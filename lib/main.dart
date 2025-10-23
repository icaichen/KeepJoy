import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const KeepJoyApp());
}

class KeepJoyApp extends StatelessWidget {
  const KeepJoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KeepJoy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Chinese
      ],
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _HomeScreen(),
      _PlaceholderScreen(title: l10n.items),
      _PlaceholderScreen(title: l10n.memories),
      _PlaceholderScreen(title: l10n.insights),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: l10n.items,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.memories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: l10n.insights,
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  String _getQuoteOfDay(AppLocalizations l10n) {
    // Get day of year to determine which quote to show
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    // Cycle through 15 quotes based on day of year
    final quoteIndex = (dayOfYear % 15) + 1;

    // Use reflection-like approach to get quote
    switch (quoteIndex) {
      case 1: return l10n.quote1;
      case 2: return l10n.quote2;
      case 3: return l10n.quote3;
      case 4: return l10n.quote4;
      case 5: return l10n.quote5;
      case 6: return l10n.quote6;
      case 7: return l10n.quote7;
      case 8: return l10n.quote8;
      case 9: return l10n.quote9;
      case 10: return l10n.quote10;
      case 11: return l10n.quote11;
      case 12: return l10n.quote12;
      case 13: return l10n.quote13;
      case 14: return l10n.quote14;
      case 15: return l10n.quote15;
      default: return l10n.quote1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Get quote of the day
    final quoteOfDay = _getQuoteOfDay(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            Card(
              child: Container(
                height: screenHeight * 0.18, // 18% of screen height
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.1, // 10% of screen width
                      height: screenWidth * 0.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                      ),
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: 3.14159, // 180 degrees to flip it
                        child: Icon(
                          Icons.format_quote,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          quoteOfDay,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Continue Your Session section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Your Session',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Card(
                  child: Container(
                    height: screenHeight * 0.12, // 12% of screen height
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            // Start Declutter section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Declutter',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: screenHeight * 0.15, // 15% of screen height
                            alignment: Alignment.center,
                            child: Text('Joy Declutter'),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            height: screenHeight * 0.15,
                            alignment: Alignment.center,
                            child: Text('Deep Cleaning'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                Card(
                  child: InkWell(
                    onTap: () {},
                    child: Container(
                      height: screenHeight * 0.075, // 7.5% of screen height (half of above)
                      alignment: Alignment.center,
                      child: Text('Quick Declutter'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            // Monthly Achievement section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Achievement',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Container(
                          height: screenHeight * 0.15,
                          alignment: Alignment.center,
                          child: Text('Streak'),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Card(
                        child: Container(
                          height: screenHeight * 0.15,
                          alignment: Alignment.center,
                          child: Text('Item Decluttered'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    width: double.infinity,
                    child: Text('Room Cleaned'),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    width: double.infinity,
                    child: Text('Memory Created'),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Card(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    width: double.infinity,
                    child: Text('Items Resell'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
