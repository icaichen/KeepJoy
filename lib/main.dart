import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/deep_cleaning/deep_cleaning_flow.dart';
import 'features/joy_declutter/joy_declutter_flow.dart';
import 'features/quick_declutter/quick_declutter_flow.dart';
import 'features/calendar/activity_calendar_page.dart';
import 'features/calendar/add_session_dialog.dart';
import 'features/memories/memories_page.dart';
import 'features/profile/profile_page.dart';
import 'features/resell/resell_tracker_page.dart';
import 'l10n/app_localizations.dart';
import 'models/declutter_item.dart';
import 'models/memory.dart';
import 'models/resell_item.dart';
import 'models/planned_session.dart';

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
  final List<PlannedSession> _plannedSessions = [];
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

  void _addPlannedSession(PlannedSession session) {
    setState(() {
      _plannedSessions.add(session);
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
        declutteredItems: _declutteredItems,
        memories: _memories,
        plannedSessions: _plannedSessions,
        onAddPlannedSession: _addPlannedSession,
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
  final List<DeclutterItem> declutteredItems;
  final List<Memory> memories;
  final List<PlannedSession> plannedSessions;
  final void Function(PlannedSession) onAddPlannedSession;

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
    required this.declutteredItems,
    required this.memories,
    required this.plannedSessions,
    required this.onAddPlannedSession,
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

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 18) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  String _getDailyTagline(AppLocalizations l10n) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    // Cycle through 5 taglines based on day of year
    final taglineIndex = (dayOfYear % 5) + 1;

    switch (taglineIndex) {
      case 1:
        return l10n.tagline1;
      case 2:
        return l10n.tagline2;
      case 3:
        return l10n.tagline3;
      case 4:
        return l10n.tagline4;
      case 5:
        return l10n.tagline5;
      default:
        return l10n.tagline1;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatQuote(String quote) {
    // Remove " — Unknown" from the end if it exists
    if (quote.endsWith(' — Unknown')) {
      return quote.substring(0, quote.length - ' — Unknown'.length);
    }
    return quote;
  }

  String _getNextSessionTitle(PlannedSession session) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(
      session.scheduledDate.year,
      session.scheduledDate.month,
      session.scheduledDate.day,
    );
    final difference = sessionDate.difference(today).inDays;

    if (difference == 0) {
      return "Today's Session";
    } else if (difference == 1) {
      return "Tomorrow's Session";
    } else if (difference < 7) {
      return "Upcoming Session";
    } else {
      return "Scheduled Session";
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(l10n),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.readyToSparkJoy,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purple Section - FULL WIDTH
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6B5CE7), // Deeper purple
                    Color(0xFF5B4FC5), // Rich purple-blue
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section - Centered
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.welcomeBack,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDailyTagline(l10n),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // This Month's Progress Section with semi-transparent card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.thisMonthProgress,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _formatDate(DateTime.now()),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _WhiteProgressCard(
                                label: l10n.itemDecluttered,
                                value: '$declutteredCount',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _WhiteProgressCard(
                                label: l10n.areasCleared,
                                value: '0',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _WhiteProgressCard(
                                label: l10n.newValueCreated,
                                value: '¥${newValue.toStringAsFixed(0)}',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Streak Achievement
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDB022), // Gold color
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.streakAchievement,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.daysStreak(streak),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Declutter Calendar Widget (Planned Sessions)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.declutterCalendar,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ActivityCalendarPage(
                                declutteredItems: declutteredItems,
                                memories: memories,
                              ),
                            ),
                          );
                        },
                        child: Text(l10n.viewFull),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // Show next planned session or empty state
                  if (plannedSessions.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              l10n.startPlanningDeclutter,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final session = await showDialog<PlannedSession>(
                                    context: context,
                                    builder: (_) => const AddSessionDialog(),
                                  );
                                  if (session != null) {
                                    onAddPlannedSession(session);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.sessionCreated)),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: Text(l10n.addNew),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Show next upcoming session
                    Card(
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE9E3FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.access_time, color: Color(0xFF6B5CE7)),
                        ),
                        title: Text(_getNextSessionTitle(plannedSessions.first)),
                        subtitle: Text('${plannedSessions.first.title} • ${plannedSessions.first.scheduledTime}'),
                        trailing: TextButton(
                          onPressed: () {
                            // TODO: Implement reschedule
                          },
                          child: const Text('Reschedule'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Continue Your Session section (only show if active session exists)
              if (activeSession != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Column(
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
            ),
            // Start Declutter section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
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
            ),
            SizedBox(height: screenHeight * 0.03),

            // Daily Inspiration
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyInspiration,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.format_quote,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _formatQuote(quoteOfDay),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Recent Activities section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
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
    final statusLabel = status.label(context);
    final categoryLabel = item.category.label(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to item detail page if needed
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildThumbnail(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Status-specific info
                    if (isPending) ...[
                      Text(
                        _timeAgo(context, item.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      Text(
                        statusLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    const double size = 80;
    if (item.photoPath != null && item.photoPath!.isNotEmpty) {
      final file = File(item.photoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
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

class _WhiteProgressCard extends StatelessWidget {
  const _WhiteProgressCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 36,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Compact calendar widget for dashboard (showing current week/month)
class _CompactCalendarWidget extends StatelessWidget {
  const _CompactCalendarWidget({
    required this.onAddSession,
  });

  final VoidCallback onAddSession;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    final todayDate = DateTime(now.year, now.month, now.day);

    // TODO: Replace with actual planned sessions from database
    final plannedSessions = <DateTime>{
      DateTime(now.year, now.month, 5),
      DateTime(now.year, now.month, 12),
      DateTime(now.year, now.month, 14),
    };

    final quickSessions = <DateTime>{
      DateTime(now.year, now.month, 7),
    };

    final scheduledSessions = <DateTime>{
      DateTime(now.year, now.month, 16),
    };

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar days - compact view
        ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 32));
                }

                final date = DateTime(now.year, now.month, dayNumber);
                final isToday = date == todayDate;
                final hasPlannedSession = plannedSessions.contains(date);
                final hasQuickSession = quickSessions.contains(date);
                final hasScheduledSession = scheduledSessions.contains(date);

                Color? backgroundColor;
                if (hasScheduledSession) {
                  backgroundColor = const Color(0xFFB8A9F5); // Purple
                } else if (hasQuickSession) {
                  backgroundColor = const Color(0xFFA3C9F5); // Blue
                } else if (hasPlannedSession) {
                  backgroundColor = const Color(0xFFB5E5C4); // Green
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: onAddSession,
                    child: Container(
                      height: 32,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: isToday
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                                color: backgroundColor != null ? Colors.black87 : null,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(
              color: const Color(0xFFB5E5C4),
              label: 'Completed sessions',
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: const Color(0xFFA3C9F5),
              label: 'Quick sweep',
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: const Color(0xFFB8A9F5),
              label: 'Scheduled session',
            ),
          ],
        ),
      ],
    );
  }
}

/// Legend item for calendar
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}


