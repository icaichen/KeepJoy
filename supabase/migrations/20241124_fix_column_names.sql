-- ============================================================================
-- FIX: Rename columns to match app code
-- App sends: photo_path, before_photo_path, after_photo_path
-- Database has: remote_photo_url, remote_before_photo_url, remote_after_photo_url
-- ============================================================================

-- declutter_items: rename remote_photo_url -> photo_path
ALTER TABLE declutter_items
  DROP COLUMN IF EXISTS local_photo_path,
  ADD COLUMN IF NOT EXISTS photo_path TEXT;

-- If remote_photo_url exists, copy data and drop it
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'declutter_items' AND column_name = 'remote_photo_url') THEN
    UPDATE declutter_items SET photo_path = remote_photo_url WHERE photo_path IS NULL;
    ALTER TABLE declutter_items DROP COLUMN remote_photo_url;
  END IF;
END $$;

-- deep_cleaning_sessions: rename to before_photo_path and after_photo_path
ALTER TABLE deep_cleaning_sessions
  DROP COLUMN IF EXISTS local_before_photo_path,
  DROP COLUMN IF EXISTS local_after_photo_path,
  ADD COLUMN IF NOT EXISTS before_photo_path TEXT,
  ADD COLUMN IF NOT EXISTS after_photo_path TEXT;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'deep_cleaning_sessions' AND column_name = 'remote_before_photo_url') THEN
    UPDATE deep_cleaning_sessions SET before_photo_path = remote_before_photo_url WHERE before_photo_path IS NULL;
    ALTER TABLE deep_cleaning_sessions DROP COLUMN remote_before_photo_url;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'deep_cleaning_sessions' AND column_name = 'remote_after_photo_url') THEN
    UPDATE deep_cleaning_sessions SET after_photo_path = remote_after_photo_url WHERE after_photo_path IS NULL;
    ALTER TABLE deep_cleaning_sessions DROP COLUMN remote_after_photo_url;
  END IF;
END $$;

-- memories: same fix
ALTER TABLE memories
  DROP COLUMN IF EXISTS local_photo_path,
  ADD COLUMN IF NOT EXISTS photo_path TEXT;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_name = 'memories' AND column_name = 'remote_photo_url') THEN
    UPDATE memories SET photo_path = remote_photo_url WHERE photo_path IS NULL;
    ALTER TABLE memories DROP COLUMN remote_photo_url;
  END IF;
END $$;
