
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keepjoy_app/features/onboarding/onboarding_screen.dart';
import 'package:keepjoy_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OnboardingScreen renders correctly and navigates', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: OnboardingScreen(),
      ),
    );

    // Pump and settle to allow localizations to load if needed (usually synchronous but good practice)
    await tester.pumpAndSettle();

    // Verify first slide
    expect(find.text('Spark Joy'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify second slide (Value Driven)
    expect(find.text('Value Driven'), findsOneWidget);
    
    // Tap Next twice more to get to last slide
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(); // Slide 3
    
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(); // Slide 4

    // Verify last slide and "Get Started" button
    expect(find.text('Mindful Living'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    
    // Tap Get Started
    // Note: We can't easily verify navigation to WelcomePage without mocking the route or using a navigator observer,
    // but we can verify the shared preference was set.
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_seen_onboarding'), true);
  });
}
