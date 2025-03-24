BEGIN;

<<<<<<< HEAD
<<<<<<< HEAD
-- Adding user information when creating an account (insert customer auth)
=======
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Adding user information when creating an account (insert customer auth)
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_add_customer_info
AFTER INSERT ON CustomersAuth
FOR EACH ROW
EXECUTE FUNCTION add_customer_info();

<<<<<<< HEAD
<<<<<<< HEAD
-- Set old_quality from item before insert to ItemsServiceHistory
=======
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Set old_quality from item before insert to ItemsServiceHistory
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_add_items_service_history
BEFORE INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION set_actual_old_quality();

<<<<<<< HEAD
<<<<<<< HEAD
-- Update quality in Items after insert to ItemsServiceHistory
=======
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Update quality in Items after insert to ItemsServiceHistory
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_update_quality_items
AFTER INSERT ON ItemsServiceHistory
FOR EACH ROW
EXECUTE FUNCTION update_quality_items();

<<<<<<< HEAD
<<<<<<< HEAD
-- Validation function before creating a warehouse transfer order
=======
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Validation function before creating a warehouse transfer order
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_prevent_add_order
BEFORE INSERT ON WarehousesOrders
FOR EACH ROW
EXECUTE FUNCTION prevent_add_order();

<<<<<<< HEAD
<<<<<<< HEAD
-- Prevent updates to warehouse transfer orders
=======
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Prevent updates to warehouse transfer orders
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_prevent_update_status_warehouses_order
BEFORE UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION prevent_update_status_warehouses_order();

<<<<<<< HEAD
<<<<<<< HEAD
-- Update warehouse transfer order status
=======
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Update warehouse transfer order status
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_update_warehouses_order_status
AFTER UPDATE OF delivery_status_id
ON WarehousesOrders
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION update_warehouses_order_status();

<<<<<<< HEAD
<<<<<<< HEAD
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
=======
CREATE TRIGGER trg_prevent_decommissioning
=======
-- Validate item before decommissioning
CREATE TRIGGER trg_validate_item_decommissioning
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
BEFORE INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION validate_item_decommissioning();

-- Update item status to inactive when decommissioned
CREATE TRIGGER trg_set_item_inactive_on_decommission
AFTER INSERT ON ItemsDecommissioning
FOR EACH ROW
EXECUTE FUNCTION set_item_inactive_on_decommission();

<<<<<<< HEAD
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Validate item availability before creating a rent
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_prevent_rent
BEFORE INSERT ON Rent
FOR EACH ROW
EXECUTE FUNCTION prevent_rent();

<<<<<<< HEAD
<<<<<<< HEAD
-- Process rent status updates
CREATE TRIGGER trg_process_rent_status_update
AFTER UPDATE OF delivery_status_id ON Rent
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION process_rent_status_update();

-- Insert rental record into history
=======
CREATE TRIGGER trg_process_update_devilery_status_rent
=======
-- Process rent status updates
CREATE TRIGGER trg_process_rent_status_update
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
AFTER UPDATE OF delivery_status_id ON Rent
FOR EACH ROW
WHEN (OLD.delivery_status_id != NEW.delivery_status_id)
EXECUTE FUNCTION process_rent_status_update();

<<<<<<< HEAD
>>>>>>> 062183b (refactor(sql): add create files by types operation)
=======
-- Insert rental record into history
>>>>>>> 5ae6e06 (refactor(sql): optimize, add comments, structuring functions and triggers)
CREATE TRIGGER trg_add_rent_history
BEFORE DELETE ON Rent
FOR EACH ROW
EXECUTE FUNCTION add_rent_history();

COMMIT;