# Flavor 管理最佳实践 🎯

## 核心原则：配置驱动，而非条件判断

### ✅ 推荐的做法

#### 1. 在 `FlavorConfig` 中集中管理配置

```dart
// lib/config/flavor_config.dart
class FlavorConfig {
  final String apiBaseUrl;           // API 地址
  final List<String> loginMethods;   // 登录方式
  final List<String> paymentMethods; // 支付方式
  // ... 其他配置
}
```

**好处：**
- 所有差异在一个文件中管理
- 代码中直接使用配置，不需要 if 判断
- 添加新配置很容易

#### 2. 使用配置而不是条件

```dart
// ✅ 好的做法
void makeApiCall() {
  final url = FlavorConfig.instance.apiBaseUrl;
  http.get(url);
}

// ❌ 不好的做法
void makeApiCall() {
  if (FlavorConfig.instance.isChina) {
    http.get('https://api.keepjoy.cn');
  } else {
    http.get('https://api.keepjoy.com');
  }
}
```

#### 3. 只在必要时使用条件判断

**使用条件的场景：**
- 完全不同的业务逻辑
- 需要调用不同的 SDK
- 特定版本独有的功能

```dart
// 可以接受的 if 用法
if (FlavorConfig.instance.isChina) {
  // 初始化微信 SDK
  WechatSDK.initialize();
}
```

### 代码组织建议

#### 文件结构

```
lib/
├── config/
│   └── flavor_config.dart          # 集中管理所有配置
├── services/
│   ├── payment_service.dart        # 抽象接口
│   ├── payment_service_china.dart  # 中国实现
│   └── payment_service_global.dart # 国际实现
├── main.dart                       # 默认入口
├── main_china.dart                 # 中国版本入口
└── main_global.dart                # 国际版本入口
```

#### 服务类的设计模式

```dart
// 1. 定义抽象接口
abstract class PaymentService {
  Future<bool> processPayment(double amount);

  // 工厂方法
  factory PaymentService.create() {
    if (FlavorConfig.instance.isChina) {
      return ChinaPaymentService();
    }
    return GlobalPaymentService();
  }
}

// 2. 中国版本实现
class ChinaPaymentService implements PaymentService {
  @override
  Future<bool> processPayment(double amount) {
    // 使用微信支付或支付宝
    return WechatPay.pay(amount);
  }
}

// 3. 国际版本实现
class GlobalPaymentService implements PaymentService {
  @override
  Future<bool> processPayment(double amount) {
    // 使用 Apple Pay 或 Google Pay
    return RevenueCat.purchase(amount);
  }
}

// 4. 在代码中使用
void checkout() {
  final paymentService = PaymentService.create();
  paymentService.processPayment(99.99);
}
```

### UI 组件的处理

```dart
// ✅ 配置驱动的 UI
Widget buildLoginButtons() {
  final methods = FlavorConfig.instance.supportedLoginMethods;

  return Column(
    children: methods.map((method) {
      switch (method) {
        case 'wechat':
          return WechatLoginButton();
        case 'google':
          return GoogleLoginButton();
        case 'email':
          return EmailLoginButton();
        default:
          return SizedBox.shrink();
      }
    }).toList(),
  );
}
```

### 什么时候 OK 使用 if？

1. **初始化特定 SDK**
   ```dart
   void initSDKs() {
     if (FlavorConfig.instance.isChina) {
       WechatSDK.init();
       AlipaySDK.init();
     }
   }
   ```

2. **显示特定版本的功能入口**
   ```dart
   Widget buildFeatureList() {
     return Column(
       children: [
         CommonFeature(),
         if (FlavorConfig.instance.showChinaSpecificFeatures)
           ChinaOnlyFeature(),
       ],
     );
   }
   ```

3. **错误处理或日志**
   ```dart
   void logError(String error) {
     if (FlavorConfig.instance.isChina) {
       // 发送到中国服务器
     } else {
       // 发送到国际服务器
     }
   }
   ```

## 总结

记住这个原则：

> **配置什么时候不同，就在 FlavorConfig 中添加对应的字段**

这样：
- 代码清晰
- 容易维护
- 添加新版本容易（比如以后加日本版）
- 不会到处都是 if 语句

当你需要添加版本特定的东西时，问自己：
1. 能否作为配置项？ → 加到 FlavorConfig
2. 是否需要不同的实现？ → 创建抽象接口
3. 真的需要 if？ → 确保这个 if 是必要的
