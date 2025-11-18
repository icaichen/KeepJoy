import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/revenuecat_config.dart';

/// Service for managing RevenueCat subscriptions
class SubscriptionService {
  SubscriptionService._();

  /// Initialize RevenueCat with platform-specific API keys
  static Future<void> configure() async {
    try {
      // Enable debug logging in development
      await Purchases.setLogLevel(LogLevel.debug);

      // Get API key based on platform
      final String apiKey;
      if (Platform.isIOS) {
        apiKey = RevenueCatConfig.iosApiKey;
      } else if (Platform.isAndroid) {
        apiKey = RevenueCatConfig.androidApiKey;
      } else {
        print('⚠️ RevenueCat: Platform not supported');
        return;
      }

      // Configure RevenueCat
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      print('✅ RevenueCat configured successfully');
    } catch (e) {
      print('❌ RevenueCat configuration error: $e');
    }
  }

  /// Check if user has active premium subscription
  static Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      // Debug: Print all available entitlements
      print('🔍 All Entitlements: ${customerInfo.entitlements.all.keys.toList()}');
      print('🔍 Active Entitlements: ${customerInfo.entitlements.active.keys.toList()}');

      // Check if user has ANY active entitlement (in case the ID is wrong)
      if (customerInfo.entitlements.active.isNotEmpty) {
        print('✅ User has active entitlements: ${customerInfo.entitlements.active.keys.toList()}');
        // Return true if ANY entitlement is active
        return true;
      }

      // Fallback: Check specific premium entitlement
      final entitlement = customerInfo
          .entitlements.all[RevenueCatConfig.premiumEntitlementId];

      if (entitlement != null) {
        print('📦 Premium entitlement found - isActive: ${entitlement.isActive}');
        return entitlement.isActive;
      }

      print('⚠️ No premium entitlement found with ID: ${RevenueCatConfig.premiumEntitlementId}');
      return false;
    } catch (e) {
      print('❌ Error checking premium status: $e');
      return false;
    }
  }

  /// Get customer info
  static Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      print('Error getting customer info: $e');
      rethrow;
    }
  }

  /// Get available offerings (products)
  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        print('⚠️ No offerings available');
      }
      return offerings;
    } on PlatformException catch (e) {
      print('Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  static Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult.customerInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('User cancelled purchase');
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        print('Product already purchased');
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
      print('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Check if user is in trial period
  static Future<bool> isInTrialPeriod() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo
          .entitlements.all[RevenueCatConfig.premiumEntitlementId];
      
      if (entitlement == null || !entitlement.isActive) {
        return false;
      }

      // Check if it's a trial
      return entitlement.willRenew && entitlement.periodType == PeriodType.trial;
    } catch (e) {
      print('Error checking trial status: $e');
      return false;
    }
  }

  /// Get subscription expiration date
  static Future<DateTime?> getSubscriptionExpirationDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo
          .entitlements.all[RevenueCatConfig.premiumEntitlementId];
      
      final expDate = entitlement?.expirationDate;
      if (expDate is String) {
        return DateTime.tryParse(expDate);
      } else if (expDate is DateTime) {
        return expDate;
      }
      return null;
    } catch (e) {
      print('Error getting expiration date: $e');
      return null;
    }
  }

  /// Check if subscription will renew
  static Future<bool> willRenew() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo
          .entitlements.all[RevenueCatConfig.premiumEntitlementId];
      
      return entitlement?.willRenew ?? false;
    } catch (e) {
      print('Error checking renewal status: $e');
      return false;
    }
  }

  /// Listen to customer info updates
  /// Get stream of customer info updates
  /// Note: In newer versions of purchases_flutter, use Purchases.addCustomerInfoUpdateListener
  static Stream<CustomerInfo> get customerInfoStream async* {
    // Initial customer info
    yield await Purchases.getCustomerInfo();
    
    // Listen for updates - requires manual polling or using the listener callback
    // For now, just yield initial state
  }
}

