-- ============================================================================
-- Soft Delete Cleanup System
-- ============================================================================
-- This migration creates a system to automatically clean up soft-deleted
-- records after 30 days. This helps with:
-- 1. Privacy compliance (GDPR/CCPA)
-- 2. Database performance
-- 3. Storage cost management
-- ============================================================================

-- Enable pg_cron extension for scheduled tasks (if not already enabled)
-- Note: This may require superuser privileges. If it fails, enable it manually
-- in Supabase Dashboard > Database > Extensions
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- ============================================================================
-- Function: clean_soft_deleted_records
-- ============================================================================
-- Permanently deletes records that have been soft-deleted for more than 30 days
-- This affects all main tables: memories, items, sessions, etc.
-- ============================================================================

CREATE OR REPLACE FUNCTION clean_soft_deleted_records()
RETURNS TABLE (
  table_name TEXT,
  deleted_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER -- Run with function owner's privileges
AS $$
DECLARE
  cutoff_date TIMESTAMP;
  memories_deleted INTEGER;
  items_deleted INTEGER;
  sessions_deleted INTEGER;
  resell_items_deleted INTEGER;
  planned_sessions_deleted INTEGER;
BEGIN
  -- Calculate cutoff date (30 days ago)
  cutoff_date := NOW() - INTERVAL '30 days';

  RAISE NOTICE 'Starting soft-delete cleanup for records older than %', cutoff_date;

  -- Clean memories table
  DELETE FROM public.memories
  WHERE deleted_at IS NOT NULL
    AND deleted_at < cutoff_date;
  GET DIAGNOSTICS memories_deleted = ROW_COUNT;
  RAISE NOTICE 'Deleted % memories', memories_deleted;

  -- Clean declutter_items table
  DELETE FROM public.declutter_items
  WHERE deleted_at IS NOT NULL
    AND deleted_at < cutoff_date;
  GET DIAGNOSTICS items_deleted = ROW_COUNT;
  RAISE NOTICE 'Deleted % declutter items', items_deleted;

  -- Clean deep_cleaning_sessions table
  DELETE FROM public.deep_cleaning_sessions
  WHERE deleted_at IS NOT NULL
    AND deleted_at < cutoff_date;
  GET DIAGNOSTICS sessions_deleted = ROW_COUNT;
  RAISE NOTICE 'Deleted % deep cleaning sessions', sessions_deleted;

  -- Clean resell_items table
  DELETE FROM public.resell_items
  WHERE deleted_at IS NOT NULL
    AND deleted_at < cutoff_date;
  GET DIAGNOSTICS resell_items_deleted = ROW_COUNT;
  RAISE NOTICE 'Deleted % resell items', resell_items_deleted;

  -- Clean planned_sessions table
  DELETE FROM public.planned_sessions
  WHERE deleted_at IS NOT NULL
    AND deleted_at < cutoff_date;
  GET DIAGNOSTICS planned_sessions_deleted = ROW_COUNT;
  RAISE NOTICE 'Deleted % planned sessions', planned_sessions_deleted;

  -- Return summary
  RETURN QUERY
  SELECT 'memories'::TEXT, memories_deleted
  UNION ALL
  SELECT 'declutter_items'::TEXT, items_deleted
  UNION ALL
  SELECT 'deep_cleaning_sessions'::TEXT, sessions_deleted
  UNION ALL
  SELECT 'resell_items'::TEXT, resell_items_deleted
  UNION ALL
  SELECT 'planned_sessions'::TEXT, planned_sessions_deleted;

  RAISE NOTICE 'Cleanup completed successfully';
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION clean_soft_deleted_records() IS
'Permanently deletes soft-deleted records older than 30 days from all tables. Returns count of deleted records per table.';

-- ============================================================================
-- Schedule: Run cleanup daily at 2 AM UTC
-- ============================================================================
-- This uses pg_cron to schedule the cleanup function
-- Note: Supabase free tier may have limitations on pg_cron
-- ============================================================================

-- Remove any existing schedule with the same name
SELECT cron.unschedule('clean-soft-deleted-records')
WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'clean-soft-deleted-records'
);

-- Schedule the cleanup to run daily at 2 AM UTC
SELECT cron.schedule(
  'clean-soft-deleted-records',           -- Job name
  '0 2 * * *',                            -- Cron expression: Daily at 2 AM UTC
  $$SELECT * FROM clean_soft_deleted_records()$$  -- SQL to execute
);

-- ============================================================================
-- Manual Testing
-- ============================================================================
-- To test the cleanup function manually, run:
--   SELECT * FROM clean_soft_deleted_records();
--
-- To check scheduled jobs:
--   SELECT * FROM cron.job;
--
-- To view job run history:
--   SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
--
-- To disable the scheduled job:
--   SELECT cron.unschedule('clean-soft-deleted-records');
-- ============================================================================
