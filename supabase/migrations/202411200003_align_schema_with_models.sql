-- Align database schema with Flutter models and tighten RLS policies

-- Add purchase review fields to declutter_items
ALTER TABLE IF EXISTS public.declutter_items
  ADD COLUMN IF NOT EXISTS purchase_review TEXT,
  ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;

ALTER TABLE IF EXISTS public.declutter_items
  DROP CONSTRAINT IF EXISTS declutter_items_purchase_review_check;

ALTER TABLE IF EXISTS public.declutter_items
  ADD CONSTRAINT declutter_items_purchase_review_check
  CHECK (
    purchase_review IN ('worthIt', 'wouldBuyAgain', 'neutral', 'wasteMoney')
  );

-- Make planned_sessions scheduling optional and add planning metadata
ALTER TABLE IF EXISTS public.planned_sessions
  ALTER COLUMN scheduled_date DROP NOT NULL,
  ALTER COLUMN scheduled_time DROP NOT NULL;

ALTER TABLE IF EXISTS public.planned_sessions
  ADD COLUMN IF NOT EXISTS is_completed BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'someday',
  ADD COLUMN IF NOT EXISTS mode TEXT DEFAULT 'deepCleaning',
  ADD COLUMN IF NOT EXISTS goal TEXT;

UPDATE public.planned_sessions
SET is_completed = FALSE
WHERE is_completed IS NULL;

ALTER TABLE IF EXISTS public.planned_sessions
  ALTER COLUMN is_completed SET NOT NULL;

UPDATE public.planned_sessions
SET priority = 'someday'
WHERE priority IS NULL;

ALTER TABLE IF EXISTS public.planned_sessions
  ALTER COLUMN priority SET NOT NULL;

UPDATE public.planned_sessions
SET mode = 'deepCleaning'
WHERE mode IS NULL;

ALTER TABLE IF EXISTS public.planned_sessions
  ALTER COLUMN mode SET NOT NULL;

ALTER TABLE IF EXISTS public.planned_sessions
  DROP CONSTRAINT IF EXISTS planned_sessions_priority_check;

ALTER TABLE IF EXISTS public.planned_sessions
  ADD CONSTRAINT planned_sessions_priority_check
  CHECK (priority IN ('today', 'thisWeek', 'someday'));

ALTER TABLE IF EXISTS public.planned_sessions
  DROP CONSTRAINT IF EXISTS planned_sessions_mode_check;

ALTER TABLE IF EXISTS public.planned_sessions
  ADD CONSTRAINT planned_sessions_mode_check
  CHECK (mode IN ('deepCleaning', 'joyDeclutter', 'quickDeclutter'));

-- Expand allowed memory types and sentiments
ALTER TABLE IF EXISTS public.memories
  DROP CONSTRAINT IF EXISTS memories_type_check;

ALTER TABLE IF EXISTS public.memories
  ADD CONSTRAINT memories_type_check
  CHECK (
    type IN (
      'decluttering',
      'cleaning',
      'custom',
      'grateful',
      'lesson',
      'celebrate'
    )
  );

ALTER TABLE IF EXISTS public.memories
  DROP CONSTRAINT IF EXISTS memories_sentiment_check;

ALTER TABLE IF EXISTS public.memories
  ADD CONSTRAINT memories_sentiment_check
  CHECK (
    sentiment IN (
      'love',
      'nostalgia',
      'adventure',
      'happy',
      'grateful',
      'peaceful',
      'childhoodMemory',
      'grownTogether',
      'missionCompleted'
    )
  );

-- Strengthen UPDATE policies to prevent user_id swapping
DROP POLICY IF EXISTS "Users can update their own declutter items" ON public.declutter_items;
CREATE POLICY "Users can update their own declutter items"
  ON public.declutter_items FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own resell items" ON public.resell_items;
CREATE POLICY "Users can update their own resell items"
  ON public.resell_items FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own deep cleaning sessions" ON public.deep_cleaning_sessions;
CREATE POLICY "Users can update their own deep cleaning sessions"
  ON public.deep_cleaning_sessions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own memories" ON public.memories;
CREATE POLICY "Users can update their own memories"
  ON public.memories FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own planned sessions" ON public.planned_sessions;
CREATE POLICY "Users can update their own planned sessions"
  ON public.planned_sessions FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
