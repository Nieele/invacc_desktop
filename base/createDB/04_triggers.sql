BEGIN;

-- Adding user information when creating an account (insert customer auth)
CREATE TRIGGER trg_add_customer_info
AFTER INSERT ON CustomersAuth
FOR EACH ROW
EXECUTE FUNCTION add_customer_info();

-- Set old_quality from item before insert to ItemsServiceHistory
CREATE TRIGGER trg_add_items_service_history
BEFORE INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION set_actual_old_quality();

-- Update quality in Items after insert to ItemsServiceHistory
CREATE TRIGGER trg_update_quality_items
AFTER INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION update_quality_items();

-- Validation function before creating a warehouse transfer order
CREATE TRIGGER trg_prevent_add_order
BEFORE INSERT ON WarehousesOrders
FOR EACH ROW
EXECUTE FUNCTION prevent_add_order();

-- Prevent updates to warehouse transfer orders
CREATE TRIGGER trg_prevent_update_status_warehouses_order
BEFORE UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION prevent_update_status_warehouses_order();

-- Update warehouse transfer order status
CREATE TRIGGER trg_update_warehouses_order_status
AFTER UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION update_warehouses_order_status();

-- Validate item before decommissioning
CREATE TRIGGER trg_validate_item_decommissioning
BEFORE INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION validate_item_decommissioning();

-- Update item status to inactive when decommissioned
CREATE TRIGGER trg_set_item_inactive_on_decommission
AFTER INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION set_item_inactive_on_decommission();

-- Validate item availability before creating a rent
CREATE TRIGGER trg_prevent_rent
BEFORE INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION prevent_rent();

-- Process rent status updates
CREATE TRIGGER trg_process_rent_status_update
AFTER UPDATE OF delivery_status_id ON Rent
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION process_rent_status_update();

-- Insert rental record into history
CREATE TRIGGER trg_add_rent_history
BEFORE DELETE ON Rent
FOR EACH ROW
EXECUTE FUNCTION add_rent_history();

COMMIT;