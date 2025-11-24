-- ============================================================================
-- Supabase Storage Setup for Profile Avatars
-- ============================================================================
-- Run this SQL in your Supabase SQL Editor after creating the 'profiles' bucket
--
-- IMPORTANT: First create the 'profiles' bucket manually in Supabase Dashboard:
-- 1. Go to Storage in Supabase Dashboard
-- 2. Click "New bucket"
-- 3. Name: "profiles"
-- 4. Check "Public bucket" (so avatar URLs work)
-- 5. Click "Create bucket"
--
-- Then run this SQL to set up the security policies.
-- ============================================================================

-- ============================================================================
-- Storage Policies for 'profiles' bucket (avatars)
-- ============================================================================

-- Policy: Allow authenticated users to upload their own avatars
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Allow users to update/replace their own avatars
CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Allow users to delete their own avatars
CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Allow anyone to view all avatars (public read access)
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profiles');

-- ============================================================================
-- Optional: Verify other storage buckets exist
-- ============================================================================
-- Make sure these buckets also exist in your Supabase project:
--
-- 1. 'memories' - for memory photos
-- 2. 'items' - for item photos
-- 3. 'sessions' - for before/after cleaning photos
--
-- Each should have similar RLS policies. If they don't exist yet,
-- create them in the Supabase Dashboard and add similar policies.
-- ============================================================================

-- Example policies for 'memories' bucket (if needed):
/*
CREATE POLICY "Users can upload own memory photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'memories' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can view own memory photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'memories' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can update own memory photos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'memories' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users can delete own memory photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'memories' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
*/

-- ============================================================================
-- Done! Your profile avatars should now work properly.
-- ============================================================================
