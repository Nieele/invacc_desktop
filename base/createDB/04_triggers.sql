BEGIN;

CREATE TRIGGER trg_add_customer_info
AFTER INSERT ON CustomersAuth
FOR EACH ROW
EXECUTE FUNCTION add_customer_info();

CREATE TRIGGER trg_add_items_service_history
BEFORE INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION set_actual_old_quality();

CREATE TRIGGER trg_update_quality_items
AFTER INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION update_quality_items();

CREATE TRIGGER trg_prevent_add_order
BEFORE INSERT ON WarehousesOrders
FOR EACH ROW
EXECUTE FUNCTION prevent_add_order();

CREATE TRIGGER trg_prevent_update_status_warehouses_order
BEFORE UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION prevent_update_status_warehouses_order();

CREATE TRIGGER trg_update_warehouses_order_status
AFTER UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION update_warehouses_order_status();

CREATE TRIGGER trg_prevent_decommissioning
BEFORE INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION prevent_decommissioning();

CREATE TRIGGER trg_update_decommission_item
AFTER INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION update_decommission_item();

CREATE TRIGGER trg_prevent_rent
BEFORE INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION prevent_rent();

CREATE TRIGGER trg_process_update_devilery_status_rent
AFTER UPDATE OF delivery_status_id ON Rent
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION process_update_devilery_status_rent();

CREATE TRIGGER trg_add_rent_history
BEFORE DELETE ON Rent
FOR EACH ROW
EXECUTE FUNCTION add_rent_history();

COMMIT;