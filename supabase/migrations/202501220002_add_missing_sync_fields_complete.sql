-- Add ALL missing sync metadata fields to ALL tables
-- This migration ensures EVERY table has deleted_at, device_id, and session_status fields

-- ============================================================================
-- DECLUTTER_ITEMS: Add deleted_at and device_id
-- ============================================================================
ALTER TABLE IF EXISTS public.declutter_items
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

CREATE INDEX IF NOT EXISTS declutter_items_deleted_at_idx ON public.declutter_items(deleted_at);

-- ============================================================================
-- RESELL_ITEMS: Add deleted_at and device_id
-- ============================================================================
ALTER TABLE IF EXISTS public.resell_items
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

CREATE INDEX IF NOT EXISTS resell_items_deleted_at_idx ON public.resell_items(deleted_at);

-- ============================================================================
-- DEEP_CLEANING_SESSIONS: Add deleted_at, device_id, and session_status
-- ============================================================================
ALTER TABLE IF EXISTS public.deep_cleaning_sessions
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT,
  ADD COLUMN IF NOT EXISTS session_status TEXT CHECK (
    session_status IN ('ongoing', 'paused', 'completed', 'canceled')
  );

CREATE INDEX IF NOT EXISTS deep_cleaning_sessions_deleted_at_idx ON public.deep_cleaning_sessions(deleted_at);

-- Set default session_status for existing rows
UPDATE public.deep_cleaning_sessions
SET session_status = 'completed'
WHERE session_status IS NULL;

-- ============================================================================
-- MEMORIES: Add deleted_at and device_id
-- ============================================================================
ALTER TABLE IF EXISTS public.memories
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

CREATE INDEX IF NOT EXISTS memories_deleted_at_idx ON public.memories(deleted_at);

-- ============================================================================
-- PLANNED_SESSIONS: Add deleted_at and device_id
-- ============================================================================
ALTER TABLE IF EXISTS public.planned_sessions
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

CREATE INDEX IF NOT EXISTS planned_sessions_deleted_at_idx ON public.planned_sessions(deleted_at);
