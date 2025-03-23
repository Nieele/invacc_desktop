BEGIN;

CREATE EXTENSION IF NOT EXISTS pgagent;

---------------------------------------------------------------------
-- Таблица должностей сотрудников
---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS Employees_roles (
    role_id     serial      PRIMARY KEY,
    role        varchar(50) NOT NULL UNIQUE
);

-- Используется в prevent_update_status_warehouses_order
INSERT INTO Employees_roles(role_id, role) 
    VALUES  (1, 'admin'),
            (2, 'unkown'),
            (3, 'worker'),
            (4, 'inventory_manager'),
            (5, 'marketing_specialist'),
            (6, 'moderator'),
            (7, 'director');

---------------------------------------------------------------------
-- Таблица сотрудников
---------------------------------------------------------------------
-- TODO: Внести поправки - должна быть возможность создавать пустого пользователя с ролью (unknown)
CREATE TABLE IF NOT EXISTS Employees (
    id              serial          PRIMARY KEY,
    username        varchar(50)     NOT NULL UNIQUE,
    full_name       varchar(100)    NOT NULL,
    warehouse_id    int             NOT NULL,
    role_id         int             NOT NULL,
    active          boolean         NOT NULL DEFAULT true,
    CONSTRAINT fk_Employees_role FOREIGN KEY (role_id) REFERENCES Employees_roles (role_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

---------------------------------------------------------------------
-- Таблица складов
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Warehouses (
    id       serial        PRIMARY KEY,
    name     varchar(50)   NOT NULL  UNIQUE,
    phone    varchar(15)   NOT NULL  UNIQUE,
    email    varchar(50)   NOT NULL  UNIQUE,
    address  varchar(100)  NOT NULL  UNIQUE,
    active   boolean       NOT NULL  DEFAULT true
);

-- Индекс для быстрого поиска активных складов
CREATE INDEX idx_warehouses_active ON Warehouses(active);

---------------------------------------------------------------------
-- Таблица товаров
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Items (
    id               serial         PRIMARY KEY,
    warehouse_id     int            NOT NULL,
    name             varchar(50)    NOT NULL,
    description      text           NULL,
    extra_attributes jsonb          NULL,
    quality          int            NOT NULL  DEFAULT 100  CHECK (quality >= 0 AND quality <= 100),
    price            decimal(10,2)  NOT NULL               CHECK (price > 0),
    late_penalty     decimal(10,2)  NOT NULL               CHECK (late_penalty > 0),
    active           boolean        NOT NULL  DEFAULT TRUE,
    CONSTRAINT fk_items_warehouses FOREIGN KEY (warehouse_id) REFERENCES Warehouses (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Индекс для быстрого поиска товаров по складу
CREATE INDEX idx_items_warehouse ON Items(warehouse_id);

---------------------------------------------------------------------
-- Тип перечисления для статусов доставки (используется для перевозок оборудования между складами)
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DeliveryStatus (
    id serial PRIMARY KEY,
    status_code text NOT NULL UNIQUE,
    description text NOT NULL
);

-- Используется в таблице WarehousesOrders
-- Используется в функции prevent_add_order, prevent_update_status_warehouses_order
INSERT INTO DeliveryStatus (id, status_code, description)
VALUES 
    (1, 'in stock',  'Прибыл на склад'),
    (2, 'request',   'Запрос на доставку'),
    (3, 'cancelled', 'Отменен'),
    (4, 'shipped',   'Отправлено'),
    (5, 'received',  'Получено'),
    (6, 'returning', 'Возврат на склад')
ON CONFLICT (status_code) DO NOTHING;

---------------------------------------------------------------------
-- Таблица заказов на перевозку оборудования между складами (WarehousesOrders)
---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS WarehousesOrders (
    id                       serial     PRIMARY KEY,
    item_id                  int        NOT NULL,
    source_warehouse_id      int        NULL,
    destination_warehouse_id int        NOT NULL,
    sending_time             timestamp  NULL,
    receiving_time           timestamp  NULL,
    delivery_status_id       int        NOT NULL DEFAULT 2, -- 2 соответствует 'request'
    CONSTRAINT fk_wo_items          FOREIGN KEY (item_id)                   REFERENCES Items (id)           ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_wo_source         FOREIGN KEY (source_warehouse_id)       REFERENCES Warehouses (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_wo_destination    FOREIGN KEY (destination_warehouse_id)  REFERENCES Warehouses (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_wo_status         FOREIGN KEY (delivery_status_id)        REFERENCES DeliveryStatus (id)  ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_wo_ ON WarehousesOrders(delivery_status_id);

---------------------------------------------------------------------
-- Таблица истории изменений качества товара
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ItemsServiceHistory (
    id             serial  PRIMARY KEY,
    item_id        int     NOT NULL,
    old_quality    int     NOT NULL  DEFAULT 0  CHECK (old_quality >= 0 AND old_quality <= 100),
    new_quality    int     NOT NULL             CHECK (new_quality >= 0 AND new_quality <= 100),
    change_reason  text    NOT NULL,
    CONSTRAINT fk_itemsservice_items FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);

---------------------------------------------------------------------
-- Таблица списания товаров
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ItemsDecommissioning (
    id       serial  PRIMARY KEY,
    item_id  int     NOT NULL  UNIQUE,
    reason   text    NOT NULL,
    CONSTRAINT fk_itemsdecommissioning_items FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);

---------------------------------------------------------------------
-- Таблицы для категорий товаров
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Categories (
    id             serial       PRIMARY KEY,
    category_name  varchar(50)  NOT NULL  UNIQUE
);

CREATE TABLE IF NOT EXISTS ItemsCategories (
    item_id      int,
    category_id  int,
    PRIMARY KEY (item_id, category_id),
    CONSTRAINT fk_itemscategories_items FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_itemscategories_categories FOREIGN KEY (category_id) REFERENCES Categories (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

---------------------------------------------------------------------
-- Таблица скидок (Discounts)
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Discounts (
    id          serial       PRIMARY KEY,
    name        varchar(50)  NOT NULL,
    description text         NULL,
    percent     smallint     NOT NULL                 CHECK (percent > 0 AND percent < 100),
    start_date  date         NOT NULL  DEFAULT CURRENT_DATE  CHECK (start_date >= CURRENT_DATE),
    end_date    date         NOT NULL                 CHECK (end_date > CURRENT_DATE)
);

-- Индекс по датам действия скидок для ускорения выборок
CREATE INDEX idx_discounts_dates ON Discounts(start_date, end_date);

---------------------------------------------------------------------
-- Таблица связи товаров и скидок
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ItemsDiscounts (
    item_id      int,
    discount_id  int,
    PRIMARY KEY (item_id, discount_id),
    CONSTRAINT fk_itemsdiscounts_items      FOREIGN KEY (item_id)       REFERENCES Items (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_itemsdiscounts_discounts  FOREIGN KEY (discount_id)   REFERENCES Discounts (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

---------------------------------------------------------------------
-- Таблица аутентификации пользователей
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CustomersAuth (
    id          serial          PRIMARY KEY,
    login       varchar(50)     NOT NULL UNIQUE,
    password    varchar(60)     NOT NULL -- bcrypt hash
);

---------------------------------------------------------------------
-- Таблица сессий аутентификаций
---------------------------------------------------------------------

-- TODO: table with jwt token, ip, device

---------------------------------------------------------------------
-- Таблица клиентов
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CustomersInfo (
    id                  serial        PRIMARY KEY,
    firstname           varchar(50)   NULL,
    lastname            varchar(50)   NULL,
    phone               varchar(30)   NULL,
    phone_verified      boolean       NOT NULL  DEFAULT false,
    email               varchar(50)   NULL,
    email_verified      boolean       NOT NULL  DEFAULT false,
    passport            varchar(30)   NULL,
    passport_verified   boolean       NOT NULL  DEFAULT false,
    CONSTRAINT fk_customersinfo_customersauth FOREIGN KEY (id) REFERENCES CustomersAuth (id) ON DELETE CASCADE ON UPDATE CASCADE
);

---------------------------------------------------------------------
-- Таблица аренды товаров
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Rent (
    id                  serial          PRIMARY KEY,
    item_id             int             NOT NULL  UNIQUE,
    customer_id         int             NOT NULL,
    address             varchar(255)    NOT NULL,
    delivery_status_id  int             NOT NULL,
    start_rent_time     timestamp       NOT NULL  DEFAULT NOW(),
    end_rent_time       timestamp       NOT NULL,  
    total_payments      decimal(10,2)   NOT NULL  DEFAULT 0,
    overdue             boolean         NOT NULL  DEFAULT false,
    CONSTRAINT fk_rent_items            FOREIGN KEY (item_id)               REFERENCES Items (id)           ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rent_customers        FOREIGN KEY (customer_id)           REFERENCES CustomersInfo (id)   ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rent_deliverystatus   FOREIGN KEY (delivery_status_id)    REFERENCES DeliveryStatus (id)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (start_rent_time < end_rent_time)
);

-- Индекс по статусу заказа
CREATE INDEX idx_rent_delivery ON Rent(delivery_status_id);

---------------------------------------------------------------------
-- Таблица истории аренды
---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS RentHistory (
    id                 serial         PRIMARY KEY,
    item_id            int            NOT NULL,
    warehouse_rent_id  int            NOT NULL,
    customer_id        int            NOT NULL,
    address            varchar(255)   NOT NULL,
    delivery_status_id int            NOT NULL,
    start_rent_time    timestamp      NOT NULL,
    end_rent_time      timestamp      NOT NULL,
    overdue_rent_days  int            NOT NULL,
    total_payments     decimal(10,2)  NOT NULL,
    CONSTRAINT fk_renthistory_items         FOREIGN KEY (item_id)           REFERENCES Items (id)       ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_renthistory_warehouses    FOREIGN KEY (warehouse_rent_id) REFERENCES Warehouses (id)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_renthistory_customers     FOREIGN KEY (customer_id)       REFERENCES CustomersInfo (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (start_rent_time < end_rent_time)
);

---------------------------------------------------------------------
-- Триггеры и функции для бизнес-логики
---------------------------------------------------------------------

-- Триггер для заполнения поля old_quality
CREATE OR REPLACE FUNCTION set_actual_old_quality()
RETURNS TRIGGER AS $$
BEGIN
    NEW.old_quality = (SELECT quality FROM Items WHERE id = NEW.item_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_items_service_history
BEFORE INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION set_actual_old_quality();

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

CREATE TRIGGER trg_update_quality_items
AFTER INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION update_quality_items();


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

CREATE TRIGGER trg_prevent_add_order
BEFORE INSERT ON WarehousesOrders
FOR EACH ROW
EXECUTE FUNCTION prevent_add_order();

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

CREATE TRIGGER trg_prevent_update_status_warehouses_order
BEFORE UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION prevent_update_status_warehouses_order();

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

CREATE TRIGGER trg_update_warehouses_order_status
AFTER UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION update_warehouses_order_status();

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

CREATE TRIGGER trg_prevent_decommissioning
BEFORE INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION prevent_decommissioning();

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

CREATE TRIGGER trg_update_decommission_item
AFTER INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION update_decommission_item();

-- Проверка перед созданием аренды
CREATE OR REPLACE FUNCTION prevent_rent()
RETURNS TRIGGER AS $$
DECLARE
    delivery_status_in_stock int := 1;
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

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_rent
BEFORE INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION prevent_rent();

-- Вычисление общей суммы аренды с учётом скидок
CREATE OR REPLACE FUNCTION calculate_total_interim_payment_rent()
RETURNS TRIGGER AS $$
DECLARE
    total_days int;
    item_price decimal(10,2);
    current_day date;
    total_discount_percent int;
    total_payments_tmp decimal(10,2) := 0;
BEGIN
    -- Всего аредованных дней
    SELECT 
        CASE
            WHEN EXTRACT(DAY FROM NEW.end_rent_time - NEW.start_rent_time) = 0 THEN 1
            ELSE EXTRACT(DAY FROM NEW.end_rent_time - NEW.start_rent_time) + 
                CASE WHEN EXTRACT(HOUR FROM NEW.end_rent_time) >= 12 THEN 1 ELSE 0 END
        END
    INTO total_days;

    -- Цена на товар
    SELECT price 
    FROM Items 
    WHERE id = NEW.item_id
    INTO item_price;

    -- Применение скидок и просчет всей стоимости аренды
    FOR i IN 0..total_days - 1 LOOP
        current_day := (NEW.start_rent_time::date + i);
        total_discount_percent := 0;

        SELECT COALESCE(SUM(Discounts.percent), 0)
        FROM Discounts
        JOIN ItemsDiscounts ON ItemsDiscounts.discount_id = Discounts.id
        WHERE ItemsDiscounts.item_id = NEW.item_id AND
            current_day BETWEEN Discounts.start_date AND Discounts.end_date
        INTO total_discount_percent;

        IF total_discount_percent > 100 THEN
            total_discount_percent := 100;
        END IF;

        total_payments_tmp := total_payments_tmp + item_price * (1 - total_discount_percent::float/100);
    END LOOP;

    -- Внесение общей стоимости аренды
    UPDATE Rent 
    SET total_payments = total_payments_tmp
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_total_interim_payment_rent
AFTER INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION calculate_total_interim_payment_rent();

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

CREATE TRIGGER trg_add_rent_history
BEFORE DELETE ON Rent
FOR EACH ROW
EXECUTE FUNCTION add_rent_history();

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

-- Создание задания pgAgent для ежедневного обновления просроченных аренд
-- TODO: обновить scheduller

-- DO $$
-- DECLARE
--     jid integer;
--     scid integer;
-- BEGIN
--     INSERT INTO pgagent.pga_job(
--         jobjclid, jobname, jobdesc, jobhostagent, jobenabled
--     ) VALUES (
--         1, 'DailyCheckOverdueRent', 'Ежедневное обновление просроченных аренд', '', true
--     ) RETURNING jobid INTO jid;

--     INSERT INTO pgagent.pga_jobstep (
--         jstjobid, jstname, jstenabled, jstkind,
--         jstconnstr, jstdbname, jstonerror,
--         jstcode, jstdesc
--     ) VALUES (
--         jid, 'CheckAndUpdate', true, 's',
--         '', 'RentalDB', 'f',
--         'SELECT public.daily_update_overdue_rent();', ''
--     );

--     INSERT INTO pgagent.pga_schedule(
--         jscjobid, jscname, jscdesc, jscenabled,
--         jscstart, jscend, jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
--     ) VALUES (
--         jid, 'Daily 12:00', '', true,
--         NOW(), (NOW() + INTERVAL '1 year'),
--         '{t,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::boolean[],
--         '{f,f,f,f,f,f,f,f,f,f,f,f,t,f,f,f,f,f,f,f,f,f,f,f}'::boolean[],
--         '{f,f,f,f,f,f,f}'::boolean[],
--         '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::boolean[],
--         '{f,f,f,f,f,f,f,f,f,f,f,f}'::boolean[]
--     ) RETURNING jscid INTO scid;
-- END
-- $$;

---------------------------------------------------------------------
-- Разделение транзакционных и аналитических данных: Материализованное представление
---------------------------------------------------------------------
-- Ежемесячная сводка по истории аренды
CREATE MATERIALIZED VIEW monthly_rent_summary AS
SELECT date_trunc('month', end_rent_time) AS month,
       COUNT(*) AS total_rents,
       SUM(total_payments) AS revenue
FROM RentHistory
WHERE delivery_status_id != 3 -- 3 - cancelled
GROUP BY month;

-- TODO: добавить pgagent для REFRESH MATERIALIZED VIEW monthly_rent_summary на 1 число месяца
REFRESH MATERIALIZED VIEW monthly_rent_summary;


---------------------------------------------------------------------
-- Логгирование
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Централизованный аудит: Создание единой таблицы аудита
---------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS logged_actions (
    id              serial      PRIMARY KEY,
    table_schema    text        NOT NULL,
    table_name      text        NOT NULL,
    operation       text        NOT NULL,
    changed_by      text        NOT NULL,
    changed_at      timestamp   NOT NULL DEFAULT NOW(),
    old_data        jsonb,
    new_data        jsonb
);

-- Универсальная функция аудита, которая записывает данные при INSERT, UPDATE и DELETE
CREATE OR REPLACE FUNCTION audit_log() RETURNS trigger AS $$
DECLARE
    v_old jsonb;
    v_new jsonb;
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_old := to_jsonb(OLD);
        INSERT INTO logged_actions(table_schema, table_name, operation, changed_by, old_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, current_user, v_old);
        RETURN OLD;
    ELSIF TG_OP = 'INSERT' THEN
        v_new := to_jsonb(NEW);
        INSERT INTO logged_actions(table_schema, table_name, operation, changed_by, new_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, current_user, v_new);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        v_old := to_jsonb(OLD);
        v_new := to_jsonb(NEW);
        INSERT INTO logged_actions(table_schema, table_name, operation, changed_by, old_data, new_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, TG_OP, current_user, v_old, v_new);
        RETURN NEW;
    END IF;
    RETURN NULL; -- Не должно достигаться
END;
$$ LANGUAGE plpgsql;

-- привязка тригера к аудиту
CREATE TRIGGER audit_test_trigger
AFTER INSERT OR UPDATE OR DELETE ON Items
FOR EACH ROW EXECUTE FUNCTION audit_log();

---------------------------------------------------------------------
-- Создание ролей и назначение привилегий
---------------------------------------------------------------------
-- postgres
DO $$
BEGIN
    CREATE ROLE postgres;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role postgres already exists, skipping creation.';
END $$;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'root';

-- register
DO $$
BEGIN
    CREATE ROLE register;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role register already exists, skipping creation.';
END $$;
ALTER ROLE register WITH NOSUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'password';

-- unknown
DO $$
BEGIN
    CREATE ROLE unknown;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role unknown already exists, skipping creation.';
END $$;
ALTER ROLE unknown WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;

-- worker
DO $$
BEGIN
    CREATE ROLE worker;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role worker already exists, skipping creation.';
END $$;
ALTER ROLE worker WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Rent, CustomersInfo TO worker;
GRANT SELECT, INSERT ON TABLE RentHistory TO worker;
GRANT USAGE, SELECT ON SEQUENCE rent_id_seq, customersinfo_id_seq, renthistory_id_seq TO worker;
GRANT SELECT ON TABLE Items, ItemsCategories, Categories, ItemsDiscounts, Discounts, WarehousesOrders, ItemsDecommissioning TO worker;

-- inventory_manager
DO $$
BEGIN
    CREATE ROLE inventory_manager;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role inventory_manager already exists, skipping creation.';
END $$;
ALTER ROLE inventory_manager WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ItemsDecommissioning, WarehousesOrders, ItemsCategories, Categories TO inventory_manager;
GRANT SELECT, INSERT, UPDATE ON TABLE WarehousesOrders, Items, ItemsServiceHistory TO inventory_manager;
GRANT USAGE, SELECT ON SEQUENCE itemsdecommissioning_id_seq, warehousesorders_id_seq, categories_id_seq, items_id_seq, itemsservicehistory_id_seq TO inventory_manager;
GRANT SELECT ON TABLE Employees, Employees_roles, Warehouses, RentHistory, Rent TO inventory_manager;

-- marketing_specialist
DO $$
BEGIN
    CREATE ROLE marketing_specialist;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role marketing_specialist already exists, skipping creation.';
END $$;
ALTER ROLE marketing_specialist WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ItemsDiscounts, Discounts TO marketing_specialist;
GRANT USAGE, SELECT ON SEQUENCE discounts_id_seq TO marketing_specialist;
GRANT SELECT ON TABLE Items, ItemsCategories, Categories, ItemsServiceHistory, Warehouses, WarehousesOrders, ItemsDecommissioning, Rent, RentHistory TO marketing_specialist;

-- director
DO $$
BEGIN
    CREATE ROLE director;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role director already exists, skipping creation.';
END $$;
ALTER ROLE director WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Warehouses, Employees TO director;
GRANT USAGE, SELECT ON SEQUENCE warehouses_id_seq, employees_id_seq TO director;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO director;

-- moderator
DO $$
BEGIN
    CREATE ROLE moderator;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role moderator already exists, skipping creation.';
END $$;
ALTER ROLE moderator WITH NOSUPERUSER INHERIT CREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT unknown, worker, inventory_manager, marketing_specialist TO moderator WITH ADMIN OPTION;

-- admin
DO $$
BEGIN
    CREATE ROLE admin;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role admin already exists, skipping creation.';
END $$;
ALTER ROLE admin WITH SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS NOLOGIN;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON SCHEMA public TO admin;

COMMIT;