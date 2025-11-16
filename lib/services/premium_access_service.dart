import 'package:keepjoy_app/services/subscription_service.dart';

import 'trial_service.dart';

class PremiumAccessService {
  PremiumAccessService._();

  static Future<bool> hasPremiumAccess() async {
    try {
      final trialActive = await TrialService.isTrialActive();
      if (trialActive) {
        return true;
      }
      final premium = await SubscriptionService.isPremium();
      return premium;
    } catch (_) {
      return false;
    }
  }

  static Future<int> trialDaysRemaining() => TrialService.trialDaysRemaining();
}
