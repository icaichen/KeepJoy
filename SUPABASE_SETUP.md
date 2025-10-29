# Supabase Integration Setup Guide

## What Was Done

### ✅ Models Updated
All data models have been enhanced with:
- **`userId` field**: Links data to authenticated users
- **`toJson()` method**: Serializes data for Supabase
- **`fromJson()` factory**: Deserializes data from Supabase
- **`createdAt` and `updatedAt` timestamps**: Tracks record history

Updated models:
- `DeclutterItem`
- `ResellItem`
- `DeepCleaningSession`
- `Memory`
- `PlannedSession`

### ✅ Dependencies Added
- `supabase_flutter: ^2.9.1` - Supabase client with auth
- `flutter_secure_storage: ^9.2.2` - Secure token storage

### ✅ Services Created
- **`AuthService`** ([lib/services/auth_service.dart](lib/services/auth_service.dart)) - Handles authentication
- **`DataRepository`** ([lib/services/data_repository.dart](lib/services/data_repository.dart)) - Handles all CRUD operations

### ✅ UI Created
- **`AuthScreen`** ([lib/features/auth/auth_screen.dart](lib/features/auth/auth_screen.dart)) - Login/signup screen

### ✅ Database Schema
- **SQL schema** ([supabase/schema.sql](supabase/schema.sql)) - Complete database structure with RLS policies

---

## Setup Instructions

### Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign in with GitHub (or create account)
4. Click "New Project"
5. Fill in project details:
   - **Name**: keepjoy
   - **Database Password**: [create a strong password]
   - **Region**: [choose closest to you]
6. Click "Create new project" and wait for setup to complete

### Step 2: Run Database Schema

1. In your Supabase project, go to **SQL Editor** (left sidebar)
2. Click "New query"
3. Copy the entire contents of `supabase/schema.sql`
4. Paste into the SQL editor
5. Click "Run" or press `Cmd+Enter`
6. Verify success (should see "Success. No rows returned")

This creates:
- 5 tables with proper foreign keys
- Row Level Security (RLS) policies
- Indexes for performance
- Auto-update triggers for `updated_at` fields

### Step 3: Get API Credentials

1. In Supabase, go to **Project Settings** (gear icon in left sidebar)
2. Click **API** in the left menu
3. Copy two values:
   - **Project URL** (looks like: `https://xyzabc123.supabase.co`)
   - **anon/public key** (long JWT token starting with `eyJ...`)

### Step 4: Update Configuration

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values:
   ```dart
   static const String supabaseUrl = 'YOUR_ACTUAL_PROJECT_URL';
   static const String supabaseAnonKey = 'YOUR_ACTUAL_ANON_KEY';
   ```

### Step 5: Update main.dart (IMPORTANT!)

⚠️ **Your app currently has compilation errors** because all models now require `userId`.

You need to:

1. **Initialize Supabase** in `main()`:
   ```dart
   import 'package:keepjoy_app/services/auth_service.dart';
   import 'package:keepjoy_app/features/auth/auth_screen.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();

     // Initialize Supabase
     await AuthService.initialize();

     runApp(const MyApp());
   }
   ```

2. **Add auth state listener** in `MyApp`:
   ```dart
   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         home: StreamBuilder(
           stream: AuthService().authStateChanges,
           builder: (context, snapshot) {
             // Show auth screen if not logged in
             if (snapshot.data?.session == null) {
               return const AuthScreen();
             }
             // Show main app if logged in
             return const MainNavigator();
           },
         ),
       );
     }
   }
   ```

3. **Pass `userId` when creating models**:
   ```dart
   final userId = AuthService().currentUserId!;

   // Example: Creating a DeclutterItem
   final item = DeclutterItem(
     id: const Uuid().v4(),
     userId: userId,  // ← ADD THIS
     name: 'My Item',
     category: DeclutterCategory.clothes,
     createdAt: DateTime.now(),
     status: DeclutterStatus.pending,
   );
   ```

4. **Sync with database** after creating/updating:
   ```dart
   final repository = DataRepository();

   // Create
   await repository.createDeclutterItem(item);

   // Update
   await repository.updateDeclutterItem(item);

   // Delete
   await repository.deleteDeclutterItem(item.id);

   // Fetch all
   final items = await repository.fetchDeclutterItems();
   ```

### Step 6: Handle Photo Storage

Currently, photos are stored as local file paths. For production, you should:
1. Upload photos to Supabase Storage
2. Store the public URL in the database
3. Update photo handling logic

Example:
```dart
// Upload photo to Supabase Storage
final file = File(photoPath);
final fileName = '${userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
await supabase.storage.from('photos').upload(fileName, file);

// Get public URL
final url = supabase.storage.from('photos').getPublicUrl(fileName);

// Store URL in database instead of local path
```

---

## Testing

### Test Authentication
1. Run the app: `flutter run`
2. You should see the auth screen
3. Create an account with email/password
4. Sign in
5. You should see the main app

### Test Data Persistence
1. Create some items in the app
2. Close the app completely
3. Reopen the app and sign in
4. Data should be persisted

### Test in Supabase Dashboard
1. Go to **Table Editor** in Supabase
2. Select a table (e.g., `declutter_items`)
3. You should see your data
4. Try editing/deleting in the dashboard
5. Refresh app to see changes

---

## Key Benefits

✅ **User Authentication**: Secure email/password login
✅ **Data Persistence**: All data stored in PostgreSQL
✅ **Multi-device Sync**: Access data from any device
✅ **Row Level Security**: Users can only see their own data
✅ **Real-time Updates**: Supabase supports real-time subscriptions
✅ **Automatic Backups**: Supabase handles database backups
✅ **Scalable**: PostgreSQL can handle millions of rows

---

## Potential Issues Found & Fixed

### ✅ Fixed Issues:
1. **Missing `_chipColors` in InsightsScreen** - Added color palette
2. **Missing serialization methods** - Added to all models
3. **Missing `userId` fields** - Added to all models
4. **Missing `updatedAt` fields** - Added to all models
5. **Missing `createdAt` in some models** - Added where missing
6. **Completed sessions not tracked** - Fixed in main.dart

### ⚠️ Remaining Tasks:
1. Update all model creation in main.dart to pass `userId`
2. Integrate `DataRepository` for all CRUD operations
3. Replace local file storage with Supabase Storage for photos
4. Add offline support with local caching (optional)
5. Add real-time sync listeners (optional)

---

## Next Steps

1. **Complete Step 1-4** to set up Supabase
2. **Review Step 5** carefully - this requires code changes in main.dart
3. Test authentication flow
4. Test data persistence
5. Consider photo storage strategy

Need help? Check:
- [Supabase Docs](https://supabase.com/docs)
- [Flutter Supabase Docs](https://supabase.com/docs/reference/dart)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
