---------------------------------------------------------------------
-- Tables
---------------------------------------------------------------------

BEGIN;

--------------------------------------------------
-- Internal employee roles
--------------------------------------------------

CREATE TABLE IF NOT EXISTS EmployeesRoles (
    role_id     serial      PRIMARY KEY,
    role        varchar(50) NOT NULL UNIQUE
);

INSERT INTO EmployeesRoles(role_id, role) 
    VALUES  (1, 'admin'),
            (2, 'unkown'),
            (3, 'worker'),
            (4, 'inventory_manager');


CREATE TABLE IF NOT EXISTS Employees (
    id              serial          PRIMARY KEY,
    username        varchar(50)     NOT NULL UNIQUE,
    full_name       varchar(100)    NOT NULL,
    warehouse_id    int             NOT NULL,
    role_id         int             NOT NULL DEFAULT 2, -- 2 corresponds to 'unknown'
    active          boolean         NOT NULL DEFAULT true,
    CONSTRAINT fk_EmployeesRole FOREIGN KEY (role_id) REFERENCES EmployeesRoles (role_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


--------------------------------------------------
-- Storage tables
--------------------------------------------------


CREATE TABLE IF NOT EXISTS Warehouses (
    id       serial        PRIMARY KEY,
    name     varchar(50)   NOT NULL  UNIQUE,
    phone    varchar(15)   NOT NULL  UNIQUE,
    email    varchar(50)   NOT NULL  UNIQUE,
    address  varchar(100)  NOT NULL  UNIQUE,
    active   boolean       NOT NULL  DEFAULT true
);
CREATE INDEX idx_warehouses_active ON Warehouses(active);


CREATE TABLE IF NOT EXISTS Items (
    id               serial         PRIMARY KEY,
    warehouse_id     int            NOT NULL,
    name             varchar(50)    NOT NULL,
    description      text           NULL,
    extra_attributes jsonb          NULL,
    quality          int            NOT NULL  DEFAULT 100  CHECK (quality >= 0 AND quality <= 100),
    price            decimal(10,2)  NOT NULL               CHECK (price > 0),
    late_penalty     decimal(10,2)  NOT NULL               CHECK (late_penalty > 0),
    deposit          decimal(10,2)  NOT NULL               CHECK (deposit >= 0),
    active           boolean        NOT NULL  DEFAULT TRUE,
    img_url          text           NULL      DEFAULT 'not_found.webp',
    CONSTRAINT fk_items_warehouses FOREIGN KEY (warehouse_id) REFERENCES Warehouses (id) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_items_warehouse ON Items(warehouse_id);


--------------------------------------------------
-- Delivery tables
--------------------------------------------------


CREATE TABLE IF NOT EXISTS DeliveryStatus (
    id serial PRIMARY KEY,
    status_code text NOT NULL UNIQUE,
    description text NOT NULL
);

INSERT INTO DeliveryStatus (id, status_code, description)
VALUES 
    (1, 'in stock',  'Прибыл на склад'),
    (2, 'request',   'Запрос на доставку'),
    (3, 'cancelled', 'Отменен'),
    (4, 'shipped',   'Отправлено'),
    (5, 'received',  'Получено'),
    (6, 'returning', 'Возврат на склад')
ON CONFLICT (status_code) DO NOTHING;


CREATE TABLE IF NOT EXISTS WarehousesOrders (
    id                       serial     PRIMARY KEY,
    item_id                  int        NOT NULL,
    source_warehouse_id      int        NULL,
    destination_warehouse_id int        NOT NULL,
    sending_time             timestamp  NULL,
    receiving_time           timestamp  NULL,
    delivery_status_id       int        NOT NULL DEFAULT 2, -- 2 corresponds to 'request'
    CONSTRAINT fk_wo_items          FOREIGN KEY (item_id)                   REFERENCES Items (id)           ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_wo_source         FOREIGN KEY (source_warehouse_id)       REFERENCES Warehouses (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_wo_destination    FOREIGN KEY (destination_warehouse_id)  REFERENCES Warehouses (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_wo_status         FOREIGN KEY (delivery_status_id)        REFERENCES DeliveryStatus (id)  ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX idx_wo_ ON WarehousesOrders(delivery_status_id);


--------------------------------------------------
-- Item maintenance tables
--------------------------------------------------


CREATE TABLE IF NOT EXISTS ItemServiceHistory (
    id             serial  PRIMARY KEY,
    item_id        int     NOT NULL,
    old_quality    int     NULL                 CHECK (old_quality >= 0 AND old_quality <= 100),
    new_quality    int     NOT NULL             CHECK (new_quality >= 0 AND new_quality <= 100),
    change_reason  text    NOT NULL,
    CONSTRAINT fk_itemservice_items FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS ItemDecommissioning (
    id       serial  PRIMARY KEY,
    item_id  int     NOT NULL  UNIQUE,
    reason   text    NOT NULL,
    CONSTRAINT fk_itemdecommissioning_items FOREIGN KEY (item_id) REFERENCES Items (id) ON DELETE CASCADE ON UPDATE CASCADE
);


--------------------------------------------------
-- Categories tables
--------------------------------------------------


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
CREATE INDEX idx_itemscategories ON items_categories (category_id, item_id);


--------------------------------------------------
-- Promo tables
--------------------------------------------------


CREATE TABLE Promocodes (
    id              serial       PRIMARY KEY,
    code            varchar(50)  NOT NULL  UNIQUE,
    description     text         NULL,
    percent         int          NOT NULL                        CHECK (percent > 0 AND percent < 100),
    start_date      date         NOT NULL  DEFAULT CURRENT_DATE  CHECK (start_date >= CURRENT_DATE),
    end_date        date         NOT NULL                        CHECK (end_date > CURRENT_DATE),
    number_of_uses  int          NOT NULL  DEFAULT 0
);


--------------------------------------------------
-- Customers tables
--------------------------------------------------


CREATE TABLE IF NOT EXISTS CustomersAuth (
    id          serial          PRIMARY KEY,
    email       varchar(50)     NOT NULL UNIQUE,
    password    varchar(60)     NOT NULL -- bcrypt hash
);

-- TODO: table session with jwt token, ip, device

CREATE TABLE IF NOT EXISTS CustomersInfo (
    id                  serial        PRIMARY KEY,
    firstname           varchar(50)   NULL,
    lastname            varchar(50)   NULL,
    phone               varchar(30)   NULL,
    passport            varchar(30)   NULL,
    phone_verified      boolean       NOT NULL  DEFAULT false,
    email_verified      boolean       NOT NULL  DEFAULT false,
    passport_verified   boolean       NOT NULL  DEFAULT false,
    CONSTRAINT fk_customersinfo_customersauth FOREIGN KEY (id) REFERENCES CustomersAuth (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS Cart (
    id          serial PRIMARY KEY,
    customer_id int NOT NULL,
    item_id     int NOT NULL,
    CONSTRAINT fk_cart_customers FOREIGN KEY (customer_id) REFERENCES CustomersInfo (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cart_items     FOREIGN KEY (item_id)     REFERENCES Items (id)         ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE(customer_id, item_id)
);
CREATE INDEX idx_cart_customer ON Cart(customer_id);


--------------------------------------------------
-- Rent tables
--------------------------------------------------


CREATE TABLE IF NOT EXISTS Rent (
    id                  serial          PRIMARY KEY,
    item_id             int             NOT NULL  UNIQUE,
    customer_id         int             NOT NULL,
    promocode_id        int             NULL,
    address             varchar(255)    NOT NULL,
    delivery_status_id  int             NOT NULL  DEFAULT 2, -- 2 corresponds to 'request'
    number_of_days      int             NOT NULL,
    start_rent_time     timestamp       NULL,
    end_rent_time       timestamp       NULL,  
    total_payments      decimal(10,2)   NULL,
    overdue             boolean         NOT NULL  DEFAULT false,
    CONSTRAINT fk_rent_items            FOREIGN KEY (item_id)               REFERENCES Items (id)           ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rent_customers        FOREIGN KEY (customer_id)           REFERENCES CustomersInfo (id)   ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rent_deliverystatus   FOREIGN KEY (delivery_status_id)    REFERENCES DeliveryStatus (id)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rent_promocode        FOREIGN KEY (promocode_id)          REFERENCES Promocodes (id)      ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (start_rent_time < end_rent_time)
);
CREATE INDEX idx_rent_delivery ON Rent(delivery_status_id);


CREATE TABLE IF NOT EXISTS RentHistory (
    id                 serial         PRIMARY KEY,
    item_id            int            NOT NULL,
    warehouse_rent_id  int            NOT NULL,
    customer_id        int            NOT NULL,
    address            varchar(255)   NOT NULL,
    delivery_status_id int            NOT NULL,
    start_rent_time    timestamp      NULL,
    end_rent_time      timestamp      NULL,
    overdue_rent_days  int            NOT NULL,
    total_payments     decimal(10,2)  NOT NULL,
    CONSTRAINT fk_renthistory_items         FOREIGN KEY (item_id)           REFERENCES Items (id)       ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_renthistory_warehouses    FOREIGN KEY (warehouse_rent_id) REFERENCES Warehouses (id)  ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_renthistory_customers     FOREIGN KEY (customer_id)       REFERENCES CustomersInfo (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (start_rent_time < end_rent_time)
);

COMMIT;