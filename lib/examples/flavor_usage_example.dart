import 'package:keepjoy_app/config/flavor_config.dart';

/// ✅ 正确的用法示例

// 示例 1: 使用配置而不是 if 语句
void makeApiCall() {
  final apiUrl = FlavorConfig.instance.apiBaseUrl;
  // 使用 apiUrl 发起请求
  // 中国版本会自动使用 https://api.keepjoy.cn
  // 国际版本会自动使用 https://api.keepjoy.com
  print('API URL: $apiUrl');
}

// 示例 2: 显示支持的登录方式
List<String> getLoginMethods() {
  // 直接从配置获取，不需要 if 语句
  return FlavorConfig.instance.supportedLoginMethods;
  // 中国版本返回: ['email', 'wechat', 'alipay']
  // 国际版本返回: ['email', 'google', 'apple']
}

// 示例 3: 只在需要时使用 if（很少）
void showSpecialFeature() {
  // 只有在真的需要完全不同的逻辑时才用 if
  if (FlavorConfig.instance.showChinaSpecificFeatures) {
    // 显示中国特有的功能
    print('显示中国版本特殊功能');
  }
}

// 示例 4: UI 中的使用
class LoginPage {
  void buildLoginButtons() {
    final methods = FlavorConfig.instance.supportedLoginMethods;

    for (var method in methods) {
      switch (method) {
        case 'email':
          print('显示邮箱登录按钮');
          break;
        case 'wechat':
          print('显示微信登录按钮');
          break;
        case 'google':
          print('显示 Google 登录按钮');
          break;
        // ... 其他登录方式
      }
    }
  }
}

/// ❌ 不好的做法（避免）
void badExample() {
  // 到处都是 if 语句 - 不推荐！
  if (FlavorConfig.instance.isChina) {
    // 中国逻辑
    print('中国版本');
  } else {
    // 国际逻辑
    print('国际版本');
  }
}
