class AppLinks {
  /// TODO: Replace with the actual App Store URL once the app is published.
  /// Example format: https://apps.apple.com/app/idXXXXXXXXX
  static const String iosAppStoreUrl = '#TODO_REPLACE_IOS_APP_STORE_URL#';

  /// TODO: Replace with the Google Play Store listing once available.
  static const String androidPlayStoreUrl = '#TODO_REPLACE_ANDROID_PLAY_URL#';

  /// TODO: Replace with the final share/landing page URL.
  static const String shareUrl = 'https://keepjoy-site.vercel.app/download.html';

  /// Deep link scheme for authentication callbacks
  /// This must match the URL scheme configured in iOS Info.plist and Android manifest
  static const String authCallbackScheme = 'keepjoy://auth-callback';

  /// Reset password redirect URL (must be added to Supabase Auth > Redirect URLs).
  /// Using deep link scheme for mobile apps - redirects directly to the app
  static const String resetPasswordRedirect = authCallbackScheme;
}
