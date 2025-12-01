/// 支付服务抽象接口
/// 不同的 flavor 可以有不同的实现
abstract class PaymentService {
  /// 初始化支付服务
  Future<void> initialize();

  /// 处理支付
  Future<bool> processPayment(String productId, double amount);

  /// 获取支付方式列表
  List<String> getAvailablePaymentMethods();

  /// 工厂方法：根据 flavor 返回不同的实现
  factory PaymentService.create() {
    // 这里以后可以根据 flavor 返回不同实现
    // 现在先返回一个默认实现
    return _DefaultPaymentService();
  }
}

/// 默认支付服务实现（当前使用的）
class _DefaultPaymentService implements PaymentService {
  @override
  Future<void> initialize() async {
    // RevenueCat 初始化
  }

  @override
  Future<bool> processPayment(String productId, double amount) async {
    // 使用 RevenueCat
    return true;
  }

  @override
  List<String> getAvailablePaymentMethods() {
    return ['Apple Pay', 'Google Pay'];
  }
}

/// 中国版本的支付服务（以后添加）
class _ChinaPaymentService implements PaymentService {
  @override
  Future<void> initialize() async {
    // 初始化微信支付、支付宝
  }

  @override
  Future<bool> processPayment(String productId, double amount) async {
    // 使用微信支付或支付宝
    return true;
  }

  @override
  List<String> getAvailablePaymentMethods() {
    return ['微信支付', '支付宝'];
  }
}
