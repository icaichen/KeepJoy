import 'trial_service.dart';
import 'subscription_service.dart';

class PremiumAccessService {
  PremiumAccessService._();

  static Future<bool> hasPremiumAccess() async {
    try {
      // Check trial first
      final trialActive = await TrialService.isTrialActive();
      if (trialActive) {
        return true;
      }

      // Then check RevenueCat subscription
      final subscriptionActive = await SubscriptionService.isPremium();
      return subscriptionActive;
    } catch (_) {
      return false;
    }
  }

  static Future<int> trialDaysRemaining() => TrialService.trialDaysRemaining();
}
