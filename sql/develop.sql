CREATE TABLE IF NOT EXISTS Warehouses (
    id       serial        PRIMARY KEY,
    name     varchar(50)   NOT NULL  UNIQUE,
    phone    varchar(15)   NOT NULL  UNIQUE,
    email    varchar(50)   NOT NULL  UNIQUE,
    address  varchar(100)  NOT NULL  UNIQUE,
    active   boolean       NOT NULL  DEFAULT true
);

CREATE TABLE IF NOT EXISTS Items (
    id            serial         PRIMARY KEY,
    warehouse_id  int            NOT NULL,
    name          varchar(50)    NOT NULL,
    desription    text           NULL,
    quality       int            NOT NULL  DEFAULT 100  CHECK (quality >= 0 AND quality <= 100),
    price         decimal(10,2)  NOT NULL               CHECK (price > 0),
    late_penalty  decimal(10,2)  NOT NULL               CHECK (late_penalty > 0),
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ItemsInfo (
    id          serial       PRIMARY KEY,
    created_by  varchar(50)  NOT NULL,
    created_at  timestamp    NOT NULL  DEFAULT NOW(),
    FOREIGN KEY (id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ItemsServiceHistory (
    id             serial  PRIMARY KEY,
    item_id        int     NOT NULL,
    old_quality    int     NOT NULL  CHECK (old_quality >= 0 AND old_quality <= 100),
    new_quality    int     NOT NULL  CHECK (new_quality >= 0 AND new_quality <= 100),
    change_reason  text    NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ItemsServiceHistoryInfo (
    id          serial       PRIMARY KEY,
    changed_by  varchar(50)  NOT NULL,
    changed_at  timestamp    NOT NULL  DEFAULT NOW(),
    FOREIGN KEY (id) REFERENCES ItemsServiceHistory (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ItemDecommissioning (
    id       serial  PRIMARY KEY,
    item_id  int     NOT NULL  UNIQUE,
    reason   text    NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Categories (
    id             serial       PRIMARY KEY,
    category_name  varchar(50)  NOT NULL  UNIQUE
);

CREATE TABLE IF NOT EXISTS ItemsCategories (
    item_id      int  NOT NULL,
    category_id  int  NOT NULL,
    FOREIGN KEY (item_id)     REFERENCES Items (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE(item_id, category_id)
);

CREATE TABLE IF NOT EXISTS Discounts (
    id          serial       PRIMARY KEY,
    name        varchar(50)  NOT NULL,
    descpition  text         NULL,
    percent     int          NOT NULL                 CHECK (percent > 0 AND percent < 100),
    start_date  timestamp    NOT NULL  DEFAULT NOW()  CHECK (start_date <= NOW()),
    end_date    timestamp    NOT NULL                 CHECK (end_date > NOW())
);

CREATE TABLE IF NOT EXISTS ItemsDiscounts (
    item_id      int  NOT NULL,
    discount_id  int  NOT NULL,
    FOREIGN KEY (item_id)     REFERENCES Items (id)     ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (discount_id) REFERENCES Discounts (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE(item_id, discount_id)
);

CREATE TABLE IF NOT EXISTS Customers (
    id         serial        PRIMARY KEY,
    firstname  varchar(50)   NOT NULL,
    lastname   varchar(50)   NOT NULL,
    phone      varchar(15)   NOT NULL,
    email      varchar(50)   NOT NULL  DEFAULT 'empty',
    address    varchar(100)  NOT NULL  DEFAULT 'empty',
    passport   varchar(30)   NOT NULL  DEFAULT 'empty'
);

CREATE TABLE IF NOT EXISTS Rent (
    id               serial         PRIMARY KEY,
    item_id          int            NOT NULL  UNIQUE,
    customer_id      int            NOT NULL,
    start_rent_time  timestamp      NOT NULL  DEFAULT NOW(),
    end_rent_time    timestamp      NOT NULL,  
    total_payments   decimal(10,2)  NOT NULL  DEFAULT 0,
    overdue          boolean                  DEFAULT false,
    FOREIGN KEY (item_id)     REFERENCES Items (id)     ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (start_rent_time < end_rent_time)
);

CREATE TABLE IF NOT EXISTS RentHistory (
    id                 serial         PRIMARY KEY,
    item_id            int            NOT NULL,
    customer_id        int            NOT NULL,
    start_rent_time    timestamp      NOT NULL,
    end_rent_time      timestamp      NOT NULL,
    overdue_rent_days  int            NOT NULL,
    total_payments     decimal(10,2)  NOT NULL,
    FOREIGN KEY (item_id)     REFERENCES Items (id)     ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TYPE delivery_status AS ENUM ('request', 'shipped', 'received');

CREATE TABLE IF NOT EXISTS WarehousesOrders (
    id                        serial           PRIMARY KEY,
    uuid_delivery             uuid             NOT NULL  DEFAULT gen_random_uuid()  UNIQUE,
    item_id                   int              NOT NULL  UNIQUE,
    destination_warehouse_id  int              NOT NULL,
    status                    delivery_status  NOT NULL  DEFAULT 'request',
    FOREIGN KEY (item_id)                  REFERENCES Items (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (destination_warehouse_id) REFERENCES Warehouses (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS WarehousesOrdersHistory (
    id                        serial     PRIMARY KEY,
    item_id                   int        NOT NULL,
    source_warehouse_id       int        NOT NULL,
    destination_warehouse_id  int        NOT NULL,
    sending_time              timestamp  NULL       DEFAULT NULL,
    receiving_time            timestamp  NULL       DEFAULT NULL,
    uuid_delivery             uuid       NULL       UNIQUE,
    FOREIGN KEY (item_id)                  REFERENCES Items (id)                       ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (source_warehouse_id)      REFERENCES Warehouses (id)                  ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (destination_warehouse_id) REFERENCES Warehouses (id)                  ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (uuid_delivery)            REFERENCES WarehousesOrders (uuid_delivery) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE UserWarehouse (
    id            serial       PRIMARY KEY,
    username      varchar(50)  NOT NULL  UNIQUE,
    warehouse_id  int          NULL,
    FOREIGN KEY (warehouse_id) REFERENCES Warehouses (id) ON DELETE SET NULL ON UPDATE CASCADE
);


-- Triggers

-- Automatic creation of a record in the table ItemsInfo
CREATE OR REPLACE FUNCTION add_items_info()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO ItemsInfo (id, created_by)
    VALUES (NEW.id, current_user);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_items_info
AFTER INSERT ON Items
FOR EACH ROW
EXECUTE FUNCTION add_items_info();


-- Automatic replace quality Items after adding an entry to the ItemsServiceHistory
CREATE OR REPLACE FUNCTION add_items_service_history()
RETURNS TRIGGER AS $$
BEGIN
    -- add in the table ItemsServiceHistory
    INSERT INTO ItemsServiceHistoryInfo (id, changed_by)
    VALUES (NEW.id, current_user);

    -- set old quality from items (to avoid insertion errors) in ItemsServiceHistory
    UPDATE ItemsServiceHistory
    SET old_quality = (
                        SELECT quality 
                        FROM Items 
                        WHERE id = NEW.item_id
                      );

    -- update quality in Items (set new_quality from ItemsServiceHistory) 
    UPDATE Items
    SET quality = NEW.new_quality
    WHERE id = NEW.item_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_items_service_history
AFTER INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION add_items_service_history();


-- Check before order. The item should not be rented
CREATE OR REPLACE FUNCTION prevent_add_order()
RETURNS TRIGGER AS $$
DECLARE
    warehouse_active_status boolean;
BEGIN
    SELECT active INTO warehouse_active_status
    FROM Warehouses
    WHERE id = NEW.destination_warehouse_id;

    IF warehouse_active_status = false THEN
        RAISE EXCEPTION 'Cannot add order to warehouse_id %, it is non active.', NEW.destination_warehouse_id;
    END IF;

    IF EXISTS (SELECT * FROM Rent WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot add order for item_id %, it is currently rented.', NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_add_order
BEFORE INSERT ON WarehousesOrders
FOR EACH ROW
EXECUTE FUNCTION prevent_add_order();


-- Creating of a record in the WarehousesOrdersHistory after insert to WarehousesOrders
CREATE OR REPLACE FUNCTION add_warehouses_orders_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO WarehousesOrdersHistory(item_id, source_warehouse_id, destination_warehouse_id, sending_time, receiving_time, uuid_delivery)
    VALUES (
                NEW.item_id,
                (SELECT warehouse_id FROM Items WHERE id = NEW.item_id),
                NEW.destination_warehouse_id,
                NULL,
                NULL,
                NEW.uuid_delivery
           );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_warehouses_orders_history
AFTER INSERT ON WarehousesOrders
FOR EACH ROW
EXECUTE FUNCTION add_warehouses_orders_history();


-- changing the WarehousesOrderHistory when changing the status of the WarehousesOrder
CREATE OR REPLACE FUNCTION update_warehouses_order_history()
RETURNS TRIGGER AS $$
BEGIN
   -- status changed to shipped
    IF NEW.status = 'shipped' THEN
        UPDATE WarehousesOrdersHistory
        SET sending_time = NOW()
        WHERE uuid_delivery = NEW.uuid_delivery;
    END IF;
    
    -- status changed to received
    IF NEW.status = 'received' THEN
        UPDATE WarehousesOrdersHistory
        SET receiving_time = NOW()
        WHERE uuid_delivery = NEW.uuid_delivery;

        DELETE FROM WarehousesOrders
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_warehouses_order_history
AFTER UPDATE OF status
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.status != NEW.status)
EXECUTE FUNCTION update_warehouses_order_history();


-- Check before decommissioning. The item should not be rented or order
CREATE OR REPLACE FUNCTION prevent_decommissioning()
RETURNS TRIGGER AS $$
BEGIN
    -- the item is being rented 
    IF EXISTS (SELECT * FROM Rent WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot decommissioning item_id %, it is currently rented.', NEW.item_id;
    END IF;

    -- the item has been ordered
    IF EXISTS (SELECT * FROM WarehousesOrders WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot decommissioning item_id %, it is currently ordered.', NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_decommissioning
BEFORE INSERT ON ItemDecommissioning
FOR EACH ROW
EXECUTE FUNCTION prevent_decommissioning();


-- Check before rent. The item should not be already ordered or decommissioned
CREATE OR REPLACE FUNCTION prevent_rent()
RETURNS TRIGGER AS $$
BEGIN
    -- the item has been ordered
    IF EXISTS (SELECT * FROM WarehousesOrders WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot decommissioning item_id %, it is currently order.', NEW.item_id;
    END IF;

    -- the item has been decommissioned
    IF EXISTS (SELECT * FROM WarehousesOrders WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot decommissioning item_id %, it is currently order.', NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_rent
BEFORE INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION prevent_rent();

-- calculate total_payment
CREATE OR REPLACE FUNCTION calculate_total_interim_payment_rent()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Rent 
       SET total_payments = (
                                SELECT price 
                                  FROM Item
                                 WHERE id = NEW.item_id
                            ) * 
                                CASE 
                                    WHEN EXTRACT(HOUR FROM end_rent_time) >= 12 THEN 
                                        DATE_PART('day', end_rent_time - start_rent_time) + 1
                                    ELSE
                                        DATE_PART('day', end_rent_time - start_rent_time)
                                END
     WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_total_interim_payment_rent
AFTER INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION calculate_total_interim_payment_rent();


-- create a history record based on a record from rent after delete from rent
CREATE OR REPLACE FUNCTION add_rent_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO RentHistory(item_id, warehouse_rent_id, customer_id, start_rent_time, end_rent_time, overdue_rent_days, total_payments)
    VALUES (
            NEW.item_id,
            (SELECT warehouse_id FROM Items WHERE id = NEW.item_id),
            NEW.customer_id,
            NEW.start_rent_time,
            NOW(),
            CASE 
                WHEN NEW.overdue = true THEN
                    DATE_PART('day', ((NOW() - start_rent_time) - (end_rent_time - start_rent_time))) + 1
                ELSE 
                    0
            END,
            NEW.total_payments
        );

    UPDATE RentHistory
    SET total_payments = total_payments + overdue_rent_days * (SELECT late_penalty FROM Item WHERE id = NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_rent_history
BEFORE DELETE ON Rent
FOR EACH ROW
EXECUTE FUNCTION add_rent_history();