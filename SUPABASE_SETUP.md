# Supabase Authentication Setup Guide

## ✅ Authentication Implementation Complete!

The authentication system has been fully integrated with Supabase. Here's what's been implemented:

### What's Working Now:

✅ **Sign Up**: Create new user accounts with email and password
✅ **Sign In**: Log in with existing credentials
✅ **Welcome Screen**: Beautiful onboarding page with KeepJoy logo
✅ **Login/Signup Screen**: Unified authentication page matching app design
✅ **Auto-navigation**: Automatically routes to home screen when authenticated
✅ **Session persistence**: Users stay logged in even after closing the app
✅ **Logout**: Users can log out from the profile page
✅ **Loading states**: Shows spinner during authentication
✅ **Error handling**: Displays error messages for failed attempts

---

## Quick Setup Guide

### Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Fill in the project details:
   - **Name**: KeepJoy (or any name you prefer)
   - **Database Password**: Choose a strong password (save this somewhere safe)
   - **Region**: Select the region closest to your users
5. Click "Create new project" and wait for it to finish setting up (takes about 2 minutes)

### Step 2: Get Your Project Credentials

1. Once your project is created, go to **Project Settings** (gear icon in the sidebar)
2. Navigate to **API** section
3. You'll find two important pieces of information:
   - **Project URL**: Something like `https://xyzcompany.supabase.co`
   - **anon/public key**: A long JWT token starting with `eyJ...`

### Step 3: Configure Your App

1. Copy your Supabase URL and anon key from **Project Settings > API**.
2. Pass them to Flutter via `--dart-define` so they never touch source control:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xyzcompany.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

For release builds, do the same (e.g., `flutter build ipa --dart-define=...`).
If you previously committed credentials, regenerate your anon key in the Supabase dashboard after updating this configuration.

### Step 4: Enable Email Authentication (Optional Configuration)

1. In your Supabase project dashboard, go to **Authentication** > **Providers**
2. Make sure **Email** provider is enabled (it should be by default)

#### Optional: Disable Email Confirmation for Testing

If you want to test without having to confirm emails:

1. Go to **Authentication** > **Settings**
2. Scroll to **Email Auth**
3. Toggle off **Enable email confirmations**
4. Click **Save**

**Warning**: Only disable email confirmation for testing! Always enable it for production.

### Step 5: Test Your Setup

1. Stop your Flutter app if it's running
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run your app: `flutter run`
5. You should now be able to:
   - See the welcome screen with the KeepJoy logo
   - Sign up with a new email and password
   - Sign in with existing credentials
   - Be automatically logged in on app restart
   - Log out from the profile page

---

## Testing the Authentication Flow

### Test Sign Up:
1. Open the app (you should see the welcome screen)
2. Tap "Get Started"
3. Toggle to "Sign Up" mode
4. Fill in your details:
   - Name (optional, for display)
   - Email address
   - Password (minimum 6 characters)
   - Confirm password
5. Tap "Sign Up"
6. You should see a success message and be redirected to the home screen

### Test Sign In:
1. Log out from the profile page
2. You should be taken back to the welcome screen
3. Tap "Get Started"
4. Enter your email and password
5. Tap "Sign In"
6. You should be redirected to the home screen

### Test Session Persistence:
1. While logged in, close the app completely
2. Reopen the app
3. You should go directly to the home screen (not the welcome screen)

### Test Logout:
1. Go to the Profile tab
2. Scroll down to "Data Management"
3. Tap "Log Out"
4. You should be taken back to the welcome screen

---

## Implementation Details

### Files Modified:

1. **`lib/main.dart`**
   - Added Supabase initialization in `main()`
   - Added AuthService import
   - Checks authentication status to determine initial route

2. **`lib/features/auth/login_page.dart`**
   - Integrated with AuthService
   - Handles sign up and sign in
   - Shows loading state during authentication
   - Displays error messages
   - Navigates to home on success

3. **`lib/features/auth/welcome_page.dart`**
   - Already correctly implemented
   - Navigates to login page

4. **`lib/services/auth_service.dart`**
   - Already exists with all necessary methods
   - Handles Supabase initialization
   - Provides sign up, sign in, sign out methods

### Authentication Flow:

