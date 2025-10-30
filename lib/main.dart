import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'features/deep_cleaning/deep_cleaning_flow.dart';
import 'features/joy_declutter/joy_declutter_flow.dart';
import 'features/quick_declutter/quick_declutter_flow.dart';
import 'features/calendar/activity_calendar_page.dart';
import 'features/calendar/add_session_dialog.dart';
import 'features/memories/memories_page.dart';
import 'features/profile/profile_page.dart';
import 'features/resell/resell_tracker_page.dart';
import 'features/insights/insights_screen.dart';
import 'features/items/items_screen.dart';
import 'l10n/app_localizations.dart';
import 'package:keepjoy_app/models/activity_entry.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/planned_session.dart';

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
        fontFamily: 'SF Pro',
        fontFamilyFallback: const [
          'Source Han Sans CN',
          'Noto Sans SC',
          'PingFang SC',
          'Roboto',
          'Inter',
        ],
        // Cohesive Typography System
        textTheme: const TextTheme(
          // Display styles - for hero content
          displayLarge: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            height: 1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.3,
          ),
          // Headlines - for section titles
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.3,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            height: 1.3,
          ),
          // Titles - for card titles and important text
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.4,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            height: 1.4,
          ),
          // Body text - for regular content
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: 1.5,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            height: 1.4,
          ),
          // Labels - for buttons and small text
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.4,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.4,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
            height: 1.4,
          ),
        ),
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
  final List<DeepCleaningSession> _completedSessions = [];
  final List<ActivityEntry> _activityHistory = [];
  final Set<String> _activityDates =
      {}; // Track dates when user was active (format: yyyy-MM-dd)

  // Temporary placeholder userId until authentication is integrated
  // TODO: Replace with actual userId from AuthService after integration
  static const String _placeholderUserId = 'temp-user-id';

  // Calculate streak (consecutive days of activity)
  int _calculateStreak() {
    if (_activityDates.isEmpty) return 0;

    final sortedDates = _activityDates.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    int streak = 0;
    DateTime checkDate = today;

    // Start from today or most recent activity
    if (!sortedDates.contains(todayStr)) {
      // If no activity today, start from yesterday
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Count backwards from most recent activity
    while (true) {
      final checkDateStr =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
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
        .where(
          (item) =>
              item.status == ResellStatus.sold &&
              item.soldDate != null &&
              item.soldDate!.isAfter(monthStart) &&
              item.soldDate!.isBefore(now.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, item) => sum + (item.soldPrice ?? 0.0));
  }

  // Record activity for today
  void _recordActivity(
    ActivityType type, {
    String? description,
    int? itemCount,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    setState(() {
      _activityDates.add(dateStr);
      _activityHistory.insert(
        0,
        ActivityEntry(
          type: type,
          timestamp: now,
          description: description,
          itemCount: itemCount,
        ),
      );
      if (_activityHistory.length > 20) {
        _activityHistory.removeRange(20, _activityHistory.length);
      }
    });
  }

  void _startSession(String area) {
    setState(() {
      _activeSession = DeepCleaningSession(
        id: const Uuid().v4(),
        userId: _placeholderUserId,
        area: area,
        startTime: DateTime.now(),
      );
    });
  }

  void _stopSession() {
    final session = _activeSession;
    if (session != null) {
      _recordActivity(
        ActivityType.deepCleaning,
        description: session.area,
        itemCount: session.itemsCount,
      );
    }
    setState(() {
      if (session != null) {
        // Save the completed session
        _completedSessions.insert(0, session);
      }
      _activeSession = null;
    });
  }

  void _addPendingItem(DeclutterItem item) {
    _recordActivity(
      ActivityType.quickDeclutter,
      description: item.name,
      itemCount: 1,
    ); // Record activity for Quick Declutter
    setState(() {
      _pendingItems.insert(0, item);
    });
  }

  void _addDeclutteredItem(DeclutterItem item) {
    _recordActivity(
      ActivityType.joyDeclutter,
      description: item.name,
      itemCount: 1,
    ); // Record activity for Joy Declutter
    setState(() {
      _declutteredItems.insert(0, item);
      _pendingItems.removeWhere((pending) => pending.id == item.id);

      // If item is marked for resell, create a ResellItem
      if (item.status == DeclutterStatus.resell) {
        final resellItem = ResellItem(
          id: 'resell_${DateTime.now().millisecondsSinceEpoch}',
          userId: _placeholderUserId,
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
        activityHistory: List.unmodifiable(_activityHistory),
      ),
      ItemsScreen(
        items: List.unmodifiable([..._pendingItems, ..._declutteredItems]),
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
      InsightsScreen(
        declutteredItems: List.unmodifiable(_declutteredItems),
        resellItems: List.unmodifiable(_resellItems),
        deepCleaningSessions: List.unmodifiable(_completedSessions),
        streak: _calculateStreak(),
        memories: List.unmodifiable(_memories),
      ),
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
  final List<ActivityEntry> activityHistory;

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
    required this.activityHistory,
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

  String _getElapsedTime(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    const shortMonths = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${shortMonths[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData _iconForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.deepCleaning:
        return Icons.cleaning_services_rounded;
      case ActivityType.joyDeclutter:
        return Icons.favorite_border_rounded;
      case ActivityType.quickDeclutter:
        return Icons.flash_on_rounded;
    }
  }

  String _activityTitle(ActivityEntry entry, AppLocalizations l10n) {
    switch (entry.type) {
      case ActivityType.deepCleaning:
        return l10n.deepCleaning;
      case ActivityType.joyDeclutter:
        return l10n.joyDeclutterTitle;
      case ActivityType.quickDeclutter:
        return l10n.quickDeclutterTitle;
    }
  }

  String? _activitySubtitle(
    ActivityEntry entry,
    AppLocalizations l10n,
    bool isChinese,
  ) {
    final parts = <String>[];
    final description = entry.description?.trim();
    if (description != null && description.isNotEmpty) {
      parts.add(description);
    }
    if (entry.itemCount != null) {
      parts.add(l10n.itemsCount(entry.itemCount!));
    }
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(isChinese ? ' · ' : ' • ');
  }

  String _formatActivityTime(DateTime timestamp, bool isChinese) {
    final localeCode = isChinese ? 'zh_CN' : 'en_US';
    final pattern = isChinese ? 'M月d日 HH:mm' : 'MMM d, h:mm a';
    return DateFormat(pattern, localeCode).format(timestamp);
  }

  void _showActivityHistory(BuildContext context, AppLocalizations l10n) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
    final activities = activityHistory.take(5).toList();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.recentActivities,
                  style: sheetTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                if (activities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      isChinese
                          ? '近期还没有活动记录，继续加油！'
                          : 'No recent activity yet—keep going!',
                      style: sheetTheme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activities.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 24, color: Color(0xFFE5E7EB)),
                    itemBuilder: (_, index) {
                      final entry = activities[index];
                      final subtitle = _activitySubtitle(
                        entry,
                        l10n,
                        isChinese,
                      );
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _iconForActivity(entry.type),
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _activityTitle(entry, l10n),
                                  style: sheetTheme.textTheme.bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111827),
                                      ),
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: sheetTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xFF4B5563),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatActivityTime(entry.timestamp, isChinese),
                            style: sheetTheme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuickTips(BuildContext context, AppLocalizations l10n) {
    final tips = _getAllQuickTips(l10n);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.todaysTip,
                  style: sheetTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final tip = tips[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '•',
                          style: sheetTheme.textTheme.bodyLarge?.copyWith(
                            height: 1.4,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: sheetTheme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatQuote(String quote) {
    // Remove attribution from the end if it exists (— Author or — Unknown)
    final emDashIndex = quote.indexOf(' —');
    if (emDashIndex != -1) {
      return quote.substring(0, emDashIndex);
    }
    return quote;
  }

  String _getQuoteAttribution(String quote) {
    // Extract attribution from the quote
    final emDashIndex = quote.indexOf(' —');
    if (emDashIndex != -1) {
      return quote.substring(emDashIndex + 3); // Skip " — "
    }
    return '';
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

  String _getJoyCheckMessage(AppLocalizations l10n) {
    final messages = [
      l10n.joyCheckMessage1,
      l10n.joyCheckMessage2,
      l10n.joyCheckMessage3,
      l10n.joyCheckMessage4,
      l10n.joyCheckMessage5,
      l10n.joyCheckMessage6,
    ];
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return messages[dayOfYear % messages.length];
  }

  List<String> _getAllQuickTips(AppLocalizations l10n) {
    return [
      l10n.todaysTip1,
      l10n.todaysTip2,
      l10n.todaysTip3,
      l10n.todaysTip4,
      l10n.todaysTip5,
      l10n.todaysTip6,
    ];
  }

  String _getTodaysTip(AppLocalizations l10n) {
    final tips = _getAllQuickTips(l10n);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return tips[dayOfYear % tips.length];
  }

  String _getTodaysTipPreview(AppLocalizations l10n) {
    final tip = _getTodaysTip(l10n);
    // Return first 40 characters as preview
    if (tip.length <= 40) return tip;
    return '${tip.substring(0, 40)}...';
  }

  Widget _buildStartDeclutterGradientCard({
    required VoidCallback onTap,
    required List<Color> colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
    EdgeInsets padding = const EdgeInsets.all(16),
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors, begin: begin, end: end),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
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
        toolbarHeight: 80,
        title: Text(
          _getGreeting(l10n),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, size: 32),
            iconSize: 32,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfilePage(onLocaleChange: onLocaleChange),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F7),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Purple Section - FULL WIDTH
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section - Centered
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l10n.continueYourJoyJourney,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  height: 1.18,
                                  letterSpacing: 0.5,
                                ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _getDailyTagline(l10n),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF4C4F56),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  height: 1.4,
                                ),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // This Month's Progress Section with colored card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFA98EF1), // Deeper lavender purple
                          Color(0xFFB8A9F5), // Primary purple
                          Color(0xFFCFF8E8), // Mint accent
                        ],
                        stops: [0.0, 0.7, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Monthly Progress",
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _formatDate(DateTime.now()),
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xBFFFFFFF), // 75% opacity white
                                ),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
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
                                value: newValue.toStringAsFixed(0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Streak Achievement
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showActivityHistory(context, l10n),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF8FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDB022), // Gold color
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.streakAchievement,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.daysStreak(streak),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black45,
                            size: 28,
                          ),
                        ],
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.015),
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE1E7EF)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: "Active Session" and "Deep Cleaning"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Active Session',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0,
                                        color: const Color(0xFF111827),
                                      ),
                                ),
                                Text(
                                  'Deep Cleaning',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                        color: const Color(0xFF6B7280),
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Timer and location row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side: Timer and location
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Large timer display - single line
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _getElapsedTime(
                                            activeSession!.startTime,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                            height: 1.05,
                                            letterSpacing: -0.2,
                                            fontFeatures: [
                                              FontFeature.tabularFigures(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      // Location and status
                                      Text(
                                        '${activeSession!.area} - ${l10n.inProgress}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Right side: Buttons
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Resume button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF414B5A),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // Navigate back to timer
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DeepCleaningTimerPage(
                                                      area: activeSession!.area,
                                                      beforePhotoPath:
                                                          activeSession!
                                                              .beforePhotoPath,
                                                      onStopSession:
                                                          onStopSession,
                                                    ),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  'Resume',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Stop button (square)
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF414B5A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
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
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      onStopSession();
                                                    },
                                                    child: Text(l10n.ok),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.stop_rounded,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

            // Declutter Calendar Widget (Planned Sessions)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.declutterCalendar,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827),
                            ),
                      ),
                      TextButton.icon(
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
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.addNew),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Show next planned session or empty state - both are clickable to show calendar
                  if (plannedSessions.isEmpty)
                    _buildStartDeclutterGradientCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActivityCalendarPage(
                              declutteredItems: declutteredItems,
                              memories: memories,
                            ),
                          ),
                        );
                      },
                      colors: const [Color(0xFFF5F6FF), Color(0xFFE4E9FF)],
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.startPlanningDeclutter,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.9),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9DEFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF5C6BFF),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Show next upcoming session - clickable to show calendar
                    _buildStartDeclutterGradientCard(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActivityCalendarPage(
                              declutteredItems: declutteredItems,
                              memories: memories,
                            ),
                          ),
                        );
                      },
                      colors: const [Color(0xFFF5F6FF), Color(0xFFE4E9FF)],
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getNextSessionTitle(plannedSessions.first),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${plannedSessions.first.title} • ${plannedSessions.first.scheduledTime}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9E3FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: Color(0xFF6B5CE7),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Start Declutter section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.startDeclutter,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStartDeclutterGradientCard(
                          onTap: onOpenJoyDeclutter,
                          colors: const [Color(0xFF3570FF), Color(0xFF1BCBFF)],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.joyDeclutterTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: _buildStartDeclutterGradientCard(
                          onTap: onOpenQuickDeclutter,
                          colors: const [Color(0xFFFF6CAB), Color(0xFFFF8F61)],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.quickDeclutterTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  _buildStartDeclutterGradientCard(
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
                    colors: const [Color(0xFF34E27A), Color(0xFF00B86B)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.deepCleaningTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Daily Inspiration
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyInspiration,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quote Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4E8EF)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: const Color(0xFF9CA3AF),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatQuote(quoteOfDay),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                  color: const Color(0xFF374151),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '- ${_getQuoteAttribution(quoteOfDay)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Tip Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4E8EF)),
                    ),
                    child: InkWell(
                      onTap: () => _showQuickTips(context, l10n),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF4FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFF1F6FEB),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _getTodaysTipPreview(l10n),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: const Color(0xFF4B5563),
                                      height: 1.4,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Joy Check Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE4E8EF)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 22,
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.joyCheck,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF111827),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.whatBroughtYouJoy,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: const Color(0xFF4B5563)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle sharing joy
                              },
                              icon: const Icon(
                                Icons.sentiment_satisfied_alt,
                                size: 18,
                              ),
                              label: Text(l10n.shareYourJoy),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF414B5A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
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
  const _WhiteProgressCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xBFFFFFFF), // 75% opacity white
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
        ),
      ],
    );
  }
}

/// Compact calendar widget for dashboard (showing current week/month)
class _CompactCalendarWidget extends StatelessWidget {
  const _CompactCalendarWidget({required this.onAddSession});

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

    final quickSessions = <DateTime>{DateTime(now.year, now.month, 7)};

    final scheduledSessions = <DateTime>{DateTime(now.year, now.month, 16)};

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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 12,
                                color: backgroundColor != null
                                    ? Colors.black87
                                    : null,
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
            _LegendItem(color: const Color(0xFFA3C9F5), label: 'Quick sweep'),
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
  const _LegendItem({required this.color, required this.label});

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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
