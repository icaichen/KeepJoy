import 'subscription_service.dart';

/// Service for checking premium access
/// Trial is managed by App Store/Google Play through RevenueCat
class PremiumAccessService {
  PremiumAccessService._();

  /// Check if user has premium access (either active subscription or trial)
  /// Trial is controlled by App Store/Google Play via RevenueCat, not locally
  static Future<bool> hasPremiumAccess() async {
    try {
      // Check RevenueCat for both subscription and trial status
      final isPremium = await SubscriptionService.isPremium();
      return isPremium;
    } catch (_) {
      return false;
    }
  }

  /// Get remaining trial days from RevenueCat subscription
  static Future<int> trialDaysRemaining() async {
    try {
      final isInTrial = await SubscriptionService.isInTrialPeriod();
      if (!isInTrial) return 0;

      final expirationDate =
          await SubscriptionService.getSubscriptionExpirationDate();
      if (expirationDate == null) return 0;

      final remaining = expirationDate.difference(DateTime.now()).inDays;
      return remaining > 0 ? remaining : 0;
    } catch (_) {
      return 0;
    }
  }
}