```
App Start
    ↓
Initialize Supabase
    ↓
Check if user is authenticated
    ↓
   Yes → Home Screen
    ↓
   No → Welcome Screen
    ↓
Get Started / Already have account
    ↓
Login Page
    ↓
Sign Up / Sign In
    ↓
Success → Home Screen
    ↓
Error → Show error message
```

---

## Troubleshooting

### "Invalid API key" or "Failed to initialize"

- Double-check that your `supabaseUrl` and `supabaseAnonKey` are correct in `lib/config/supabase_config.dart`
- Make sure there are no extra spaces or quotes
- Verify you copied the **anon/public** key, not the service role key
- Restart your app after updating the config

### "Email rate limit exceeded"

- Supabase has rate limits on the free tier
- Wait a few minutes and try again
- Consider upgrading your plan if you need higher limits

### "User already registered"

- This means an account with that email already exists
- Try signing in instead, or use a different email

### "Invalid login credentials"

- Check that your email and password are correct
- Passwords are case-sensitive
- Make sure you're using the email you signed up with

### App stays on welcome screen after login

- Check that navigation to `/home` is working
- Verify that `AuthService().isAuthenticated` returns true after login
- Try a full restart: `flutter clean && flutter pub get && flutter run`

### "Unable to load asset: app_logo.png"

- Make sure you've added the logo to `assets/images/app_logo.png`
- Run `flutter clean && flutter pub get`
- Perform a full restart (not hot reload)

---

## Next Steps (Optional Enhancements)

### 1. Password Reset

The forgot password functionality is already stubbed out in the login page. To implement it:

1. Add a dialog to collect the user's email
2. Call `AuthService().resetPassword(email)`
3. Show a success message
4. User will receive a password reset email

### 2. Social Authentication

You can add Google and Apple sign-in by:

1. Setting up OAuth providers in Supabase (Authentication > Providers)
2. Following the Supabase documentation for each provider
3. Using Supabase's OAuth methods
4. Update the social login buttons in login_page.dart

### 3. User Profiles

Create a `profiles` table in Supabase to store additional user information:

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

### 4. Email Verification

For production, enable email verification:

1. Go to Authentication > Settings in Supabase
2. Enable "Enable email confirmations"
3. Customize the email templates under "Email Templates"
4. Handle the confirmation flow in your app

---

## Security Best Practices

⚠️ **IMPORTANT**: Never commit your Supabase credentials to version control!

### Provide credentials at runtime

- Use `--dart-define` (or your CI/CD secret store) to inject `SUPABASE_URL` and `SUPABASE_ANON_KEY` when running or building the app.
- Example: `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- For CI, configure the same defines in your build pipeline or use environment-specific per-app configuration.

### Rotate leaked keys

If a key was ever committed, immediately:
1. Go to **Project Settings > API** in Supabase.
2. Click **Regenerate** under the anon/public key.
3. Update your local `--dart-define` values and any deployed environments.

### Row Level Security (RLS)

Make sure to enable RLS on all your database tables:

```sql
-- Example for declutter_items table
ALTER TABLE declutter_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own items"
  ON declutter_items FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own items"
  ON declutter_items FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own items"
  ON declutter_items FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own items"
  ON declutter_items FOR DELETE
  USING (auth.uid() = user_id);
```

---

## Database Schema (Optional)

If you want to persist data to Supabase (not just use authentication), check the `supabase/schema.sql` file which contains:

- Tables for all app data models
- Row Level Security policies
- Indexes for performance
- Auto-update triggers

Run this SQL in your Supabase SQL Editor to create the tables.

---

## Support & Resources

### Documentation
- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

### Community
- [Supabase Discord](https://discord.supabase.com)
- [Supabase GitHub Discussions](https://github.com/supabase/supabase/discussions)

### Need Help?

If you encounter any issues:
1. Check the troubleshooting section above
2. Verify your Supabase credentials are correct
3. Check the Supabase Dashboard for auth logs
4. Review the Flutter console for error messages

---

## What's Next?

You now have a fully functional authentication system! Here are some ideas for what to build next:

1. **Data Persistence**: Integrate the DataRepository to save user data to Supabase
2. **Photo Storage**: Use Supabase Storage for photos instead of local storage
3. **Multi-device Sync**: Users can access their data from any device
4. **Offline Support**: Implement local caching with background sync
5. **Real-time Updates**: Use Supabase real-time subscriptions for live data updates

Happy coding! 🎉
