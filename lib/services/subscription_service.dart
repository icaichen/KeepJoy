import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenuecat_config.dart';

/// Service for managing RevenueCat subscriptions
class SubscriptionService {
  SubscriptionService._();

  static const bool _logDebug = kDebugMode;
  static void _log(Object message) {
    if (_logDebug) {
      debugPrint('$message');
    }
  }

  /// Initialize RevenueCat with platform-specific API keys
  static Future<void> configure() async {
    try {
      _log('🔧 Starting RevenueCat configuration...');

      // Enable debug logging in development
      await Purchases.setLogLevel(_logDebug ? LogLevel.debug : LogLevel.warn);

      // Get API key based on platform
      final String apiKey;
      if (kIsWeb) {
        _log('🌐 Platform: Web (Not fully supported by RevenueCat SDK yet, using placeholder)');
        // RevenueCat doesn't officially support Web yet in the same way, 
        // but this prevents the crash. You might want to handle this differently.
        return; 
      } else if (Platform.isIOS) {
        apiKey = RevenueCatConfig.iosApiKey;
        _log('📱 Platform: iOS');
        _log('🔑 Using iOS API Key: ${apiKey.substring(0, 10)}...');
      } else if (Platform.isAndroid) {
        apiKey = RevenueCatConfig.androidApiKey;
        _log('📱 Platform: Android');
        _log('🔑 Using Android API Key: ${apiKey.substring(0, 10)}...');
      } else {
        _log('⚠️ RevenueCat: Platform not supported');
        return;
      }

      // Configure RevenueCat
      _log('⚙️ Creating PurchasesConfiguration...');
      final configuration = PurchasesConfiguration(apiKey);

      _log('⚙️ Calling Purchases.configure()...');
      await Purchases.configure(configuration);

      _log('✅ RevenueCat configured successfully');

      // Verify configuration by getting customer info
      try {
        _log('🔍 Verifying configuration by fetching customer info...');
        final customerInfo = await Purchases.getCustomerInfo();
        _log('✅ Customer info fetched successfully');
        _log('📊 User ID: ${customerInfo.originalAppUserId}');
      } catch (e) {
        _log('⚠️ Could not fetch customer info after config: $e');
      }
    } catch (e, stackTrace) {
      _log('❌ RevenueCat configuration error: $e');
      _log('📍 Stack trace: $stackTrace');
    }
  }

  /// Login user to RevenueCat with Supabase user ID
  /// This ensures subscription is tied to the user account
  static Future<void> loginUser(String userId) async {
    try {
      await Purchases.logIn(userId);
      _log('✅ RevenueCat user logged in: $userId');
    } catch (e) {
      _log('❌ RevenueCat login error: $e');
      rethrow;
    }
  }

  /// Logout user from RevenueCat
  static Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
      _log('✅ RevenueCat user logged out');
    } catch (e) {
      _log('❌ RevenueCat logout error: $e');
    }
  }

  /// Check if user has active premium subscription
  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Debug: Print all available entitlements
      _log('🔍 All Entitlements: ${customerInfo.entitlements.all.keys.toList()}');
      _log(
        '🔍 Active Entitlements: ${customerInfo.entitlements.active.keys.toList()}',
      );

      // Check if user has ANY active entitlement (in case the ID is wrong)
      if (customerInfo.entitlements.active.isNotEmpty) {
        _log(
          '✅ User has active entitlements: ${customerInfo.entitlements.active.keys.toList()}',
        );
        // Return true if ANY entitlement is active
        return true;
      }

      // Fallback: Check specific premium entitlement
      final entitlement =
          customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];

      if (entitlement != null) {
        _log(
          '📦 Premium entitlement found - isActive: ${entitlement.isActive}',
        );
        return entitlement.isActive;
      }

      _log(
        '⚠️ No premium entitlement found with ID: ${RevenueCatConfig.premiumEntitlementId}',
      );
      return false;
    } catch (e) {
      _log('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer info
  static Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      _log('Error getting customer info: $e');
      rethrow;
    }
  }

  /// Get available offerings (products)
  static Future<Offerings?> getOfferings() async {
    try {
      _log('📦 Fetching offerings from RevenueCat...');
      final offerings = await Purchases.getOfferings();

      _log('📋 Offerings fetched - Current offering: ${offerings.current?.identifier ?? "null"}');
      _log('📋 All offerings: ${offerings.all.keys.toList()}');

      final activeOffering = offerings.current ??
          offerings.getOffering(RevenueCatConfig.defaultOfferingId);

      if (activeOffering == null) {
        _log('⚠️ No current or default ("${RevenueCatConfig.defaultOfferingId}") offering available');
        _log(
          '⚠️ Check RevenueCat dashboard: mark an offering as Current or ensure the "${RevenueCatConfig.defaultOfferingId}" offering exists with products',
        );
        return null;
      }

      final packages = activeOffering.availablePackages;
      _log(
        '📦 Available packages in offering ${activeOffering.identifier}: ${packages.length}',
      );
      for (var package in packages) {
        _log('   - ${package.identifier}: ${package.storeProduct.title} (${package.storeProduct.priceString})');
      }

      return offerings;
    } on PlatformException catch (e) {
      _log('❌ Platform error fetching offerings: ${e.code} - ${e.message}');
      _log('📍 Details: $e');
      return null;
    } catch (e, stackTrace) {
      _log('❌ Error fetching offerings: $e');
      _log('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Purchase a package
  static Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      // ignore: deprecated_member_use
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        _log('User cancelled purchase');
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        _log('Product already purchased');
      }
      rethrow;
    }
  }

  /// Restore previous purchases
  static Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      _log('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Check if user is in trial period
  static Future<bool> isInTrialPeriod() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];

      if (entitlement == null || !entitlement.isActive) {
        return false;
      }

      // Check if it's a trial
      return entitlement.willRenew &&
          entitlement.periodType == PeriodType.trial;
    } catch (e) {
      _log('Error checking trial status: $e');
      return false;
    }
  }

  /// Get subscription expiration date
  static Future<DateTime?> getSubscriptionExpirationDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];

      final expDate = entitlement?.expirationDate;
      if (expDate is String) {
        return DateTime.tryParse(expDate);
      } else if (expDate is DateTime) {
        return expDate;
      }
      return null;
    } catch (e) {
      _log('Error getting expiration date: $e');
      return null;
    }
  }

  /// Check if subscription will renew
  static Future<bool> willRenew() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement =
          customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];

      return entitlement?.willRenew ?? false;
    } catch (e) {
      _log('Error checking renewal status: $e');
      return false;
    }
  }

  /// Add listener for customer info updates
  /// This enables real-time subscription status sync across devices
  /// The listener will be called whenever the subscription status changes
  static void addCustomerInfoUpdateListener(
    Function(CustomerInfo) onCustomerInfoUpdate,
  ) {
    try {
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _log('🔄 RevenueCat: Customer info updated');
        onCustomerInfoUpdate(customerInfo);
      });
      _log('✅ RevenueCat: Customer info listener added');
    } catch (e) {
      _log('❌ Error adding customer info listener: $e');
    }
  }

  /// Remove customer info update listener
  static void removeCustomerInfoUpdateListener(
    Function(CustomerInfo) listener,
  ) {
    try {
      Purchases.removeCustomerInfoUpdateListener(listener);
      _log('✅ RevenueCat: Customer info listener removed');
    } catch (e) {
      _log('❌ Error removing customer info listener: $e');
    }
  }
}
