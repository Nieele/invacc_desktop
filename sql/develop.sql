BEGIN;

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
    old_quality    int     NOT NULL  DEFAULT 0  CHECK (old_quality >= 0 AND old_quality <= 100),
    new_quality    int     NOT NULL             CHECK (new_quality >= 0 AND new_quality <= 100),
    change_reason  text    NOT NULL,
    FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ItemsServiceHistoryInfo (
    id          serial       PRIMARY KEY,
    changed_by  varchar(50)  NOT NULL,
    changed_at  timestamp    NOT NULL  DEFAULT NOW(),
    FOREIGN KEY (id) REFERENCES ItemsServiceHistory (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS ItemsDecommissioning (
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
    description text         NULL,
    percent     int          NOT NULL                 CHECK (percent > 0 AND percent < 100),
    start_date  date         NOT NULL  DEFAULT NOW()  CHECK (start_date >= NOW()),
    end_date    date         NOT NULL                 CHECK (end_date > NOW())
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
    phone      varchar(30)   NOT NULL  UNIQUE,
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
    warehouse_rent_id  int            NOT NULL,
    customer_id        int            NOT NULL,
    start_rent_time    timestamp      NOT NULL,
    end_rent_time      timestamp      NOT NULL,
    overdue_rent_days  int            NOT NULL,
    total_payments     decimal(10,2)  NOT NULL,
    FOREIGN KEY (item_id)               REFERENCES Items (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (warehouse_rent_id)     REFERENCES Warehouses (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (customer_id)           REFERENCES Customers (id)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (start_rent_time < end_rent_time)
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
-- set old quality from items
    NEW.old_quality = (SELECT quality 
                        FROM Items 
                        WHERE id = NEW.item_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_items_service_history
BEFORE INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION add_items_service_history();


-- update quality in Items (set new_quality from ItemsServiceHistory) 
CREATE OR REPLACE FUNCTION update_quality_items()
RETURNS TRIGGER AS $$
BEGIN
    -- add in the table ItemsServiceHistory
    INSERT INTO ItemsServiceHistoryInfo (id, changed_by)
    VALUES (NEW.id, current_user);

    UPDATE Items
    SET quality = NEW.new_quality
    WHERE id = NEW.item_id;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_quality_items
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


-- only source warehouse user can send the item and only destination warehouse user can receive the item 
CREATE OR REPLACE FUNCTION prevent_update_status_warehouses_order()
RETURNS TRIGGER AS $$
BEGIN
   -- status changed to shipped
    IF NEW.status = 'shipped' THEN
        IF (SELECT source_warehouse_id 
            FROM WarehousesOrdersHistory 
            WHERE uuid_delivery = NEW.uuid_delivery) != 
           (SELECT warehouse_id 
            FROM UserWarehouse 
            WHERE username = current_user) THEN
                RAISE EXCEPTION 'It is not possible to confirm the shipment from another warehouse.';
        END IF;
    END IF;
    
    -- status changed to received
    IF NEW.status = 'received' THEN
        IF (SELECT destination_warehouse_id 
            FROM WarehousesOrdersHistory 
            WHERE uuid_delivery = NEW.uuid_delivery) != 
           (SELECT warehouse_id 
            FROM UserWarehouse 
            WHERE username = current_user) THEN
                RAISE EXCEPTION 'It is not possible to confirm receipt from another warehouse.';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_update_status_warehouses_order
BEFORE UPDATE OF status
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.status != NEW.status)
EXECUTE FUNCTION prevent_update_status_warehouses_order();

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
BEFORE INSERT ON ItemsDecommissioning
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
    IF EXISTS (SELECT * FROM ItemsDecommissioning WHERE item_id = NEW.item_id) THEN
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
DECLARE
    total_days int;
    item_price decimal(10,2);
    current_day date;
    total_discount_percent int;
    total_payments_tmp decimal(10,2) := 0;
BEGIN
    SELECT 
        CASE
            WHEN EXTRACT(DAY FROM NEW.end_rent_time - NEW.start_rent_time) = 0 THEN 1
            ELSE EXTRACT(DAY FROM NEW.end_rent_time - NEW.start_rent_time) + 
                CASE WHEN EXTRACT(HOUR FROM NEW.end_rent_time) >= 12 THEN 1 ELSE 0 END
        END
    INTO total_days;

    SELECT price 
    FROM Items 
    WHERE id = NEW.item_id
    INTO item_price;

    FOR i IN 0..total_days - 1 LOOP
        current_day := NEW.start_rent_time::date + (i * INTERVAL '1 day');
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


-- create a history record based on a record from rent after delete from rent
CREATE OR REPLACE FUNCTION add_rent_history()
RETURNS TRIGGER AS $$
DECLARE
    warehouse_id_item int;
    start_overdue_time timestamp;
    overdue_rent_days_calc int := 0;
    late_penalty_item decimal(10, 2);
BEGIN
    SELECT warehouse_id 
    FROM Items 
    WHERE id = OLD.item_id
    INTO warehouse_id_item;

    IF OLD.overdue = true THEN
        start_overdue_time := CASE  
            WHEN (OLD.end_rent_time < DATE_TRUNC('day', OLD.start_rent_time) + INTERVAL '2 days') OR (EXTRACT(HOUR FROM OLD.end_rent_time) >= 12) THEN
                DATE_TRUNC('day', OLD.start_rent_time) + INTERVAL '2 days'
            ELSE
                DATE_TRUNC('day', OLD.end_rent_time) + INTERVAL '1 day'
        END;

        overdue_rent_days_calc := 1 + GREATEST(CEIL(EXTRACT(EPOCH FROM (NOW() - start_overdue_time)) / 86400));
    END IF;

    SELECT late_penalty 
    FROM Items WHERE 
    id = OLD.item_id
    INTO late_penalty_item;

    INSERT INTO RentHistory(item_id, warehouse_rent_id, customer_id, start_rent_time, end_rent_time, overdue_rent_days, total_payments)
    VALUES (
            OLD.item_id,
            warehouse_id_item,
            OLD.customer_id,
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


-- add new users to the UserWarehouse
CREATE OR REPLACE FUNCTION update_user_warehouse()
RETURNS VOID AS $$
BEGIN
    INSERT INTO UserWarehouse (username, warehouse_id)
    SELECT usename, NULL
    FROM pg_user
    WHERE usename NOT IN (SELECT uw.username FROM UserWarehouse uw) AND usename NOT IN ('postgres', 'register');

    DELETE FROM UserWarehouse
    WHERE username NOT IN (SELECT usename FROM pg_user);
END;
$$ LANGUAGE plpgsql;


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
                        WHEN EXTRACT(HOUR FROM end_rent_time) >= 12 THEN 
                            INTERVAL '1 day 12 hours' 
                        ELSE 
                            INTERVAL '12 hours' 
                    END)
        END
    );
END;
$$ LANGUAGE plpgsql;


-- Add schedule pgagent. execute update overdue in Rent everyday in 12:00
CREATE EXTENSION IF NOT EXISTS pgagent;

DO $$
DECLARE
    jid integer;
    scid integer;
BEGIN
-- Creating a new job
INSERT INTO pgagent.pga_job(
    jobjclid, jobname, jobdesc, jobhostagent, jobenabled
) VALUES (
    1::integer, 'DailyCheckOverdueRent'::text, ''::text, ''::text, true
) RETURNING jobid INTO jid;

-- Steps
-- Inserting a step (jobid: NULL)
INSERT INTO pgagent.pga_jobstep (
    jstjobid, jstname, jstenabled, jstkind,
    jstconnstr, jstdbname, jstonerror,
    jstcode, jstdesc
) VALUES (
    jid, 'CheckAndUpdate'::text, true, 's'::character(1),
    ''::text, 'RentalDB'::name, 'f'::character(1),
    'SELECT public.daily_update_overdue_rent();'::text, ''::text
) ;

-- Schedules
-- Inserting a schedule
INSERT INTO pgagent.pga_schedule(
    jscjobid, jscname, jscdesc, jscenabled,
    jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
) VALUES (
    jid, 'Daily 12:00'::text, ''::text, true,
    NOW()::timestamp with time zone, (NOW() + INTERVAL '1 year')::timestamp with time zone,
    -- Minutes
    '{t,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Hours
    '{f,f,f,f,f,f,f,f,f,f,f,f,t,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Week days
    '{f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Month days
    '{f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[],
    -- Months
    '{f,f,f,f,f,f,f,f,f,f,f,f}'::bool[]::boolean[]
) RETURNING jscid INTO scid;
END
$$;


-- Create roles

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
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE    Rent, Customers                                                                                       TO worker;
GRANT SELECT, INSERT                 ON TABLE    RentHistory                                                                                           TO worker;
GRANT USAGE, SELECT                  ON SEQUENCE rent_id_seq, customers_id_seq, renthistory_id_seq                                                     TO worker;
GRANT SELECT                         ON TABLE    Items, ItemsCategories, Categories, ItemsDiscounts, Discounts, WarehousesOrders, ItemsDecommissioning TO worker;


-- inventory_manager
DO $$
BEGIN
    CREATE ROLE inventory_manager;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role inventory_manager already exists, skipping creation.';
END $$;
 ALTER ROLE inventory_manager WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE    ItemsDecommissioning, WarehousesOrders, ItemsCategories, Categories          TO inventory_manager;
GRANT SELECT, INSERT, UPDATE         ON TABLE    WarehousesOrdersHistory, Items, ItemsServiceHistory                          TO inventory_manager;
GRANT SELECT, INSERT                 ON TABLE    ItemsInfo, ItemsServiceHistoryInfo                                           TO inventory_manager;
GRANT USAGE, SELECT                  ON SEQUENCE itemsdecommissioning_id_seq, warehousesorders_id_seq, 
                                                 warehousesordershistory_id_seq, categories_id_seq, items_id_seq, 
                                                 itemsinfo_id_seq, itemsservicehistory_id_seq, itemsservicehistoryinfo_id_seq TO inventory_manager;
GRANT SELECT                         ON TABLE    UserWarehouse, Warehouses, RentHistory, Rent                                 TO inventory_manager;


-- marketing_specialist
DO $$
BEGIN
    CREATE ROLE marketing_specialist;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role marketing_specialist already exists, skipping creation.';
END $$;
 ALTER ROLE marketing_specialist WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE    ItemsDiscounts, Discounts                                TO marketing_specialist;
GRANT USAGE, SELECT                  ON SEQUENCE discounts_id_seq                                         TO marketing_specialist;
GRANT SELECT                         ON TABLE    Items, ItemsCategories, Categories, ItemsServiceHistory, 
                                                 Warehouses, WarehousesOrders, WarehousesOrdersHistory, 
                                                 ItemsDecommissioning, Rent, RentHistory                  TO marketing_specialist;


-- director
DO $$
BEGIN
    CREATE ROLE director;
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role director already exists, skipping creation.';
END $$;
 ALTER ROLE director WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE    Warehouses, UserWarehouse                                TO director;
GRANT USAGE, SELECT                  ON SEQUENCE warehouses_id_seq, userwarehouse_id_seq                  TO director;
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


-- Insertion test data

-- INSERT Warehouses
INSERT INTO Warehouses VALUES (1, 'Арбор',   '+79167130067', 'arbor@rental.com',   '125315, г. Москва, ул. Усиевича, дом 18');
INSERT INTO Warehouses VALUES (2, 'Флюмен',  '+79162103495', 'flumen@rental.com',  '980371, г. Москва, ул. Брянская, дом 8');
INSERT INTO Warehouses VALUES (3, 'Гелидус', '+79165499144', 'gelidus@rental.com', '980178, г. Москва, ул. Краснопрудная, дом 11');
INSERT INTO Warehouses VALUES (4, 'Монтис',  '+79168251546', 'montis@rental.com',  '983182, г. Санкт-Петербург, пр-кт Испытателей, дом 31');
INSERT INTO Warehouses VALUES (5, 'Сильва',  '+79165946514', 'silva@rental.com',   '420127, Респ. Татарстан, г. Казань, ул. Максимова, дом 2');
SELECT setval('warehouses_id_seq', (SELECT MAX(id) FROM Warehouses));

-- INSERT Items
INSERT INTO Items VALUES (1,  1, 'плиткорез',                            'Для точной резки плитки и керамики.',                    91,  300,  400 );
INSERT INTO Items VALUES (2,  1, 'пневматический гайковерт',             'Для быстрого и эффективного закручивания гаек.',         62,  900,  1300);
INSERT INTO Items VALUES (3,  1, 'лазерный уровень',                     'Для точной установки и выравнивания объектов.',          100, 400,  600 );
INSERT INTO Items VALUES (4,  2, 'тележка с ручным подъемником',         'Для легкого подъема и перемещения грузов.',              85,  1200, 1500);
INSERT INTO Items VALUES (5,  2, 'складской робот',                      'Автоматизированное устройство для перемещения товаров.', 64,  4000, 5500);
INSERT INTO Items VALUES (6,  3, 'кран-балка',                           'Для перемещения тяжелых предметов в пределах склада.',   54,  4000, 5500);
INSERT INTO Items VALUES (7,  2, 'конвейер',                             'Используется для перемещения товаров на складе.',        80,  1500, 2000);
INSERT INTO Items VALUES (8,  1, 'электрический погрузчик',              'Используется для перемещения тяжелых грузов.',           56,  2000, 2500);
INSERT INTO Items VALUES (9,  4, 'сварочный аппарат',                    'Для сварки металлов и других материалов.',               0,   700,  1000);
INSERT INTO Items VALUES (10, 4, 'компрессор',                           'Для подачи сжатого воздуха.',                            10,  700,  1000);
INSERT INTO Items VALUES (11, 5, 'фрезерный станок',                     'Для точной фрезеровки различных материалов.',            77,  2500, 3000);
INSERT INTO Items VALUES (12, 1, 'газовый резак',                        'Для резки металлов и других твердых материалов.',        95,  600,  800 );
INSERT INTO Items VALUES (13, 5, 'дрель-шуруповерт',                     'Для сверления и закручивания шурупов.',                  68,  700,  900 );
INSERT INTO Items VALUES (14, 3, 'плоскогубцы с изолированными ручками', 'Для работы с электрическими проводами и кабелями.',      35,  200,  300 );
INSERT INTO Items VALUES (15, 3, 'бетононасос',                          'Для перекачивания бетона на строительных площадках.',    84,  4000, 5500);
INSERT INTO Items VALUES (16, 3, 'вакуумный упаковщик',                  'Для упаковки продуктов в вакуумной упаковке.',           90,  2000, 2400);
SELECT setval('items_id_seq', (SELECT MAX(id) FROM Items));

-- INSERT Categories
INSERT INTO Categories VALUES (1, 'Инструменты');
INSERT INTO Categories VALUES (2, 'Обработка');
INSERT INTO Categories VALUES (3, 'Электрика');
INSERT INTO Categories VALUES (4, 'Строительная техника');
INSERT INTO Categories VALUES (5, 'Промышленная машина');
INSERT INTO Categories VALUES (6, 'Подъемное оборудование');
INSERT INTO Categories VALUES (7, 'Автоматизация');
INSERT INTO Categories VALUES (8, 'Пневматика');
INSERT INTO Categories VALUES (9, 'Упаковка');
SELECT setval('categories_id_seq', (SELECT MAX(id) FROM Categories));

-- INSERT ItemsCategories
INSERT INTO ItemsCategories VALUES (1, 1);
INSERT INTO ItemsCategories VALUES (1, 2);
INSERT INTO ItemsCategories VALUES (2, 1);
INSERT INTO ItemsCategories VALUES (2, 3);
INSERT INTO ItemsCategories VALUES (3, 1);
INSERT INTO ItemsCategories VALUES (3, 4);
INSERT INTO ItemsCategories VALUES (4, 5);
INSERT INTO ItemsCategories VALUES (4, 6);
INSERT INTO ItemsCategories VALUES (5, 5);
INSERT INTO ItemsCategories VALUES (5, 7);
INSERT INTO ItemsCategories VALUES (6, 5);
INSERT INTO ItemsCategories VALUES (6, 6);
INSERT INTO ItemsCategories VALUES (7, 5);
INSERT INTO ItemsCategories VALUES (7, 7);
INSERT INTO ItemsCategories VALUES (8, 5);
INSERT INTO ItemsCategories VALUES (8, 6);
INSERT INTO ItemsCategories VALUES (9, 1);
INSERT INTO ItemsCategories VALUES (10, 1);
INSERT INTO ItemsCategories VALUES (10, 8);
INSERT INTO ItemsCategories VALUES (11, 5);
INSERT INTO ItemsCategories VALUES (11, 2);
INSERT INTO ItemsCategories VALUES (12, 1);
INSERT INTO ItemsCategories VALUES (12, 2);
INSERT INTO ItemsCategories VALUES (13, 1);
INSERT INTO ItemsCategories VALUES (14, 1);
INSERT INTO ItemsCategories VALUES (15, 5);
INSERT INTO ItemsCategories VALUES (15, 4);
INSERT INTO ItemsCategories VALUES (16, 5);
INSERT INTO ItemsCategories VALUES (16, 9);

-- INSERT Discounts
INSERT INTO Discounts VALUES (1, 'Недельная господдержка промышленного производства', 'По указу №5 президента РФ на промышленное оборудование возлагается скидка 10%', 10, NOW(),                     NOW() + INTERVAL '7 days');
INSERT INTO Discounts VALUES (2, 'Пора накачать колеса!',                             'Давно проверяли давление в шинах? Скидка 5% на аренду компрессора',              5, NOW() - INTERVAL '2 days', NOW() + INTERVAL '1 day');
SELECT setval('discounts_id_seq', (SELECT MAX(id) FROM Discounts));

-- INSERT ItemsDiscounts
INSERT INTO ItemsDiscounts
    SELECT i.id, 1
    FROM Items AS i 
    JOIN ItemsCategories AS ic  
        ON i.id = ic.item_id
    JOIN Categories AS c
        ON ic.category_id = c.id
    WHERE c.category_name = 'Промышленная машина';
INSERT INTO ItemsCategories VALUES (10, 2);

-- INSERT Customers
INSERT INTO Customers VALUES (1, 'Арсений',   'Корнилов', '+7(909)445-14-88', 'arseniy6950@mail.ru',         '980484 г. Москва, ш. Дмитровское, дом 131 к. 2',                                     '4128 355647');
INSERT INTO Customers VALUES (2, 'Лариса',    'Горелова', '+7(924)855-68-37', 'larisa58@mail.ru',            '918820 г. Москва, ул. Тимирязевская, дом 38/25',                                     '4794 949570');
INSERT INTO Customers VALUES (3, 'Иван',      'Аксаков',  '+7(962)409-79-76', 'ivan03071980@mail.ru',        '109147 г. Москва, ул. Марксистская, дом 9',                                          '4459 152953');
INSERT INTO Customers VALUES (4, 'Павел',     'Исаев',    '+7(909)189-17-81', 'pavel62@yandex.ru',           '119021 г. Москва, пр-кт Комсомольский, дом 3',                                       '4338 106639');
INSERT INTO Customers VALUES (5, 'Роман',     'Ельченко', '+7(971)778-40-29', 'roman4159@yandex.ru',         '141011 обл. Московская, г. Мытищи, ул. 4-я Парковая, дом 16',                        '4396 605504');
INSERT INTO Customers VALUES (6, 'Елизавета', 'Мишина',   '+7(936)970-45-53', 'elizaveta3412@yandex.ru',     '919216 обл Московская, г Долгопрудный, ш Старое Дмитровское, дом 15',                '4072 639447');
INSERT INTO Customers VALUES (7, 'Максим',    'Гребнев',  '+7(925)930-73-21', 'max47@rambler.ru',            '143402 обл. Московская, г. Красногорск, проезд Железнодорожный, дом 9',              '4522 205106');
INSERT INTO Customers VALUES (8, 'Дмитрий',   'Коршиков', '+7(908)329-79-43', 'dmitriy.korshikov@gmail.com', '980243 г. Москва, ул. Перовская, дом 8 к. 1',                                        '4041 379819');
INSERT INTO Customers VALUES (9, 'Григорий',  'Кубланов', '+7(908)302-45-12', 'grigoriy_kub@gmail.com',      '919935 обл. Московская, г. Балашиха, мкр. Железнодорожный, ул. Маяковского, дом 25', '4396 255125');
SELECT setval('customers_id_seq', (SELECT MAX(id) FROM Customers));

-- INSERT ItemsDecommissioning
INSERT INTO ItemsDecommissioning VALUES (1, 9, 'Сгорели блок питания и плата управления. Восстановление не рентабельно.');
SELECT setval('itemsdecommissioning_id_seq', (SELECT MAX(id) FROM ItemsDecommissioning));

-- INSERT ItemsServiceHistory
INSERT INTO ItemsServiceHistory(item_id, new_quality, change_reason) VALUES (2, 60, 'Треснул корпус');
SELECT setval('itemsservicehistory_id_seq', (SELECT MAX(id) FROM ItemsServiceHistory));

-- INSERT WarehousesOrdersHistory
ALTER SEQUENCE public.warehousesordershistory_id_seq RESTART WITH 5;
INSERT INTO WarehousesOrdersHistory VALUES (1, 5,  3, 2, NOW() - INTERVAL '7 days',  NOW() - INTERVAL '3 days',  NULL);
INSERT INTO WarehousesOrdersHistory VALUES (2, 10, 1, 4, NOW() - INTERVAL '30 days', NOW() - INTERVAL '26 days', NULL);
INSERT INTO WarehousesOrdersHistory VALUES (3, 9,  1, 4, NOW() - INTERVAL '12 days', NOW() - INTERVAL '11 days', NULL);
INSERT INTO WarehousesOrdersHistory VALUES (4, 13, 3, 5, NOW() - INTERVAL '15 days', NOW() - INTERVAL '6 days',  NULL);
SELECT setval('warehousesordershistory_id_seq', (SELECT MAX(id) FROM WarehousesOrdersHistory));

-- INSERT WarehousesOrders
ALTER SEQUENCE public.warehousesorders_id_seq RESTART WITH 5;
INSERT INTO WarehousesOrders(item_id, destination_warehouse_id) VALUES (7, 4);

COMMIT;