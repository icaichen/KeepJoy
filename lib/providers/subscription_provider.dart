import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';

/// Global provider for managing subscription state
class SubscriptionProvider with ChangeNotifier {
  bool _isPremium = false;
  bool _isInTrial = false;
  DateTime? _expirationDate;
  bool _willRenew = false;
  bool _isLoading = true;
  Offerings? _currentOffering;

  Timer? _periodicRefreshTimer;

  bool get isPremium => _isPremium;
  bool get isInTrial => _isInTrial;
  DateTime? get expirationDate => _expirationDate;
  bool get willRenew => _willRenew;
  bool get isLoading => _isLoading;
  Offerings? get currentOffering => _currentOffering;

  SubscriptionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchOfferings();
    await _fetchCustomerInfo();
    _listenForCustomerInfoChanges();
    _startPeriodicRefresh();
  }

  Future<void> _fetchOfferings() async {
    try {
      _currentOffering = await SubscriptionService.getOfferings();
      notifyListeners();
    } catch (e) {
      print('Error fetching offerings: $e');
    }
  }

  void _listenForCustomerInfoChanges() {
    // Add RevenueCat's real-time listener for subscription updates
    // This will automatically sync subscription status across devices
    SubscriptionService.addCustomerInfoUpdateListener((customerInfo) {
      print('📱 Subscription status updated from RevenueCat');
      _updateFromCustomerInfo(customerInfo);
    });
  }

  /// Start periodic refresh as a backup mechanism
  /// This ensures subscription status is synced even if the listener fails
  void _startPeriodicRefresh() {
    // Refresh every 5 minutes
    _periodicRefreshTimer = Timer.periodic(const Duration(minutes: 5), (
      _,
    ) async {
      print('🔄 Periodic subscription status refresh');
      await refreshSubscriptionStatus();
    });
  }

  Future<void> _fetchCustomerInfo() async {
    try {
      _isLoading = true;
      notifyListeners();

      final customerInfo = await SubscriptionService.getCustomerInfo();
      _updateFromCustomerInfo(customerInfo);
    } catch (e) {
      print('Error fetching customer info: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateFromCustomerInfo(CustomerInfo customerInfo) {
    final wasPremium = _isPremium;

    final premiumEntitlement = customerInfo.entitlements.all['premium'];

    _isPremium = premiumEntitlement?.isActive ?? false;
    _isInTrial = premiumEntitlement?.periodType == PeriodType.trial;

    // Parse expirationDate from String to DateTime if needed
    final expDate = premiumEntitlement?.expirationDate;
    if (expDate is String) {
      _expirationDate = DateTime.tryParse(expDate);
    } else if (expDate is DateTime) {
      _expirationDate = expDate;
    } else {
      _expirationDate = null;
    }

    _willRenew = premiumEntitlement?.willRenew ?? false;
    _isLoading = false;

    if (wasPremium != _isPremium) {
      print('Premium status changed: $_isPremium');
    }

    notifyListeners();
  }

  /// Manually refresh subscription status
  Future<void> refreshSubscriptionStatus() async {
    await _fetchCustomerInfo();
  }

  /// Refresh offerings
  Future<void> refreshOfferings() async {
    await _fetchOfferings();
  }

  @override
  void dispose() {
    _periodicRefreshTimer?.cancel();
    super.dispose();
  }
}
