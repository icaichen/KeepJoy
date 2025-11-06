import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/gradient_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App Title
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              Text(
                l10n.welcomeTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Get Started Button
              GradientButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                width: double.infinity,
                height: 56,
                borderRadius: BorderRadius.circular(16),
                child: Text(l10n.getStarted),
              ),

              const SizedBox(height: 16),

              // Already have account
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  l10n.alreadyHaveAccount,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
