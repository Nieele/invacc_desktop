---------------------------------------------------------------------
-- Roles
---------------------------------------------------------------------

BEGIN;

--------------------------------------------------
-- Create roles
--------------------------------------------------

-- Function to create role if not exists
CREATE OR REPLACE FUNCTION create_role_if_not_exists(role_name TEXT) RETURNS VOID AS
$$
BEGIN
    EXECUTE format('CREATE ROLE %I', role_name);
EXCEPTION
    WHEN duplicate_object THEN
        RAISE NOTICE 'Role % already exists, skipping creation.', role_name;
END;
$$ LANGUAGE plpgsql;

-- Create all roles
SELECT create_role_if_not_exists('postgres');
SELECT create_role_if_not_exists('register');
SELECT create_role_if_not_exists('admin');
SELECT create_role_if_not_exists('unknown');
SELECT create_role_if_not_exists('worker');
SELECT create_role_if_not_exists('inventory_manager');


--------------------------------------------------
-- Role configurations
--------------------------------------------------


-- Base role configurations
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'root';
ALTER ROLE register WITH NOSUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'password';
ALTER ROLE unknown WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;

-- Admin role configuration
DO $$
BEGIN
    ALTER ROLE admin WITH SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS NOLOGIN;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
    GRANT ALL PRIVILEGES ON SCHEMA public TO admin;
END $$;

-- Worker role configuration
DO $$
BEGIN
    ALTER ROLE worker WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    
    -- Worker permissions
    GRANT SELECT, UPDATE, DELETE ON TABLE Rent                                      TO worker;
    GRANT SELECT, UPDATE         ON TABLE CustomersInfo                             TO worker;
    GRANT SELECT, INSERT         ON TABLE RentHistory                               TO worker;
    GRANT SELECT                 ON TABLE CustomersAuth, DeliveryStatus, Warehouses,
        WarehousesOrders, Employees, Employees_roles, ItemsDecommissioning          TO worker;

    GRANT USAGE, SELECT ON SEQUENCE renthistory_id_seq TO worker;
END $$;

-- Inventory Manager role configuration
DO $$
BEGIN
    ALTER ROLE inventory_manager WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    
    -- Inventory Manager permissions
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ItemsDecommissioning                                               TO inventory_manager;
    GRANT SELECT, INSERT, UPDATE         ON TABLE Items, ItemsDecommissioning, ItemsServiceHistory, WarehousesOrders TO inventory_manager;
    GRANT SELECT, INSERT, UPDATE         ON TABLE Categories, ItemsCategories                                        TO inventory_manager;
    GRANT SELECT                         ON TABLE Warehouses, RentHistory, Employees, Employees_roles                TO inventory_manager;

    GRANT USAGE, SELECT ON SEQUENCE itemsdecommissioning_id_seq, items_id_seq, 
        itemsservicehistory_id_seq, warehousesorders_id_seq, categories_id_seq TO inventory_manager;
END $$;

COMMIT;