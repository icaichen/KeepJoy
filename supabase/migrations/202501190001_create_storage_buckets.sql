-- KeepJoy Storage Buckets Setup
-- This migration creates storage buckets for user images with proper RLS policies

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('memories', 'memories', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
  ('items', 'items', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
  ('sessions', 'sessions', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
  ('profiles', 'profiles', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic'])
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can upload to own memories folder" ON storage.objects;
DROP POLICY IF EXISTS "Users can read all memories" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own memories" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload to own items folder" ON storage.objects;
DROP POLICY IF EXISTS "Users can read all items" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own items" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload to own sessions folder" ON storage.objects;
DROP POLICY IF EXISTS "Users can read all sessions" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own sessions" ON storage.objects;
DROP POLICY IF EXISTS "Users can upload to own profile folder" ON storage.objects;
DROP POLICY IF EXISTS "Users can read all profiles" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own profile" ON storage.objects;

-- =============================================================================
-- MEMORIES BUCKET POLICIES
-- =============================================================================

-- Allow users to upload images to their own memories folder
CREATE POLICY "Users can upload to own memories folder"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'memories'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow anyone to read memories (public bucket)
CREATE POLICY "Users can read all memories"
ON storage.objects FOR SELECT
USING (bucket_id = 'memories');

-- Allow users to delete their own memories
CREATE POLICY "Users can delete own memories"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'memories'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =============================================================================
-- ITEMS BUCKET POLICIES
-- =============================================================================

-- Allow users to upload images to their own items folder
CREATE POLICY "Users can upload to own items folder"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'items'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow anyone to read items (public bucket)
CREATE POLICY "Users can read all items"
ON storage.objects FOR SELECT
USING (bucket_id = 'items');

-- Allow users to delete their own items
CREATE POLICY "Users can delete own items"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'items'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =============================================================================
-- SESSIONS BUCKET POLICIES
-- =============================================================================

-- Allow users to upload images to their own sessions folder
CREATE POLICY "Users can upload to own sessions folder"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'sessions'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow anyone to read sessions (public bucket)
CREATE POLICY "Users can read all sessions"
ON storage.objects FOR SELECT
USING (bucket_id = 'sessions');

-- Allow users to delete their own sessions
CREATE POLICY "Users can delete own sessions"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'sessions'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =============================================================================
-- PROFILES BUCKET POLICIES
-- =============================================================================

-- Allow users to upload images to their own profile folder
CREATE POLICY "Users can upload to own profile folder"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profiles'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow anyone to read profiles (public bucket)
CREATE POLICY "Users can read all profiles"
ON storage.objects FOR SELECT
USING (bucket_id = 'profiles');

-- Allow users to delete their own profile
CREATE POLICY "Users can delete own profile"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profiles'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =============================================================================
-- NOTES
-- =============================================================================
-- File structure should be: {bucket_id}/{user_id}/{filename}
-- Examples:
--   memories/abc123/photo.jpg
--   items/abc123/item_12345.jpg
--   sessions/abc123/before_67890.jpg
--   profiles/abc123/avatar.jpg
