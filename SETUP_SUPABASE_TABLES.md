# Supabase Database Setup

## Problem
Your TODO/calendar items (PlannedSessions) are not syncing because the `planned_sessions` table doesn't exist in your Supabase database yet.

## Solution
Run the migration SQL script in your Supabase dashboard.

## Steps

### 1. Open Supabase Dashboard
1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Select your KeepJoy project
3. Click "SQL Editor" in the left sidebar

### 2. Run the Migration
1. Click "New query" button
2. Copy and paste the entire contents of this file:
   ```
   supabase/migrations/202501200001_create_planned_sessions_table.sql
   ```
3. Click "Run" button (or press Cmd+Enter)
4. You should see "Success. No rows returned"

### 3. Verify Table Creation
1. In Supabase dashboard, click "Table Editor" in left sidebar
2. You should now see `planned_sessions` table listed
3. The table will be empty initially

### 4. Test Sync
1. Force close your app completely
2. Reopen the app
3. Create a new TODO/calendar item
4. Wait 5-10 seconds for sync
5. Check Supabase Table Editor - the item should appear in `planned_sessions` table

## What This Fixes
- ✅ TODO items will now sync to cloud
- ✅ Calendar/planned sessions will now backup
- ✅ Items will sync across devices (if you log in on multiple devices)
- ✅ Data won't be lost if you uninstall the app

## If It Still Doesn't Work
Check the app logs:
1. Connect your device/simulator
2. Run: `flutter logs | grep "planned"`
3. Look for error messages about `planned_sessions` table

## Already Have the Table?
If the table already exists, running this script is safe - it uses `CREATE TABLE IF NOT EXISTS` and `DROP POLICY IF EXISTS` to avoid errors.
