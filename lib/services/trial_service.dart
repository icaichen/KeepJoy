import 'package:shared_preferences/shared_preferences.dart';

class TrialService {
  TrialService._();

  static const _installDateKey = 'keepjoy_install_timestamp';
  static const int _trialDays = 7;

  static Future<void> ensureInitialized() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_installDateKey)) {
      await prefs.setInt(
        _installDateKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<bool> isTrialActive() async {
    final prefs = await SharedPreferences.getInstance();
    final install = prefs.getInt(_installDateKey);
    if (install == null) {
      return false;
    }
    final installDate = DateTime.fromMillisecondsSinceEpoch(install);
    final diff = DateTime.now().difference(installDate);
    return diff.inDays < _trialDays;
  }

  static Future<int> trialDaysRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final install = prefs.getInt(_installDateKey);
    if (install == null) {
      return 0;
    }
    final installDate = DateTime.fromMillisecondsSinceEpoch(install);
    final endDate = installDate.add(const Duration(days: _trialDays));
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }
}
