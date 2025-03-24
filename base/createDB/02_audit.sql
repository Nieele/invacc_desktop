---------------------------------------------------------------------
-- Audit Logging System
---------------------------------------------------------------------

BEGIN;

-- Core audit table
CREATE TABLE IF NOT EXISTS logged_actions (
    id              bigserial   PRIMARY KEY,
    table_schema    text        NOT NULL,
    table_name      text        NOT NULL,
    operation       text        NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    changed_by      text        NOT NULL,
    changed_at      timestamp   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    old_data        jsonb,
    new_data        jsonb
);

-- Generic audit function
CREATE OR REPLACE FUNCTION audit_log() RETURNS trigger AS $$
BEGIN
    INSERT INTO logged_actions(
        table_schema, 
        table_name, 
        operation, 
        changed_by, 
        old_data, 
        new_data
    )
    VALUES (
        TG_TABLE_SCHEMA,
        TG_TABLE_NAME,
        TG_OP,
        current_user,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('UPDATE', 'INSERT') THEN to_jsonb(NEW) ELSE NULL END
    );
    
    RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
END;
$$ LANGUAGE plpgsql;

-- Function to create audit trigger for a table
CREATE OR REPLACE FUNCTION create_audit_trigger(table_name text) RETURNS void AS $$
BEGIN
    EXECUTE format('
        CREATE TRIGGER audit_trigger
        AFTER INSERT OR UPDATE OR DELETE ON %I
        FOR EACH ROW EXECUTE FUNCTION audit_log()',
        table_name
    );
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers to tables
SELECT create_audit_trigger('items');
SELECT create_audit_trigger('warehousesorders');
SELECT create_audit_trigger('discounts');
SELECT create_audit_trigger('itemsdiscounts');
SELECT create_audit_trigger('itemsservicehistory');
SELECT create_audit_trigger('itemsdecommissioning');

COMMIT;