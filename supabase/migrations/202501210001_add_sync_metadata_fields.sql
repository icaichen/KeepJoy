-- Add sync metadata fields for multi-device sync support
-- Phase 7: Local-First Architecture Enhancement

-- Add deleted_at and device_id to memories table
ALTER TABLE IF EXISTS public.memories
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

-- Add deleted_at and device_id to declutter_items table
ALTER TABLE IF EXISTS public.declutter_items
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

-- Add deleted_at and device_id to resell_items table
ALTER TABLE IF EXISTS public.resell_items
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

-- Add deleted_at, device_id, and session_status to deep_cleaning_sessions table
ALTER TABLE IF EXISTS public.deep_cleaning_sessions
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT,
  ADD COLUMN IF NOT EXISTS session_status TEXT DEFAULT 'completed';

-- Add constraint for session_status
ALTER TABLE IF EXISTS public.deep_cleaning_sessions
  DROP CONSTRAINT IF EXISTS deep_cleaning_sessions_session_status_check;

ALTER TABLE IF EXISTS public.deep_cleaning_sessions
  ADD CONSTRAINT deep_cleaning_sessions_session_status_check
  CHECK (session_status IN ('ongoing', 'paused', 'completed', 'canceled'));

-- Add deleted_at and device_id to planned_sessions table
ALTER TABLE IF EXISTS public.planned_sessions
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS device_id TEXT;

-- Add indexes for better query performance on soft-deleted items
CREATE INDEX IF NOT EXISTS memories_deleted_at_idx ON public.memories(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS declutter_items_deleted_at_idx ON public.declutter_items(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS resell_items_deleted_at_idx ON public.resell_items(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS deep_cleaning_sessions_deleted_at_idx ON public.deep_cleaning_sessions(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS planned_sessions_deleted_at_idx ON public.planned_sessions(deleted_at) WHERE deleted_at IS NULL;

-- Add indexes on device_id for conflict resolution tracking
CREATE INDEX IF NOT EXISTS memories_device_id_idx ON public.memories(device_id);
CREATE INDEX IF NOT EXISTS declutter_items_device_id_idx ON public.declutter_items(device_id);
CREATE INDEX IF NOT EXISTS resell_items_device_id_idx ON public.resell_items(device_id);
CREATE INDEX IF NOT EXISTS deep_cleaning_sessions_device_id_idx ON public.deep_cleaning_sessions(device_id);
CREATE INDEX IF NOT EXISTS planned_sessions_device_id_idx ON public.planned_sessions(device_id);

-- Add comment explaining the purpose
COMMENT ON COLUMN public.memories.deleted_at IS 'Soft delete timestamp - set when item is deleted on any device';
COMMENT ON COLUMN public.memories.device_id IS 'UUID of device that made the last change - used for conflict resolution';
COMMENT ON COLUMN public.declutter_items.deleted_at IS 'Soft delete timestamp - set when item is deleted on any device';
COMMENT ON COLUMN public.declutter_items.device_id IS 'UUID of device that made the last change - used for conflict resolution';
COMMENT ON COLUMN public.resell_items.deleted_at IS 'Soft delete timestamp - set when item is deleted on any device';
COMMENT ON COLUMN public.resell_items.device_id IS 'UUID of device that made the last change - used for conflict resolution';
COMMENT ON COLUMN public.deep_cleaning_sessions.deleted_at IS 'Soft delete timestamp - set when session is deleted on any device';
COMMENT ON COLUMN public.deep_cleaning_sessions.device_id IS 'UUID of device that made the last change - used for conflict resolution';
COMMENT ON COLUMN public.deep_cleaning_sessions.session_status IS 'Current session status - ongoing, paused, completed, or canceled';
COMMENT ON COLUMN public.planned_sessions.deleted_at IS 'Soft delete timestamp - set when session is deleted on any device';
COMMENT ON COLUMN public.planned_sessions.device_id IS 'UUID of device that made the last change - used for conflict resolution';
