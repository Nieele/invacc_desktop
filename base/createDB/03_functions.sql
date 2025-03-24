BEGIN;

-- Добавление информации о пользователе при создании аккаунта
CREATE OR REPLACE FUNCTION add_customer_info()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO CustomersInfo (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для заполнения поля old_quality
CREATE OR REPLACE FUNCTION set_actual_old_quality()
RETURNS TRIGGER AS $$
BEGIN
    NEW.old_quality = (SELECT quality FROM Items WHERE id = NEW.item_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер для обновления качества товара и записи информации об изменении
CREATE OR REPLACE FUNCTION update_quality_items()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Items
    SET quality = NEW.new_quality
    WHERE id = NEW.item_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Проверка перед созданием заказа перевозки между складами
CREATE OR REPLACE FUNCTION prevent_add_order()
RETURNS TRIGGER AS $$
DECLARE
    warehouse_active_status boolean;
    delivery_status_in_stock int := 1;
    delivery_status_request  int := 2;
    delivery_status_cancel   int := 3;
    delivery_status_shipped  int := 4;
BEGIN
    SELECT active INTO warehouse_active_status
    FROM Warehouses
    WHERE id = NEW.destination_warehouse_id;

    -- Склад на который пересылается товар должен быть активен
    IF warehouse_active_status = false THEN
        RAISE EXCEPTION 'Cannot add order to warehouse_id %, it is non active.', NEW.destination_warehouse_id;
    END IF;

    -- Товар не может находиться в аренде
    IF EXISTS (
        SELECT * 
        FROM Rent 
        WHERE item_id = NEW.item_id AND
            delivery_status_id != delivery_status_cancel AND 
            delivery_status_id != delivery_status_in_stock
        ) THEN
            RAISE EXCEPTION 'Cannot add order for item_id %, it is currently rented.', NEW.item_id;
    END IF;

    -- Товар не может быть отправлен еще раз
    IF EXISTS (
        SELECT *
        FROM WarehousesOrders
        WHERE item_id = NEW.item_id AND
            delivery_status_id != delivery_status_cancel AND
            delivery_status_id != delivery_status_shipped
        ) THEN
            RAISE EXCEPTION 'Cannot add order for item_id %, it is currently request or shipped.', NEW.item_id;
    END IF;

    -- Товар не может быть отправлен на тот же склад
    IF NEW.destination_warehouse_id = (SELECT warehouse_id FROM Items WHERE id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot add order for item_id %, item already in this warehouse.', NEW.item_id;
    END IF;

    NEW.source_warehouse_id := (SELECT warehouse_id FROM Items WHERE NEW.item_id = id);
    NEW.delivery_status_id := delivery_status_request;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Проверка обновления статуса перевозки: только работник соответствующего склада может менять статус
CREATE OR REPLACE FUNCTION prevent_update_status_warehouses_order()
RETURNS TRIGGER AS $$
DECLARE
    user_warehouse           int;
    role_admin               int := 1;
    delivery_status_cancel   int := 3;
    delivery_status_shipped  int := 4;
    delivery_status_received int := 5;
BEGIN
    -- Получаем склад на котором находится работник
    SELECT warehouse_id INTO user_warehouse
    FROM Employees
    WHERE username = current_user;

    -- Работника нет в базе
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee % not found in Employees', current_user;
    END IF;

    -- Позволяет админу устанавливать статус доставки без ограничений
    IF role_admin = 
        (SELECT role_id
         FROM Employees
         WHERE username = current_user) THEN
            RETURN NEW;
    END IF;

    -- Нельзя изменить статус доставки, если доставка уже отменена
    IF OLD.delivery_status_id = delivery_status_cancel THEN
        RAISE EXCEPTION 'Delivery status item_id % - cancel', NEW.item_id;
    END IF;

    -- Позволяем установить статус отменено
    IF NEW.delivery_status_id = delivery_status_cancel THEN
        RETURN NEW;
    END IF;

    -- Нельзя установить статус отправлено, если уже стоит статус получено
    IF OLD.delivery_status_id = delivery_status_received AND
       (NEW.delivery_status_id = delivery_status_shipped OR
        NEW.delivery_status_id = delivery_status_cancel) THEN
        RAISE EXCEPTION 'It is not possible to send an item that has already been received';
    END IF;

    --  Установить статус отправлено может только работник склада на который доставляют
   IF NEW.delivery_status_id = delivery_status_shipped THEN
        IF NEW.source_warehouse_id != user_warehouse THEN
                RAISE EXCEPTION 'It is not possible to confirm the shipment from another warehouse.';
        ELSE
            RETURN NEW;
        END IF;
    END IF;
    
    -- Установить статус доставлено может только работник склада на который доставляют
    IF NEW.delivery_status_id = delivery_status_received THEN
        IF NEW.destination_warehouse_id != user_warehouse THEN
                RAISE EXCEPTION 'It is not possible to confirm receipt from another warehouse.';
            ELSE
                RETURN NEW;
        END IF;
    END IF;
    
    -- Запрещены другие виды статусов
    RAISE EXCEPTION 'Uncorrect delivery status.';
END;
$$ LANGUAGE plpgsql;

-- Обновление истории перевозок при изменении статуса заказа
CREATE OR REPLACE FUNCTION update_warehouses_order_status()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_cancel   int := 3;
    delivery_status_shipped  int := 4;
    delivery_status_received int := 5;
BEGIN
    -- Позволяем установить статус отменено
    IF NEW.delivery_status_id = delivery_status_cancel THEN
        RETURN NEW;
    END IF;

    -- Если статус сменился на отправлено
    IF NEW.delivery_status_id = delivery_status_shipped THEN
        -- Выставляем время отправки
        UPDATE WarehousesOrders
        SET sending_time = NOW()
        WHERE id = NEW.id;

        RETURN NEW;
    END IF;
    
    -- Если статус изменился на получено
    IF NEW.delivery_status_id = delivery_status_received THEN
        -- Выставляем время приемки
        UPDATE WarehousesOrders
        SET receiving_time = NOW()
        WHERE id = NEW.id;

        -- Изменяем склад предмета
        UPDATE Items
        SET warehouse_id = NEW.destination_warehouse_id
        where id = NEW.item_id;

        RETURN NEW;
    END IF;

    -- Запрещены другие виды статусов
    RAISE EXCEPTION 'Uncorrect delivery status.';
END;
$$ LANGUAGE plpgsql;

-- Проверка перед списанием товара
CREATE OR REPLACE FUNCTION prevent_decommissioning()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock int := 1;
    delivery_status_cancel   int := 3;
    delivery_status_received int := 5;
BEGIN
    -- Товар не должен быть арендован (на складе или отменен)
    IF EXISTS (
        SELECT * 
        FROM Rent 
        WHERE item_id = NEW.item_id AND
            delivery_status_id != delivery_status_in_stock AND
            delivery_status_id != delivery_status_cancel
        ) THEN
            RAISE EXCEPTION 'Cannot decommissioning item_id %, it is currently rented.', NEW.item_id;
    END IF;

    -- Товар не должен перевозиться на другой склад (отменен или доставлен)
    IF EXISTS (
        SELECT *
        FROM WarehousesOrders
        WHERE item_id = NEW.item_id AND
            delivery_status_id != delivery_status_cancel AND
            delivery_status_id != delivery_status_received
        ) THEN
            RAISE EXCEPTION 'Cannot decommissioning item_id %, it is currently ordered.', NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Выставление неактивного состояния
CREATE OR REPLACE FUNCTION update_decommission_item()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Items
    SET active = FALSE
    WHERE id = NEW.item_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Проверка перед созданием аренды
CREATE OR REPLACE FUNCTION prevent_rent()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock int := 1;
    delivery_status_request  int := 2;
    delivery_status_cancel   int := 3;
    delivery_status_received int := 5;
BEGIN
    -- Товар неактивен 
    IF EXISTS (SELECT * FROM Items WHERE NEW.item_id = id AND active = FALSE) THEN
        RAISE EXCEPTION 'Cannot rent item_id %, it is currently unactive.', NEW.item_id;
    END IF;

    -- Товар передвигается между складами
    IF EXISTS (
        SELECT * 
        FROM WarehousesOrders 
        WHERE item_id = NEW.item_id AND 
        delivery_status_id != delivery_status_cancel 
        AND delivery_status_id != delivery_status_received) THEN
            RAISE EXCEPTION 'Cannot rent item_id %, it is currently ordered.', NEW.item_id;
    END IF;

    -- Товар списан
    IF EXISTS (SELECT * FROM ItemsDecommissioning WHERE item_id = NEW.item_id) THEN
        RAISE EXCEPTION 'Cannot rent item_id %, it is decommissioned.', NEW.item_id;
    END IF;

    NEW.delivery_status_id := delivery_status_request;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Вычисление общей суммы аренды с учётом скидок
CREATE OR REPLACE FUNCTION calculate_total_interim_payment_rent()
RETURNS TRIGGER AS $$
DECLARE
    total_days int;
    item_price decimal(10,2);
    total_payments_tmp decimal(10,2) := 0;
BEGIN
    -- количество полных дней аренды
    total_days := get_total_rental_days(NEW.start_rent_time, NEW.end_rent_time);

    -- Получаем цену товара
    SELECT price INTO item_price 
    FROM Items 
    WHERE id = NEW.item_id;

    -- Вычисляем общую сумму аренды с учётом скидок
    total_payments_tmp := calculate_discounted_payment(
        NEW.item_id,
        item_price,
        NEW.start_rent_time::date,
        total_days
    );

    -- Update rent payment
    UPDATE Rent 
    SET total_payments = total_payments_tmp
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для вычисления общего количества дней аренды
-- Первый день аренды с 00:00 до 12:00 следующего дня считается за 1 день, далее каждый день обновляется в 12:00
CREATE OR REPLACE FUNCTION get_total_rental_days(start_time timestamp, end_time timestamp)
RETURNS int AS $$
DECLARE
    day_diff int;
    end_hour int;
BEGIN
    day_diff := EXTRACT(DAY FROM end_time - start_time);
    end_hour := EXTRACT(HOUR FROM end_time);
    
    RETURN CASE
        WHEN day_diff = 0 THEN 1
        ELSE day_diff + CASE WHEN end_hour >= 12 THEN 1 ELSE 0 END
    END;
END;
$$ LANGUAGE plpgsql;

-- Расчет полной стоимости аренды с учетом скидок
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

CREATE OR REPLACE FUNCTION process_update_devilery_status_rent()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock    int := 1;
    delivery_status_request     int := 2;
    delivery_status_cancel      int := 3;
    delivery_status_received    int := 5;
    delivery_status_returning   int := 6;
BEGIN
    -- Нельзя отменить заказ, если он уже в аренде
    IF (NEW.delivery_status_id = delivery_status_cancel AND 
        OLD.delivery_status_id != delivery_status_request) THEN
        RAISE EXCEPTION 'Cannot cancel rent item_id %, it is already rented', NEW.item_id;
    END IF;

    -- Если статус аренды изменился на отменен, то удаляем (перемещаем в историю)
    IF NEW.delivery_status_id = delivery_status_cancel THEN
        DELETE FROM Rent
        WHERE id = NEW.id;
    END IF;

    -- Если статус аренды изменился на получено, то устанавливаем время начала аренды
    IF NEW.delivery_status_id = delivery_status_received THEN
        UPDATE Rent
        SET start_rent_time = NOW(),
            end_rent_time = NOW() + INTERVAL '1 day' * NEW.number_of_days + INTERVAL '12 hours'
        WHERE id = NEW.id;
    END IF;

    -- Если статус аренды изменился на возвращается, то устанавливаем время окончания аренды
    -- Затем рассчитываем конечную стоимость аренды
    IF NEW.delivery_status_id = delivery_status_returning AND NEW.overdue = FALSE THEN
        PERFORM calculate_total_interim_payment_rent();
    END IF;

    -- Если товар прибыл на склад, то отправляем в историю
    IF NEW.delivery_status_id = delivery_status_in_stock THEN
        DELETE FROM Rent
        WHERE id = NEW.id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание записи в истории аренды при удалении аренды
CREATE OR REPLACE FUNCTION add_rent_history()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_cancel int := 3;
    warehouse_id_item int;
    start_overdue_time timestamp;
    overdue_rent_days_calc int := 0;
    late_penalty_item decimal(10, 2);
BEGIN
    SELECT warehouse_id 
    FROM Items 
    WHERE id = OLD.item_id
    INTO warehouse_id_item;

    -- Вычисление дней просрочки
    IF OLD.overdue = true THEN
        start_overdue_time := CASE  
            WHEN (OLD.end_rent_time < DATE_TRUNC('day', OLD.start_rent_time) + INTERVAL '2 days')
                 OR (EXTRACT(HOUR FROM OLD.end_rent_time) >= 12) THEN
                DATE_TRUNC('day', OLD.start_rent_time) + INTERVAL '2 days'
            ELSE
                DATE_TRUNC('day', OLD.end_rent_time) + INTERVAL '1 day'
        END;
        overdue_rent_days_calc := 1 + CEIL(EXTRACT(EPOCH FROM (NOW() - start_overdue_time)) / 86400);
    END IF;

    SELECT late_penalty 
    FROM Items WHERE id = OLD.item_id
    INTO late_penalty_item;

    INSERT INTO RentHistory(item_id, warehouse_rent_id, customer_id, address, delivery_status_id, start_rent_time, end_rent_time, overdue_rent_days, total_payments)
    VALUES (
            OLD.item_id,
            warehouse_id_item,
            OLD.customer_id,
            OLD.address,
            OLD.delivery_status_id,
            OLD.start_rent_time,
            NOW(),
            overdue_rent_days_calc,
            OLD.total_payments + late_penalty_item * overdue_rent_days_calc
        );

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Ежедневное обновление флага просрочки аренды
CREATE OR REPLACE FUNCTION daily_update_overdue_rent()
RETURNS VOID AS $$
BEGIN
    UPDATE Rent
    SET overdue = true 
    WHERE overdue = false
    AND NOW() > (
        CASE 
            WHEN NOW() < DATE_TRUNC('day', start_rent_time) + INTERVAL '1 day 12 hours' THEN
                DATE_TRUNC('day', start_rent_time) + INTERVAL '1 day 12 hours'
            ELSE
                DATE_TRUNC('day', end_rent_time) + 
                    (CASE 
                        WHEN EXTRACT(HOUR FROM end_rent_time) >= 12 THEN INTERVAL '1 day 12 hours' 
                        ELSE INTERVAL '12 hours' 
                    END)
        END
    );
END;
$$ LANGUAGE plpgsql;

COMMIT;