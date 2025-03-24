BEGIN;

-- Adding user information when creating an account (insert customer auth)
CREATE OR REPLACE FUNCTION add_customer_info()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO CustomersInfo (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Set old_quality from item before insert to ItemsServiceHistory
CREATE OR REPLACE FUNCTION set_actual_old_quality()
RETURNS TRIGGER AS $$
BEGIN
    NEW.old_quality = (SELECT quality FROM Items WHERE id = NEW.item_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update quality in Items after insert to ItemsServiceHistory
CREATE OR REPLACE FUNCTION update_quality_items()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Items
    SET quality = NEW.new_quality
    WHERE id = NEW.item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Validation function before creating a warehouse transfer order
CREATE OR REPLACE FUNCTION prevent_add_order()
RETURNS TRIGGER AS $$
DECLARE
    warehouse_active_status boolean;
    delivery_status_in_stock CONSTANT int := 1;
    delivery_status_request  CONSTANT int := 2;
    delivery_status_cancel   CONSTANT int := 3;
    delivery_status_shipped  CONSTANT int := 4;
BEGIN
    -- Check if destination warehouse exists and is active
    SELECT active INTO warehouse_active_status
    FROM Warehouses
    WHERE id = NEW.destination_warehouse_id;

    IF NOT warehouse_active_status THEN
        RAISE EXCEPTION 'Cannot transfer to inactive warehouse (id: %)', NEW.destination_warehouse_id;
    END IF;

    -- Get current warehouse and validate same warehouse transfer
    NEW.source_warehouse_id := (SELECT warehouse_id FROM Items WHERE id = NEW.item_id);
    
    IF NEW.destination_warehouse_id = NEW.source_warehouse_id THEN
        RAISE EXCEPTION 'Item (id: %) is already in warehouse %', NEW.item_id, NEW.destination_warehouse_id;
    END IF;

    -- Check if item is available (not rented)
    IF EXISTS (
        SELECT * FROM Rent 
        WHERE item_id = NEW.item_id 
        AND delivery_status_id NOT IN (delivery_status_cancel, delivery_status_in_stock)
    ) THEN
        RAISE EXCEPTION 'Item (id: %) is currently rented', NEW.item_id;
    END IF;

    -- Check if item isn't already being transferred
    IF EXISTS (
        SELECT 1 FROM WarehousesOrders
        WHERE item_id = NEW.item_id 
        AND delivery_status_id NOT IN (delivery_status_cancel, delivery_status_shipped)
    ) THEN
        RAISE EXCEPTION 'Item (id: %) already has pending transfer', NEW.item_id;
    END IF;

    -- Set initial status
    NEW.delivery_status_id := delivery_status_request;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Prevent updates to warehouse transfer orders
CREATE OR REPLACE FUNCTION prevent_update_status_warehouses_order()
RETURNS TRIGGER AS $$
DECLARE
    user_warehouse           int;
    role_admin               CONSTANT int := 1;
    delivery_status_cancel   CONSTANT int := 3;
    delivery_status_shipped  CONSTANT int := 4;
    delivery_status_received CONSTANT int := 5;
BEGIN
    -- Get employee's warehouse
    SELECT warehouse_id INTO user_warehouse
    FROM Employees
    WHERE username = current_user;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee % not found', current_user;
    END IF;

    -- Allow admin full access
    IF EXISTS (
        SELECT * FROM Employees 
        WHERE username = current_user 
        AND role_id = role_admin
    ) THEN
        RETURN NEW;
    END IF;

    -- Prevent updates to cancelled orders
    IF OLD.delivery_status_id = delivery_status_cancel THEN
        RAISE EXCEPTION 'Cannot modify cancelled order for item %', NEW.item_id;
    END IF;

    -- Allow cancellation from any status
    IF NEW.delivery_status_id = delivery_status_cancel THEN
        RETURN NEW;
    END IF;

    -- Prevent shipping or cancelling received items
    IF OLD.delivery_status_id = delivery_status_received AND
       NEW.delivery_status_id IN (delivery_status_shipped, delivery_status_cancel) THEN
        RAISE EXCEPTION 'Cannot modify status of received items';
    END IF;

    -- Validate shipping status update
    IF NEW.delivery_status_id = delivery_status_shipped THEN
        IF NEW.source_warehouse_id = user_warehouse THEN
            RETURN NEW;
        END IF;
        RAISE EXCEPTION 'Only source warehouse can update shipping status';
    END IF;
    
    -- Validate receiving status update
    IF NEW.delivery_status_id = delivery_status_received THEN
        IF NEW.destination_warehouse_id = user_warehouse THEN
            RETURN NEW;
        END IF;
        RAISE EXCEPTION 'Only destination warehouse can confirm receipt';
    END IF;
    
    RAISE EXCEPTION 'Invalid delivery status';
END;
$$ LANGUAGE plpgsql;

-- Update warehouse transfer order status
CREATE OR REPLACE FUNCTION update_warehouses_order_status()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_cancel   CONSTANT int := 3;
    delivery_status_shipped  CONSTANT int := 4;
    delivery_status_received CONSTANT int := 5;
BEGIN
    CASE NEW.delivery_status_id
        WHEN delivery_status_cancel THEN
            -- No additional processing needed for cancellation
            NULL;
            
        WHEN delivery_status_shipped THEN
            -- Update sending timestamp
            UPDATE WarehousesOrders
            SET sending_time = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
            
        WHEN delivery_status_received THEN
            -- Update receiving timestamp and warehouse location
            UPDATE WarehousesOrders
            SET receiving_time = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
            
            UPDATE Items
            SET warehouse_id = NEW.destination_warehouse_id
            WHERE id = NEW.item_id;
            
        ELSE
            RAISE EXCEPTION 'Invalid delivery status: %', NEW.delivery_status_id;
    END CASE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Validate item before decommissioning
CREATE OR REPLACE FUNCTION validate_item_decommissioning()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock CONSTANT int := 1;
    delivery_status_cancel   CONSTANT int := 3;
    delivery_status_received CONSTANT int := 5;
BEGIN
    -- Check if item is currently rented
    IF EXISTS (
        SELECT *
        FROM Rent 
        WHERE item_id = NEW.item_id 
        AND delivery_status_id NOT IN (delivery_status_in_stock, delivery_status_cancel)
    ) THEN
        RAISE EXCEPTION 'Cannot decommission item (id: %). Item is currently rented', NEW.item_id;
    END IF;

    -- Check if item is in transit between warehouses
    IF EXISTS (
        SELECT *
        FROM WarehousesOrders
        WHERE item_id = NEW.item_id 
        AND delivery_status_id NOT IN (delivery_status_cancel, delivery_status_received)
    ) THEN
        RAISE EXCEPTION 'Cannot decommission item (id: %). Item is currently in transit', NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Update item status to inactive when decommissioned
CREATE OR REPLACE FUNCTION set_item_inactive_on_decommission()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Items
    SET active = FALSE
    WHERE id = NEW.item_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Validate item availability before creating a rent
CREATE OR REPLACE FUNCTION prevent_rent()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock CONSTANT int := 1;
    delivery_status_request  CONSTANT int := 2;
    delivery_status_cancel   CONSTANT int := 3;
    delivery_status_received CONSTANT int := 5;
BEGIN
    -- Check if item exists and is active
    IF EXISTS (SELECT * FROM Items WHERE id = NEW.item_id AND active = FALSE) THEN
        RAISE EXCEPTION 'Cannot rent item (id: %). Item is inactive or does not exist', NEW.item_id;
    END IF;

    -- Check if item is decommissioned
    IF EXISTS (SELECT * FROM ItemsDecommissioning WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot rent item (id: %). Item is decommissioned', NEW.item_id;
    END IF;

    -- Check if item is in warehouse transfer
    IF EXISTS (
        SELECT * 
        FROM WarehousesOrders 
        WHERE item_id = NEW.item_id 
        AND delivery_status_id NOT IN (delivery_status_cancel, delivery_status_received)
    ) THEN
        RAISE EXCEPTION 'Cannot rent item (id: %). Item is currently in transfer', NEW.item_id;
    END IF;

    -- Set initial status
    NEW.delivery_status_id := delivery_status_request;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_total_rental_days(start_time timestamp, end_time timestamp)
RETURNS int AS $$
DECLARE
    rental_days int;
    noon_cutoff CONSTANT int := 12;
BEGIN
    -- Validate input
    IF start_time IS NULL OR end_time IS NULL THEN
        RAISE EXCEPTION 'Start time and end time cannot be null';
    END IF;

    IF end_time < start_time THEN
        RAISE EXCEPTION 'End time cannot be before start time';
    END IF;

    -- Calculate base days difference
    rental_days := EXTRACT(DAY FROM end_time - start_time);

    RETURN CASE
        -- Same day rental counts as 1 day
        WHEN rental_days = 0 THEN 1
        -- Add extra day if rental ends after noon
        ELSE rental_days + CASE 
            WHEN EXTRACT(HOUR FROM end_time) >= noon_cutoff THEN 1 
            ELSE 0 
        END
    END;
END;
$$ LANGUAGE plpgsql;

-- Calculate total rental cost including discounts
CREATE OR REPLACE FUNCTION calculate_discounted_payment(item_id int, item_price decimal, start_date date, days int)
RETURNS decimal AS $$
BEGIN
    RETURN (
        WITH daily_discounts AS (
            SELECT d.start_date, d.end_date, SUM(d.percent) as total_percent
            FROM Discounts d
            JOIN ItemsDiscounts itds ON itds.discount_id = d.id
            WHERE itds.item_id = item_id
            GROUP BY d.start_date, d.end_date
        )
        SELECT SUM(
            item_price * (1 - LEAST(COALESCE(dd.total_percent, 0), 100) / 100.0)
        )
        FROM generate_series(start_date, start_date + (days - 1), '1 day') AS rental_day
        LEFT JOIN daily_discounts dd ON rental_day BETWEEN dd.start_date AND dd.end_date
    );
END;
$$ LANGUAGE plpgsql;

-- calculate total payment for interim rent
CREATE OR REPLACE FUNCTION calculate_total_interim_payment_rent(item_id int, start_time timestamp, end_time timestamp)
RETURNS DECIMAL AS $$
DECLARE
    total_days int;
    item_price decimal(10,2);
    total_payment decimal(10,2);
BEGIN
    -- Validate item exists and get price
    SELECT price INTO STRICT item_price 
    FROM Items 
    WHERE id = item_id;

    -- Calculate rental duration
    IF start_time IS NULL OR end_time IS NULL THEN
        RAISE EXCEPTION 'Invalid rental period: start or end time is null';
    END IF;
    
    total_days := get_total_rental_days(start_time, end_time);
    
    -- Calculate total payment with discounts
    total_payment := calculate_discounted_payment(
        item_id,
        item_price,
        start_time::date,
        total_days
    );

    RETURN total_payment;
END;
$$ LANGUAGE plpgsql;

-- Process rent status updates
CREATE OR REPLACE FUNCTION process_rent_status_update()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock  CONSTANT int := 1;
    delivery_status_request   CONSTANT int := 2;
    delivery_status_cancel    CONSTANT int := 3;
    delivery_status_received  CONSTANT int := 5;
    delivery_status_returning CONSTANT int := 6;
    new_total_payment         decimal(10, 2);
BEGIN
    -- Handle cancellation
    IF NEW.delivery_status_id = delivery_status_cancel THEN 
        -- Prevent cancellation of active rentals
        IF OLD.delivery_status_id != delivery_status_request THEN
            RAISE EXCEPTION 'Cannot cancel rent item_id %, it is already rented', NEW.item_id;
        END IF;

        -- Move cancelled rentals to history
        DELETE FROM Rent
        WHERE id = NEW.id;
    END IF;

    -- Set rental start time and end time when item is received
    IF NEW.delivery_status_id = delivery_status_received THEN
        UPDATE Rent
        SET start_rent_time = CURRENT_TIMESTAMP,
            end_rent_time   = CURRENT_TIMESTAMP + 
                              (INTERVAL '1 day' * NEW.number_of_days) + 
                               INTERVAL '12 hours'
        WHERE id = NEW.id;
    END IF;

    -- Calculate final rental cost when item is being returned (if not overdue)
    IF NEW.delivery_status_id = delivery_status_returning AND NEW.overdue = FALSE THEN
        new_total_payment := calculate_total_interim_payment_rent(
            NEW.item_id,
            NEW.start_rent_time,
            CURRENT_TIMESTAMP
        );

        UPDATE Rent
        SET total_payments = new_total_payment
        WHERE id = NEW.id;
    END IF;

    -- Move completed rentals to history when item is back in stock
    IF NEW.delivery_status_id = delivery_status_in_stock THEN
        DELETE FROM Rent
        WHERE id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Insert rental record into history
CREATE OR REPLACE FUNCTION add_rent_history()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_cancel   CONSTANT int := 3;
    warehouse_id_item       int;
    start_overdue_time      timestamp;
    overdue_days            int := 0;
    late_penalty_amount     decimal(10, 2);
BEGIN
    -- Get warehouse ID for the rented item
    SELECT warehouse_id INTO warehouse_id_item 
    FROM Items 
    WHERE id = OLD.item_id;

    -- Calculate overdue days if rental was overdue
    IF OLD.overdue THEN
        start_overdue_time := CASE  
            -- For rentals less than 2 days or ending after noon
            WHEN OLD.end_rent_time < DATE_TRUNC('day', OLD.start_rent_time) + INTERVAL '2 days'
                 OR EXTRACT(HOUR FROM OLD.end_rent_time) >= 12 
            THEN DATE_TRUNC('day', OLD.start_rent_time) + INTERVAL '2 days'
            -- For regular rentals
            ELSE DATE_TRUNC('day', OLD.end_rent_time) + INTERVAL '1 day'
        END;
        
        overdue_days := 1 + CEIL(EXTRACT(EPOCH FROM (NOW() - start_overdue_time)) / 86400);
    END IF;

    -- Get late penalty amount for the item
    SELECT late_penalty INTO late_penalty_amount 
    FROM Items 
    WHERE id = OLD.item_id;

    -- Insert rental record into history
    INSERT INTO RentHistory (
        item_id,
        warehouse_rent_id,
        customer_id,
        address,
        delivery_status_id,
        start_rent_time,
        end_rent_time,
        overdue_rent_days,
        total_payments
    ) VALUES (
        OLD.item_id,
        warehouse_id_item,
        OLD.customer_id,
        OLD.address,
        OLD.delivery_status_id,
        OLD.start_rent_time,
        NOW(),
        overdue_days,
        OLD.total_payments + (late_penalty_amount * overdue_days)
    );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- TODO: add penny to late penalty calculation
CREATE OR REPLACE FUNCTION daily_update_overdue_rent()
RETURNS VOID AS $$
BEGIN
    UPDATE Rent
    SET overdue = true 
    WHERE overdue = false
    AND NOW() > calculate_overdue_deadline(start_rent_time, end_rent_time);
END;
$$ LANGUAGE plpgsql;

-- Helper function to calculate overdue deadline
CREATE OR REPLACE FUNCTION calculate_overdue_deadline(start_time timestamp, end_time timestamp)
RETURNS timestamp AS $$
DECLARE
    noon_cutoff CONSTANT int := 12;
BEGIN
    -- For rentals in first 24 hours
    IF NOW() < DATE_TRUNC('day', start_time) + INTERVAL '1 day 12 hours' THEN
        RETURN DATE_TRUNC('day', start_time) + INTERVAL '1 day 12 hours';
    END IF;

    -- For all other rentals
    RETURN DATE_TRUNC('day', end_time) + 
        CASE 
            WHEN EXTRACT(HOUR FROM end_time) >= noon_cutoff THEN INTERVAL '1 day 12 hours'
            ELSE INTERVAL '12 hours'
        END;
END;
$$ LANGUAGE plpgsql;

COMMIT;