/// Flavor configuration for different market versions
enum Flavor {
  china,
  global,
}

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String appTitle;

  // 🎯 在这里集中管理不同版本的配置
  final String apiBaseUrl;
  final List<String> supportedLoginMethods;
  final List<String> supportedPaymentMethods;
  final bool showChinaSpecificFeatures;

  static FlavorConfig? _instance;

  FlavorConfig._internal({
    required this.flavor,
    required this.name,
    required this.appTitle,
    required this.apiBaseUrl,
    required this.supportedLoginMethods,
    required this.supportedPaymentMethods,
    required this.showChinaSpecificFeatures,
  });

  static FlavorConfig get instance {
    return _instance ?? FlavorConfig._internal(
      flavor: Flavor.global,
      name: 'Global',
      appTitle: 'KeepJoy',
      apiBaseUrl: 'https://api.keepjoy.com',
      supportedLoginMethods: ['email', 'google', 'apple'],
      supportedPaymentMethods: ['Apple Pay', 'Google Pay'],
      showChinaSpecificFeatures: false,
    );
  }

  static void setFlavor(Flavor flavor) {
    switch (flavor) {
      case Flavor.china:
        _instance = FlavorConfig._internal(
          flavor: flavor,
          name: 'China',
          appTitle: 'KeepJoy',
          // 🇨🇳 中国版本特定配置
          apiBaseUrl: 'https://api.keepjoy.cn',
          supportedLoginMethods: ['email', 'wechat', 'alipay'],
          supportedPaymentMethods: ['微信支付', '支付宝'],
          showChinaSpecificFeatures: true,
        );
        break;
      case Flavor.global:
        _instance = FlavorConfig._internal(
          flavor: flavor,
          name: 'Global',
          appTitle: 'KeepJoy',
          // 🌍 国际版本配置
          apiBaseUrl: 'https://api.keepjoy.com',
          supportedLoginMethods: ['email', 'google', 'apple'],
          supportedPaymentMethods: ['Apple Pay', 'Google Pay'],
          showChinaSpecificFeatures: false,
        );
        break;
    }
  }

  bool get isChina => flavor == Flavor.china;
  bool get isGlobal => flavor == Flavor.global;
}
