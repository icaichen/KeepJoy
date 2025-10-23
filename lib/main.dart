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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            Card(
              child: Container(
                height: 150,
              ),
            ),
            const SizedBox(height: 24),
            // Start Declutter section
            Text(
              'Start Declutter',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: Text('Quick Declutter'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 120,
                        alignment: Alignment.center,
                        child: Text('Joy Declutter'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: () {},
                child: Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: Text('Deep Cleaning'),
                ),
              ),
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
