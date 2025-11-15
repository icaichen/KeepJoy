import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/revenuecat_config.dart';

class SubscriptionService {
  SubscriptionService._();

  static bool _isConfigured = false;

  /// Configure RevenueCat once during app startup.
  static Future<void> configure() async {
    await _tryConfigure();
  }

  /// Fetch available offerings for the current user.
  static Future<Offerings?> getOfferings() async {
    final configured = await _ensureConfigured();
    if (!configured) return null;

    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  /// Purchase a selected package from the paywall.
  static Future<CustomerInfo?> purchasePackage(Package package) async {
    final configured = await _ensureConfigured();
    if (!configured) return null;

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } on PlatformException catch (error) {
      final errorCode = PurchasesErrorHelper.getErrorCode(error);
      if (kDebugMode) {
        debugPrint('RevenueCat purchase failed: $errorCode');
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Restore previous purchases, typically exposed behind a button.
  static Future<CustomerInfo?> restorePurchases() async {
    final configured = await _ensureConfigured();
    if (!configured) return null;

    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (_) {
      return null;
    }
  }

  /// Check if the user currently has access to the premium entitlement.
  static Future<bool> isPremium() async {
    final configured = await _ensureConfigured();
    if (!configured) return false;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];
      return entitlement?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Optional listener hook so higher-level state can react to changes.
  static void listenCustomerInfoUpdates(
    void Function(CustomerInfo customerInfo) onUpdated,
  ) {
    Purchases.addCustomerInfoUpdateListener(onUpdated);
  }

  static Future<bool> _ensureConfigured() async {
    if (_isConfigured) return true;
    return _tryConfigure();
  }

  static Future<bool> _tryConfigure() async {
    if (_isConfigured) {
      return true;
    }

    final apiKey = Platform.isIOS
        ? RevenueCatConfig.iosApiKey
        : RevenueCatConfig.androidApiKey;

    if (apiKey.startsWith('#TODO')) {
      if (kDebugMode) {
        debugPrint(
          'RevenueCat API key is still a placeholder. '
          'Configure a real key in RevenueCatConfig before enabling subscriptions.',
        );
      }
      return false;
    }

    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _isConfigured = true;
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to configure RevenueCat: $error');
      }
      return false;
    }
  }
}
