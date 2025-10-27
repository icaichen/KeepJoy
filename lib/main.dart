import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/deep_cleaning/deep_cleaning_flow.dart';
import 'features/joy_declutter/joy_declutter_flow.dart';
import 'features/quick_declutter/quick_declutter_flow.dart';
import 'features/memories/memories_page.dart';
import 'features/profile/profile_page.dart';
import 'features/resell/resell_tracker_page.dart';
import 'l10n/app_localizations.dart';
import 'models/declutter_item.dart';
import 'models/memory.dart';
import 'models/resell_item.dart';

// Model for active deep cleaning session
class DeepCleaningSession {
  final String area;
  final DateTime startTime;
  final String? beforePhotoPath;
  String? afterPhotoPath;
  int? elapsedSeconds;
  int? itemsCount;
  int? focusIndex;  // 1-10
  int? moodIndex;   // 1-10
  double? beforeMessinessIndex;  // AI analysis
  double? afterMessinessIndex;   // AI analysis

  DeepCleaningSession({
    required this.area,
    required this.startTime,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.elapsedSeconds,
    this.itemsCount,
    this.focusIndex,
    this.moodIndex,
    this.beforeMessinessIndex,
    this.afterMessinessIndex,
  });

  DeepCleaningSession copyWith({
    String? area,
    DateTime? startTime,
    String? beforePhotoPath,
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  }) {
    return DeepCleaningSession(
      area: area ?? this.area,
      startTime: startTime ?? this.startTime,
      beforePhotoPath: beforePhotoPath ?? this.beforePhotoPath,
      afterPhotoPath: afterPhotoPath ?? this.afterPhotoPath,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      itemsCount: itemsCount ?? this.itemsCount,
      focusIndex: focusIndex ?? this.focusIndex,
      moodIndex: moodIndex ?? this.moodIndex,
      beforeMessinessIndex: beforeMessinessIndex ?? this.beforeMessinessIndex,
      afterMessinessIndex: afterMessinessIndex ?? this.afterMessinessIndex,
    );
  }
}

void main() {
  runApp(const KeepJoyApp());
}

class KeepJoyApp extends StatefulWidget {
  const KeepJoyApp({super.key});

  @override
  State<KeepJoyApp> createState() => _KeepJoyAppState();
}

