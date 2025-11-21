-- Create planned_sessions table if it doesn't exist
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.planned_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  area TEXT NOT NULL,
  scheduled_date DATE,
  scheduled_time TEXT,
  notes TEXT,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  priority TEXT NOT NULL DEFAULT 'someday' CHECK (
    priority IN ('today', 'thisWeek', 'someday')
  ),
  mode TEXT NOT NULL DEFAULT 'deepCleaning' CHECK (
    mode IN ('deepCleaning', 'joyDeclutter', 'quickDeclutter')
  ),
  goal TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Create indexes
CREATE INDEX IF NOT EXISTS planned_sessions_user_id_idx ON public.planned_sessions(user_id);
CREATE INDEX IF NOT EXISTS planned_sessions_scheduled_date_idx ON public.planned_sessions(scheduled_date);

-- Enable RLS
ALTER TABLE public.planned_sessions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own planned sessions" ON public.planned_sessions;
DROP POLICY IF EXISTS "Users can insert their own planned sessions" ON public.planned_sessions;
DROP POLICY IF EXISTS "Users can update their own planned sessions" ON public.planned_sessions;
DROP POLICY IF EXISTS "Users can delete their own planned sessions" ON public.planned_sessions;

-- Create RLS policies
CREATE POLICY "Users can view their own planned sessions"
  ON public.planned_sessions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own planned sessions"
  ON public.planned_sessions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own planned sessions"
  ON public.planned_sessions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own planned sessions"
  ON public.planned_sessions FOR DELETE
  USING (auth.uid() = user_id);

-- Create trigger for auto-updating updated_at
DROP TRIGGER IF EXISTS update_planned_sessions_updated_at ON public.planned_sessions;
CREATE TRIGGER update_planned_sessions_updated_at
  BEFORE UPDATE ON public.planned_sessions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
