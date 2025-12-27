/// App Configuration for HarmonyOS NEXT
/// 
/// This is a simplified configuration for the HarmonyOS-only version.
/// No flavor switching needed since this project targets only HarmonyOS.

class AppConfig {
  // API Configuration
  static const String apiBaseUrl = 'https://api.keepjoy.cn';
  
  // App Info
  static const String appTitle = 'KeepJoy';
  static const String appName = 'keepjoy';
  
  // Feature Flags
  static const bool showChinaSpecificFeatures = true;
  
  // Supported Methods (for future use with Huawei services)
  static const List<String> supportedLoginMethods = ['huawei', 'phone'];
  static const List<String> supportedPaymentMethods = ['华为支付', '微信支付', '支付宝'];
}