class _KeepJoyAppState extends State<KeepJoyApp> {
  Locale? _locale;

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KeepJoy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      locale: _locale,
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
      home: MainNavigator(onLocaleChange: _setLocale),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key, required this.onLocaleChange});

  final void Function(Locale) onLocaleChange;

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  DeepCleaningSession? _activeSession;
  final List<DeclutterItem> _pendingItems = [];
  final List<DeclutterItem> _declutteredItems = [];
  final List<Memory> _memories = [];
  final List<ResellItem> _resellItems = [];
  final Set<String> _activityDates = {}; // Track dates when user was active (format: yyyy-MM-dd)

  // Calculate streak (consecutive days of activity)
  int _calculateStreak() {
    if (_activityDates.isEmpty) return 0;

    final sortedDates = _activityDates.toList()..sort((a, b) => b.compareTo(a)); // Sort descending
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    int streak = 0;
    DateTime checkDate = today;

    // Start from today or most recent activity
    if (!sortedDates.contains(todayStr)) {
      // If no activity today, start from yesterday
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Count backwards from most recent activity
    while (true) {
      final checkDateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if (_activityDates.contains(checkDateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Calculate items decluttered this month
  int _calculateDeclutteredThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return _declutteredItems.where((item) {
      return item.createdAt.isAfter(monthStart) &&
             item.createdAt.isBefore(now.add(const Duration(days: 1)));
    }).length;
  }

  // Calculate total value of sold items this month
  double _calculateNewValueThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return _resellItems
        .where((item) =>
            item.status == ResellStatus.sold &&
            item.soldDate != null &&
            item.soldDate!.isAfter(monthStart) &&
            item.soldDate!.isBefore(now.add(const Duration(days: 1))))
        .fold(0.0, (sum, item) => sum + (item.soldPrice ?? 0.0));
  }

  // Record activity for today
  void _recordActivity() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    setState(() {
      _activityDates.add(todayStr);
    });
  }

  void _startSession(String area) {
    _recordActivity(); // Record activity for Deep Cleaning
    setState(() {
      _activeSession = DeepCleaningSession(
        area: area,
        startTime: DateTime.now(),
      );
    });
  }

  void _stopSession() {
    setState(() {
      _activeSession = null;
    });
  }

  void _addPendingItem(DeclutterItem item) {
    _recordActivity(); // Record activity for Quick Declutter
    setState(() {
      _pendingItems.insert(0, item);
    });
  }

  void _addDeclutteredItem(DeclutterItem item) {
    _recordActivity(); // Record activity for Joy Declutter
    setState(() {
      _declutteredItems.insert(0, item);
      _pendingItems.removeWhere((pending) => pending.id == item.id);

      // If item is marked for resell, create a ResellItem
      if (item.status == DeclutterStatus.resell) {
        final resellItem = ResellItem(
          id: 'resell_${DateTime.now().millisecondsSinceEpoch}',
          declutterItemId: item.id,
          status: ResellStatus.toSell,
          createdAt: DateTime.now(),
        );
        _resellItems.insert(0, resellItem);
      }

      // Note: Memory creation is now manual via Create Memory button or prompt after Joy Declutter
    });
  }

  void _updateResellItem(ResellItem item) {
    setState(() {
      final index = _resellItems.indexWhere((r) => r.id == item.id);
      if (index != -1) {
        _resellItems[index] = item;
      }
    });
  }

  void _deleteResellItem(ResellItem item) {
    setState(() {
      _resellItems.removeWhere((r) => r.id == item.id);
    });
  }

  void _openQuickDeclutter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuickDeclutterFlowPage(onItemCreated: _addPendingItem),
      ),
    );
  }

  void _openJoyDeclutter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JoyDeclutterFlowPage(
          onItemCompleted: _addDeclutteredItem,
          onMemoryCreated: _onMemoryCreated,
        ),
      ),
    );
  }

  void _onMemoryDeleted(Memory memory) {
    setState(() {
      _memories.removeWhere((m) => m.id == memory.id);
    });
  }

  void _onMemoryUpdated(Memory memory) {
    setState(() {
      final index = _memories.indexWhere((m) => m.id == memory.id);
      if (index != -1) {
        _memories[index] = memory;
      }
    });
  }

  void _onMemoryCreated(Memory memory) {
    setState(() {
      _memories.insert(0, memory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _HomeScreen(
        activeSession: _activeSession,
        onStopSession: _stopSession,
        onStartSession: _startSession,
        onOpenQuickDeclutter: () => _openQuickDeclutter(context),
        onOpenJoyDeclutter: () => _openJoyDeclutter(context),
        onLocaleChange: widget.onLocaleChange,
        streak: _calculateStreak(),
        declutteredCount: _calculateDeclutteredThisMonth(),
        newValue: _calculateNewValueThisMonth(),
      ),
      ItemsScreen(
        pendingItems: List.unmodifiable(_pendingItems),
        declutteredItems: List.unmodifiable(_declutteredItems),
      ),
      ResellTrackerPage(
        resellItems: List.unmodifiable(_resellItems),
        declutteredItems: List.unmodifiable(_declutteredItems),
        onUpdateResellItem: _updateResellItem,
        onDeleteResellItem: _deleteResellItem,
      ),
      MemoriesPage(
        memories: List.unmodifiable(_memories),
        onMemoryDeleted: _onMemoryDeleted,
        onMemoryUpdated: _onMemoryUpdated,
        onMemoryCreated: _onMemoryCreated,
      ),
      _PlaceholderScreen(title: l10n.insights),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_outlined),
            activeIcon: const Icon(Icons.grid_view),
            label: l10n.items,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money_outlined),
            activeIcon: const Icon(Icons.attach_money),
            label: l10n.resellTracker,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark_border),
            activeIcon: const Icon(Icons.bookmark),
            label: l10n.memories,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info_outline),
            activeIcon: const Icon(Icons.info),
            label: l10n.insights,
          ),
        ],
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  final DeepCleaningSession? activeSession;
  final VoidCallback onStopSession;
  final Function(String area) onStartSession;
  final VoidCallback onOpenQuickDeclutter;
  final VoidCallback onOpenJoyDeclutter;
  final void Function(Locale) onLocaleChange;
  final int streak;
  final int declutteredCount;
  final double newValue;

  const _HomeScreen({
    required this.activeSession,
    required this.onStopSession,
    required this.onStartSession,
    required this.onOpenQuickDeclutter,
    required this.onOpenJoyDeclutter,
    required this.onLocaleChange,
    required this.streak,
    required this.declutteredCount,
    required this.newValue,
  });

  String _getQuoteOfDay(AppLocalizations l10n) {
    // Get day of year to determine which quote to show
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    // Cycle through 15 quotes based on day of year
    final quoteIndex = (dayOfYear % 15) + 1;

    // Use reflection-like approach to get quote
    switch (quoteIndex) {
      case 1:
        return l10n.quote1;
      case 2:
        return l10n.quote2;
      case 3:
        return l10n.quote3;
      case 4:
        return l10n.quote4;
      case 5:
        return l10n.quote5;
      case 6:
        return l10n.quote6;
      case 7:
        return l10n.quote7;
      case 8:
        return l10n.quote8;
      case 9:
        return l10n.quote9;
      case 10:
        return l10n.quote10;
      case 11:
        return l10n.quote11;
      case 12:
        return l10n.quote12;
      case 13:
        return l10n.quote13;
      case 14:
        return l10n.quote14;
      case 15:
        return l10n.quote15;
      default:
        return l10n.quote1;
    }
  }

  String _getTimeAgo(BuildContext context, DateTime startTime) {
    final l10n = AppLocalizations.of(context)!;
    final duration = DateTime.now().difference(startTime);
    if (duration.inMinutes < 1) {
      return l10n.justNow;
    } else if (duration.inMinutes < 60) {
      return l10n.minsAgo(duration.inMinutes);
    } else if (duration.inHours < 24) {
      return l10n.hoursAgo(duration.inHours);
    } else {
      return l10n.daysAgo(duration.inDays);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfilePage(onLocaleChange: onLocaleChange),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card
            Card(
              color: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0B1220), Color(0xFF111827)],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.format_quote,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"$quoteOfDay"',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                          ),
                          const SizedBox(height: 12),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Continue Your Session section (only show if active session exists)
            if (activeSession != null)
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
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // House icon on the left
                              Container(
                                width: screenWidth * 0.12,
                                height: screenWidth * 0.12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.home, color: Colors.white),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              // Area and started info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${activeSession!.area} Deep Cleaning',
                                    ),
                                    Text(
                                      l10n.started(
                                        _getTimeAgo(
                                          context,
                                          activeSession!.startTime,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // In Progress badge
                              Text(l10n.inProgress),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Continue Session and Stop buttons
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      // Navigate back to timer
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DeepCleaningTimerPage(
                                            area: activeSession!.area,
                                            beforePhotoPath: activeSession!.beforePhotoPath,
                                            onStopSession: onStopSession,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.03,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(l10n.continueSession),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Card(
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          content: Text(
                                            l10n.deepCleaningSessionCompleted,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                onStopSession();
                                              },
                                              child: Text(l10n.ok),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                        screenWidth * 0.03,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(l10n.stop),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            // Start Declutter section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.startDeclutter,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: onOpenJoyDeclutter,
                          child: Container(
                            height: screenHeight * 0.15, // 15% of screen height
                            alignment: Alignment.center,
                            child: Text(l10n.joyDeclutterTitle),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Card(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DeepCleaningFlowPage(
                                  onStartSession: onStartSession,
                                  onStopSession: onStopSession,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: screenHeight * 0.15,
                            alignment: Alignment.center,
                            child: Text(l10n.deepCleaningTitle),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                Card(
                  child: InkWell(
                    onTap: onOpenQuickDeclutter,
                    child: Container(
                      height:
                          screenHeight *
                          0.075, // 7.5% of screen height (half of above)
                      alignment: Alignment.center,
                      child: Text(l10n.quickDeclutterTitle),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            // Recent Activities section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.recentActivities,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Container(
                          height: screenHeight * 0.15,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$streak',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.streak,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Card(
                        child: Container(
                          height: screenHeight * 0.15,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$declutteredCount',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.itemDecluttered,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Card(
                        child: Container(
                          height: screenHeight * 0.15,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¥${newValue.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.newValueCreated,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
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
                    child: Text(l10n.roomCleaned),
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
                    child: Text(l10n.memoryCreated),
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
                    child: Text(l10n.itemsResell),
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

enum ItemsSegment { toDeclutter, decluttered }

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({
    super.key,
    required this.pendingItems,
    required this.declutteredItems,
  });

  final List<DeclutterItem> pendingItems;
  final List<DeclutterItem> declutteredItems;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  ItemsSegment _segment = ItemsSegment.toDeclutter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    final pending = widget.pendingItems;
    final completed = widget.declutteredItems;

    final currentItems = _segment == ItemsSegment.toDeclutter
        ? pending
        : completed;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.items), centerTitle: false),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<ItemsSegment>(
              segments: [
                ButtonSegment(
                  value: ItemsSegment.toDeclutter,
                  label: Text(isChinese ? '待整理' : 'To Declutter'),
                ),
                ButtonSegment(
                  value: ItemsSegment.decluttered,
                  label: Text(isChinese ? '已整理' : 'Decluttered'),
                ),
              ],
              selected: <ItemsSegment>{_segment},
              onSelectionChanged: (selection) {
                setState(() {
                  _segment = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            _ItemsSummaryRow(
              pendingCount: pending.length,
              completedCount: completed.length,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: currentItems.isEmpty
                    ? _EmptyState(
                        key: ValueKey('empty-${_segment.name}'),
                        segment: _segment,
                        isChinese: isChinese,
                      )
                    : ListView.separated(
                        key: ValueKey(
                          'list-${_segment.name}-${currentItems.length}',
                        ),
                        itemCount: currentItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = currentItems[index];
                          final isPending =
                              _segment == ItemsSegment.toDeclutter;
                          return _ItemCard(item: item, isPending: isPending);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsSummaryRow extends StatelessWidget {
  const _ItemsSummaryRow({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: isChinese ? '待整理' : 'To Declutter',
            count: pendingCount,
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.hourglass_empty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: isChinese ? '已整理' : 'Decluttered',
            count: completedCount,
            color: Colors.teal,
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String title;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    '$count',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.isPending});

  final DeclutterItem item;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = isPending ? DeclutterStatus.pending : item.status;
    final statusColor = _statusColor(status, theme);
    final statusLabel = status.label(context);
    final categoryLabel = item.category.label(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(context),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        label: Text(statusLabel),
                        backgroundColor: statusColor.withValues(alpha: 0.15),
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categoryLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color == null
                          ? null
                          : theme.textTheme.bodySmall!.color!.withValues(
                              alpha: 0.7,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(context, item.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color == null
                          ? null
                          : theme.textTheme.bodySmall!.color!.withValues(
                              alpha: 0.6,
                            ),
                    ),
                  ),
                  if (!isPending &&
                      item.notes != null &&
                      item.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        item.notes!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    const double size = 60;
    if (item.photoPath != null && item.photoPath!.isNotEmpty) {
      final file = File(item.photoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.photo,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Color _statusColor(DeclutterStatus status, ThemeData theme) {
    switch (status) {
      case DeclutterStatus.pending:
        return theme.colorScheme.primary;
      case DeclutterStatus.keep:
        return Colors.teal;
      case DeclutterStatus.discard:
        return Colors.redAccent;
      case DeclutterStatus.donate:
        return Colors.orangeAccent;
      case DeclutterStatus.recycle:
        return Colors.blueAccent;
      case DeclutterStatus.resell:
        return Colors.purpleAccent;
    }
  }

  String _timeAgo(BuildContext context, DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 1) {
      return l10n.justNow;
    } else if (duration.inMinutes < 60) {
      return l10n.minsAgo(duration.inMinutes);
    } else if (duration.inHours < 24) {
      return l10n.hoursAgo(duration.inHours);
    } else {
      return l10n.daysAgo(duration.inDays);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.segment,
    required this.isChinese,
  });

  final ItemsSegment segment;
  final bool isChinese;

  @override
  Widget build(BuildContext context) {
    final title = segment == ItemsSegment.toDeclutter
        ? (isChinese ? '目前沒有待整理物品' : 'No items awaiting declutter')
        : (isChinese ? '尚未有整理完成的物品' : 'No decluttered items yet');
    final subtitle = segment == ItemsSegment.toDeclutter
        ? (isChinese
              ? '快使用「快速整理」記錄新物品吧。'
              : 'Use Quick Declutter to capture items that need decisions.')
        : (isChinese
              ? '透過「心動檢視」完成一次整理。'
              : 'Complete a Joy Declutter session to see results here.');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            segment == ItemsSegment.toDeclutter
                ? Icons.inbox_outlined
                : Icons.check_circle_outline,
            size: 72,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            width: 260,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              l10n.comingSoon,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
