
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:keepjoy_app/main.dart';
import 'package:keepjoy_app/features/auth/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OnboardingScreen renders 4 slides (Intro + 3 Mindset Groups) correctly', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Pump app
    await tester.pumpWidget(const KeepJoyApp(hasSeenOnboarding: false));
    await tester.pumpAndSettle();

    // 1. Verify Intro Slide
    // Allow animations
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text("Overwhelmed and don't know where to start?"), findsOneWidget);

    // 2. Navigate to Slide 2 (Decision Support)
    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();
    expect(find.text('Decision Support'), findsOneWidget);
    // Reset Grouping: Quick + Joy + Clean Sweep
    expect(find.text('Quick Declutter'), findsOneWidget);
    expect(find.text('Joy Declutter'), findsOneWidget);
    expect(find.text('Clean Sweep'), findsOneWidget);

    // 3. Navigate to Slide 3 (Total Control)
    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();
    expect(find.text('Total Control'), findsOneWidget);
    // Value Grouping: Items + Resell
    expect(find.text('Items'), findsOneWidget);
    expect(find.text('Resell'), findsOneWidget);

    // 4. Navigate to Slide 4 (Your Safety Net)
    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();
    expect(find.text('Your Safety Net'), findsOneWidget);
    // Heart Grouping: Memories
    expect(find.text('Memories'), findsOneWidget);

    // 5. Complete Onboarding
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    
    // Verify we land on Welcome Page
    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
