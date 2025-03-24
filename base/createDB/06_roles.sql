BEGIN;

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
SELECT create_role_if_not_exists('unknown');
SELECT create_role_if_not_exists('worker');
SELECT create_role_if_not_exists('inventory_manager');
SELECT create_role_if_not_exists('marketing_specialist');
SELECT create_role_if_not_exists('director');
SELECT create_role_if_not_exists('moderator');
SELECT create_role_if_not_exists('admin');

-- Base role configurations
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'root';
ALTER ROLE register WITH NOSUPERUSER NOINHERIT CREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'password';
ALTER ROLE unknown WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;

-- Worker role configuration
DO $$
BEGIN
    ALTER ROLE worker WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    
    -- Worker permissions
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Rent, CustomersInfo TO worker;
    GRANT SELECT, INSERT ON TABLE RentHistory TO worker;
    GRANT USAGE, SELECT ON SEQUENCE rent_id_seq, customersinfo_id_seq, renthistory_id_seq TO worker;
    GRANT SELECT ON TABLE Items, ItemsCategories, Categories, ItemsDiscounts, Discounts, 
                          WarehousesOrders, ItemsDecommissioning TO worker;
END $$;

-- Inventory Manager role configuration
DO $$
BEGIN
    ALTER ROLE inventory_manager WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    
    -- Inventory Manager permissions
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ItemsDecommissioning, WarehousesOrders, 
                                              ItemsCategories, Categories TO inventory_manager;
    GRANT SELECT, INSERT, UPDATE ON TABLE WarehousesOrders, Items, ItemsServiceHistory TO inventory_manager;
    GRANT USAGE, SELECT ON SEQUENCE itemsdecommissioning_id_seq, warehousesorders_id_seq, 
                                    categories_id_seq, items_id_seq, itemsservicehistory_id_seq TO inventory_manager;
    GRANT SELECT ON TABLE Employees, Employees_roles, Warehouses, RentHistory, Rent TO inventory_manager;
END $$;

-- Marketing Specialist role configuration
DO $$
BEGIN
    ALTER ROLE marketing_specialist WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    
    -- Marketing Specialist permissions
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE ItemsDiscounts, Discounts TO marketing_specialist;
    GRANT USAGE, SELECT ON SEQUENCE discounts_id_seq TO marketing_specialist;
    GRANT SELECT ON TABLE Items, ItemsCategories, Categories, ItemsServiceHistory, Warehouses, 
                          WarehousesOrders, ItemsDecommissioning, Rent, RentHistory TO marketing_specialist;
END $$;

-- Director role configuration
DO $$
BEGIN
    ALTER ROLE director WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    
    -- Director permissions
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE Warehouses, Employees TO director;
    GRANT USAGE, SELECT ON SEQUENCE warehouses_id_seq, employees_id_seq TO director;
    GRANT SELECT ON ALL TABLES IN SCHEMA public TO director;
END $$;

-- Moderator role configuration
DO $$
BEGIN
    ALTER ROLE moderator WITH NOSUPERUSER INHERIT CREATEROLE NOCREATEDB NOLOGIN NOREPLICATION NOBYPASSRLS;
    GRANT unknown, worker, inventory_manager, marketing_specialist TO moderator WITH ADMIN OPTION;
END $$;

-- Admin role configuration
DO $$
BEGIN
    ALTER ROLE admin WITH SUPERUSER CREATEDB CREATEROLE REPLICATION BYPASSRLS NOLOGIN;
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;
    GRANT ALL PRIVILEGES ON SCHEMA public TO admin;
END $$;

COMMIT;