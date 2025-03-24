---------------------------------------------------------------------
-- Views
---------------------------------------------------------------------

BEGIN;

--------------------------------------------------
-- Monthly Rent Analytics Materialized View
--------------------------------------------------

CREATE MATERIALIZED VIEW monthly_rent_summary 
WITH (fillfactor = 90)  -- Optimize storage and updates
AS
WITH valid_rents AS (
    SELECT end_rent_time,
           total_payments
    FROM RentHistory
    WHERE delivery_status_id != 3  -- Exclude cancelled rentals
)
SELECT 
    date_trunc('month', end_rent_time) AS month,
    COUNT(*) AS total_rents,
    COALESCE(SUM(total_payments), 0) AS revenue
FROM valid_rents
GROUP BY month;

-- Create index for better query performance
CREATE INDEX idx_monthly_rent_summary_month 
ON monthly_rent_summary (month);

-- Refresh command (to be scheduled with pgAgent)
COMMENT ON MATERIALIZED VIEW monthly_rent_summary IS 
'Monthly rental statistics excluding cancelled orders. Refresh scheduled monthly.';

COMMIT;