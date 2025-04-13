---------------------------------------------------------------------
-- pg_cron schedules
---------------------------------------------------------------------

-- update overdue rents
SELECT cron.schedule(
    'daily_update_overdue_rent_job', 
    '0 12 * * *',                       -- every day at 12:00 PM
    'SELECT daily_update_overdue_rent()'
);

-- Update monthly_rent_summary (view)
SELECT cron.schedule(
  'refresh_monthly_rent_summary',
  '0 1 1 * *',                          -- every month at 1:00 AM
  'REFRESH MATERIALIZED VIEW monthly_rent_summary'
);
