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
    id               serial     PRIMARY KEY,
    item_id          int        NOT NULL,
    customer_id      int        NOT NULL,
    start_rent_time  timestamp  NOT NULL  DEFAULT NOW(),
    end_rent_time    timestamp  NOT NULL,
    overdue          boolean              DEFAULT false,
    FOREIGN KEY (item_id)     REFERENCES Items (id)     ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers (id) ON DELETE RESTRICT ON UPDATE CASCADE
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