import 'package:flutter/widgets.dart';

/// Pops all routes above the `/home` route so the user returns to the main
/// application shell. Falls back to replacing the first route with `/home`
/// if the stack no longer contains it (e.g. after the welcome/login flow).
void popToHome(BuildContext context) {
  final navigator = Navigator.of(context);
  var foundHome = false;

  navigator.popUntil((route) {
    final isHome = route.settings.name == '/home';
    if (isHome) {
      foundHome = true;
    }
    return isHome || route.isFirst;
  });

  if (!foundHome && navigator.mounted) {
    navigator.pushReplacementNamed('/home');
  }
}
