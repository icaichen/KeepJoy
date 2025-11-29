# Password Reset Setup Guide

This guide explains how to set up password reset functionality for KeepJoy app with Supabase.

## Overview

The password reset flow works as follows:
1. User requests password reset from the login page
2. User receives an email with a reset link
3. User clicks the link, which opens the app via deep link
4. App exchanges the code from the URL for a session
5. User enters new password
6. Password is updated and user is logged out

## Setup Steps

### 1. Configure Supabase Redirect URL

You **must** add the deep link URL to your Supabase project's allowed redirect URLs:

1. Go to your Supabase project dashboard
2. Navigate to **Authentication** > **URL Configuration**
3. Under **Redirect URLs**, add:
   ```
   keepjoy://auth-callback
   ```
4. Click **Save**

**Important**: Without this step, you'll get "invalid or expired code" errors!

### 2. Verify App Configuration

The app is already configured to use the deep link scheme `keepjoy://auth-callback`:
- **iOS**: Configured in `ios/Runner/Info.plist` with CFBundleURLTypes
- **Android**: Configured in `android/app/src/main/AndroidManifest.xml` with intent-filter
- **Code**: Set in `lib/config/app_links.dart` as `resetPasswordRedirect`

### 3. Test the Flow

1. Request a password reset from the login page
2. Check your email for the reset link
3. Click the link (it should open the app)
4. If you see "invalid or expired code" error:
   - Check that `keepjoy://auth-callback` is added to Supabase redirect URLs
   - Make sure you're clicking the link within the expiration time (usually 1 hour)
   - Try requesting a new reset link

## Troubleshooting

### "Invalid or expired code" Error

**Most common causes:**

1. **Redirect URL not configured in Supabase**
   - ✅ Solution: Add `keepjoy://auth-callback` to Supabase redirect URLs (see step 1 above)

2. **Email link prefetching**
   - Some email clients (like Outlook) prefetch links, consuming the code before you click
   - ✅ Solution: Try opening the link in a different email client or request a new reset link

3. **Code expired**
   - Password reset codes expire after a certain time (default: 1 hour)
   - ✅ Solution: Request a new password reset link

4. **Deep link not configured**
   - ✅ Solution: Verify iOS and Android configurations are correct (see step 2 above)

### App doesn't open from email link

1. Check that the URL scheme is configured correctly in:
   - `ios/Runner/Info.plist`
   - `android/app/src/main/AndroidManifest.xml`
2. Try rebuilding the app after configuration changes
3. On iOS, you may need to uninstall and reinstall the app

### Code exchange fails

1. Check network connectivity
2. Verify Supabase credentials are configured correctly
3. Check app logs for detailed error messages
4. Ensure the code hasn't been used already (codes are single-use)

## Code Flow

1. **User requests reset**: `AuthService.resetPassword(email)` sends reset email
2. **Email sent**: Supabase sends email with link containing code
3. **Deep link opens app**: URL format: `keepjoy://auth-callback?code=xxx&type=recovery`
4. **Code exchange**: `ResetPasswordPage` calls `AuthService.exchangeCodeForSession(code)`
5. **Password update**: User enters new password, `AuthService.updatePassword()` is called
6. **Sign out**: User is signed out and redirected to login page

## Files Modified

- `lib/services/auth_service.dart` - Added code exchange methods
- `lib/features/auth/reset_password_page.dart` - New page for password reset
- `lib/config/app_links.dart` - Configured deep link URL
- `lib/main.dart` - Added route and deep link handling
- `android/app/src/main/AndroidManifest.xml` - Added intent-filter
- `ios/Runner/Info.plist` - Added CFBundleURLTypes

## Additional Notes

- The reset password link is valid for a limited time (default: 1 hour in Supabase)
- Each code can only be used once
- After password reset, the user must sign in again with the new password
- The deep link scheme `keepjoy://` must match exactly between Supabase and app configuration

