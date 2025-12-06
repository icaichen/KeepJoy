class AppLinks {
  /// App Store 上线地址
  static const String iosAppStoreUrl =
      'https://apps.apple.com/us/app/keepjoy/id6755450700';

  /// TODO: Replace with the Google Play Store listing once available.
  static const String androidPlayStoreUrl = '#TODO_REPLACE_ANDROID_PLAY_URL#';

  /// 仅 iOS 版时使用 App Store 链接分享
  static const String shareUrl = iosAppStoreUrl;

  /// Deep link scheme for authentication callbacks
  /// This must match the URL scheme configured in iOS Info.plist and Android manifest
  static const String authCallbackScheme = 'keepjoy://auth-callback';

  /// Reset password redirect URL (must be added to Supabase Auth > Redirect URLs).
  /// Using deep link scheme for mobile apps - redirects directly to the app
  static const String resetPasswordRedirect = authCallbackScheme;
}
