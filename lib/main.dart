import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'features/deep_cleaning/deep_cleaning_flow.dart';
import 'features/joy_declutter/joy_declutter_flow.dart';
import 'features/quick_declutter/quick_declutter_flow.dart';
import 'features/memories/memories_page.dart';
import 'features/profile/profile_page.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/items/items_screen.dart';
import 'features/resell/resell_screen.dart';
import 'features/memories/create_memory_page.dart';
import 'features/auth/welcome_page.dart';
import 'features/auth/login_page.dart';
import 'l10n/app_localizations.dart';
import 'theme/typography.dart';
import 'package:keepjoy_app/models/activity_entry.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await AuthService.initialize();

  runApp(const KeepJoyApp());
}

class KeepJoyApp extends StatefulWidget {
  const KeepJoyApp({super.key});

  @override
  State<KeepJoyApp> createState() => _KeepJoyAppState();
}

class _KeepJoyAppState extends State<KeepJoyApp> {
  Locale? _locale;
  final _authService = AuthService();

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
        fontFamily: AppTypography.primaryFont,
        fontFamilyFallback: AppTypography.chineseFallbacks,
        textTheme: AppTypography.textTheme,
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
      // Check if user is already authenticated
      initialRoute: _authService.isAuthenticated ? '/home' : '/welcome',
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => MainNavigator(onLocaleChange: _setLocale),
      },
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

  void _startSession(String area, {String? beforePhotoPath}) {
    setState(() {
      _activeSession = DeepCleaningSession(
        id: const Uuid().v4(),
        userId: _placeholderUserId,
        area: area,
        startTime: DateTime.now(),
        beforePhotoPath: beforePhotoPath,
      );
    });
  }

  void _stopSession({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  }) {
    final session = _activeSession;
    if (session != null) {
      // Update session with metrics
      final updatedSession = session.copyWith(
        afterPhotoPath: afterPhotoPath,
        elapsedSeconds: elapsedSeconds,
        itemsCount: itemsCount,
        focusIndex: focusIndex,
        moodIndex: moodIndex,
        beforeMessinessIndex: beforeMessinessIndex,
        afterMessinessIndex: afterMessinessIndex,
        updatedAt: DateTime.now(),
      );

      _recordActivity(
        ActivityType.deepCleaning,
        description: updatedSession.area,
        itemCount: updatedSession.itemsCount,
      );

      setState(() {
        // Save the completed session with metrics
        _completedSessions.insert(0, updatedSession);

        // Mark corresponding planned session as completed
        final plannedSessionIndex = _plannedSessions.indexWhere(
          (s) =>
              !s.isCompleted &&
              s.area == updatedSession.area &&
              s.mode == SessionMode.deepCleaning,
        );

        if (plannedSessionIndex != -1) {
          _plannedSessions[plannedSessionIndex] =
              _plannedSessions[plannedSessionIndex].copyWith(
                isCompleted: true,
                completedAt: DateTime.now(),
              );
        }
        _activeSession = null;
      });
    }
  }

  void _addDeclutteredItem(DeclutterItem item) {
    // Record activity based on which flow created the item
    _recordActivity(
      ActivityType.joyDeclutter,
      description: item.name,
      itemCount: 1,
    );
    setState(() {
      _declutteredItems.insert(0, item);

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

  void _onItemCompleted(DeclutterItem item) {
    // Handle item reassessment from Items page
    // All items are now in _declutteredItems, just update in place
    setState(() {
      final index = _declutteredItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _declutteredItems[index] = item;

        // If status changed to resell, create ResellItem if not exists
        if (item.status == DeclutterStatus.resell) {
          final hasResellItem = _resellItems.any(
            (r) => r.declutterItemId == item.id,
          );
          if (!hasResellItem) {
            final resellItem = ResellItem(
              id: 'resell_${DateTime.now().millisecondsSinceEpoch}',
              userId: _placeholderUserId,
              declutterItemId: item.id,
              status: ResellStatus.toSell,
              createdAt: DateTime.now(),
            );
            _resellItems.insert(0, resellItem);
          }
        }
      }
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

  void _deleteDeclutterItem(String itemId) {
    setState(() {
      _declutteredItems.removeWhere((item) => item.id == itemId);
      _resellItems.removeWhere((r) => r.declutterItemId == itemId);
    });
  }

  void _openQuickDeclutter(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            QuickDeclutterFlowPage(onItemCreated: _addDeclutteredItem),
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
      _plannedSessions.insert(
        0,
        session,
      ); // Add to beginning so it shows up first
    });
  }

  void _deletePlannedSession(PlannedSession session) {
    setState(() {
      _plannedSessions.removeWhere((s) => s.id == session.id);
    });
  }

  void _togglePlannedSession(PlannedSession session) {
    setState(() {
      final index = _plannedSessions.indexWhere((s) => s.id == session.id);
      if (index != -1) {
        _plannedSessions[index] = session.copyWith(
          isCompleted: !session.isCompleted,
          completedAt: !session.isCompleted ? DateTime.now() : null,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    final pages = [
      DashboardScreen(
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
        onDeletePlannedSession: _deletePlannedSession,
        onTogglePlannedSession: _togglePlannedSession,
        activityHistory: List.unmodifiable(_activityHistory),
        resellItems: _resellItems,
        deepCleaningSessions: _completedSessions,
        onMemoryCreated: _onMemoryCreated,
      ),
      ItemsScreen(
        items: List.unmodifiable(_declutteredItems),
        onItemCompleted: _onItemCompleted,
        onMemoryCreated: _onMemoryCreated,
        onDeleteItem: _deleteDeclutterItem,
      ),
      // Placeholder for center button (not used)
      const Center(child: Text('Add')),
      MemoriesPage(
        memories: List.unmodifiable(_memories),
        onMemoryDeleted: _onMemoryDeleted,
        onMemoryUpdated: _onMemoryUpdated,
        onMemoryCreated: _onMemoryCreated,
      ),
      ResellScreen(
        items: List.unmodifiable(_declutteredItems),
        resellItems: List.unmodifiable(_resellItems),
        onUpdateResellItem: _updateResellItem,
        onDeleteItem: _deleteDeclutterItem,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5ECFB8), Color(0xFF4EBAA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5ECFB8).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show cleaning mode selection
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (sheetContext) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Handle bar
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Joy Declutter
                            _buildCleaningModeButton(
                              icon: Icons.auto_awesome_rounded,
                              title: l10n.joyDeclutterTitle,
                              colors: [
                                const Color(0xFF3570FF),
                                const Color(0xFF1BCBFF),
                              ],
                              onTap: () {
                                Navigator.pop(sheetContext);
                                _openJoyDeclutter(context);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Quick Declutter
                            _buildCleaningModeButton(
                              icon: Icons.bolt_rounded,
                              title: l10n.quickDeclutterTitle,
                              colors: [
                                const Color(0xFFFF6CAB),
                                const Color(0xFFFF8F61),
                              ],
                              onTap: () {
                                Navigator.pop(sheetContext);
                                _openQuickDeclutter(context);
                              },
                            ),
                            const SizedBox(height: 16),

                            // Deep Cleaning
                            _buildCleaningModeButton(
                              icon: Icons.spa_rounded,
                              title: l10n.deepCleaningTitle,
                              colors: [
                                const Color(0xFF34E27A),
                                const Color(0xFF00B86B),
                              ],
                              onTap: () {
                                Navigator.pop(sheetContext);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DeepCleaningFlowPage(
                                      onStartSession: _startSession,
                                      onStopSession: _stopSession,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            customBorder: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l10n.home,
                  index: 0,
                  isActive: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
              ),
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: l10n.items,
                  index: 1,
                  isActive: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 80), // Space for FAB
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.bookmark_border,
                  activeIcon: Icons.bookmark,
                  label: l10n.memories,
                  index: 3,
                  isActive: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ),
              Expanded(
                child: _buildNavBarItem(
                  icon: Icons.sell_outlined,
                  activeIcon: Icons.sell,
                  label: isChinese ? '转售' : 'Resell',
                  index: 4,
                  isActive: _selectedIndex == 4,
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? const Color(0xFF5ECFB8) : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? const Color(0xFF5ECFB8)
                  : const Color(0xFF9CA3AF),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleaningModeButton({
    required IconData icon,
    required String title,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  final DeepCleaningSession? activeSession;
  final void Function({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  })
  onStopSession;
  final Function(String area, {String? beforePhotoPath}) onStartSession;
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

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  Timer? _timer;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    // Start a timer to update the UI every second if there's an active session
    if (widget.activeSession != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
    // Listen to scroll changes
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void didUpdateWidget(_HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle timer based on active session state
    if (widget.activeSession != null && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else if (widget.activeSession == null && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

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
    final activities = widget.activityHistory.take(5).toList();

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
    // Handle unscheduled tasks
    if (session.scheduledDate == null) {
      return "Unscheduled Task";
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(
      session.scheduledDate!.year,
      session.scheduledDate!.month,
      session.scheduledDate!.day,
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

  void _showCleaningModeSelection(BuildContext context, AppLocalizations l10n) {
    final isChinese = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    isChinese ? '开始整理' : 'Start Organizing',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Joy Declutter
                  _buildModeButton(
                    icon: Icons.auto_awesome_rounded,
                    title: l10n.joyDeclutterTitle,
                    subtitle: isChinese
                        ? '一次一件，用心感受'
                        : 'One item at a time, feel the joy',
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      widget.onOpenJoyDeclutter();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Quick Declutter
                  _buildModeButton(
                    icon: Icons.bolt_rounded,
                    title: l10n.quickDeclutterTitle,
                    subtitle: isChinese
                        ? '快速拍照，批量处理'
                        : 'Quick capture, batch process',
                    iconColor: const Color(0xFFEC4899),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      widget.onOpenQuickDeclutter();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Deep Cleaning
                  _buildModeButton(
                    icon: Icons.spa_rounded,
                    title: l10n.deepCleaningTitle,
                    subtitle: isChinese
                        ? '专注整理，焕然一新'
                        : 'Focused cleaning session',
                    iconColor: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeepCleaningFlowPage(
                            onStartSession: widget.onStartSession,
                            onStopSession: widget.onStopSession,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFF9CA3AF),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
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
    final topPadding = MediaQuery.of(context).padding.top;

    // Get quote of the day
    final quoteOfDay = _getQuoteOfDay(l10n);

    // Calculate scroll-based animations
    const headerHeight = 100.0;
    final scrollProgress = (_scrollOffset / headerHeight).clamp(0.0, 1.0);
    final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
    final collapsedHeaderOpacity = scrollProgress >= 1.0 ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header space
                const SizedBox(height: 120),

                // Purple Section - FULL WIDTH
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Color(0xFFF5F5F7)),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Streak Achievement (only show if there's a streak)
                      if (widget.streak > 0) ...[
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showActivityHistory(context, l10n),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(
                                    0xFFFDB022,
                                  ).withValues(alpha: 0.1),
                                  const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFFFDB022,
                                ).withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFDB022),
                                            Color(0xFFFFD700),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x40FDB022),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.streakAchievement,
                                            style: const TextStyle(
                                              fontFamily: 'SF Pro Display',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF111827),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '${widget.streak}',
                                                  style: const TextStyle(
                                                    fontFamily:
                                                        'SF Pro Display',
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFFFDB022),
                                                    height: 1.0,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ' ${widget.streak == 1 ? (Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh') ? '天' : 'day') : (Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh') ? '天' : 'days')}',
                                                  style: const TextStyle(
                                                    fontFamily: 'SF Pro Text',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFFD1D5DB),
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Day indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      List.generate(
                                        widget.streak > 14 ? 14 : widget.streak,
                                        (index) => Container(
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 3,
                                          ),
                                          width: widget.streak > 14 ? 6 : 8,
                                          height: widget.streak > 14 ? 6 : 8,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFDB022),
                                                Color(0xFFFFD700),
                                              ],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFFFDB022,
                                                ).withValues(alpha: 0.3),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )..addAll(
                                        widget.streak > 14
                                            ? [
                                                const SizedBox(width: 8),
                                                const Text(
                                                  '+',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'SF Pro Display',
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFFFDB022),
                                                  ),
                                                ),
                                              ]
                                            : [],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Quote Card
                      Container(
                        constraints: const BoxConstraints(maxWidth: 600),
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
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xDE000000), // black87
                                  letterSpacing: 0,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '- ${_getQuoteAttribution(quoteOfDay)}',
                                style: AppTypography.quoteAttribution.copyWith(
                                  color: const Color(0xFF757575), // grey600
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                                style: AppTypography.cardTitle.black87,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.whatBroughtYouJoy,
                                style: AppTypography.subtitle,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final memory = await Navigator.of(context)
                                        .push<Memory>(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CreateMemoryPage(),
                                          ),
                                        );

                                    if (memory != null && context.mounted) {
                                      // Call the onMemoryCreated callback from parent
                                      final mainState = context
                                          .findAncestorStateOfType<
                                            _MainNavigatorState
                                          >();
                                      mainState?._onMemoryCreated(memory);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.memoryCreated),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.sentiment_satisfied_alt,
                                    size: 18,
                                  ),
                                  label: Text(
                                    l10n.createMemory,
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0,
                                    ),
                                  ),
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
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xDE000000), // black87
                                      letterSpacing: 0,
                                      height: 1.0,
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
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Continue Your Session section (only show if active session exists)
                if (widget.activeSession != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                    ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Active Session',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0,
                                            color: const Color(0xFF111827),
                                          ),
                                    ),
                                    Text(
                                      'Deep Cleaning',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
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
                                                widget.activeSession!.startTime,
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
                                            '${widget.activeSession!.area} - ${l10n.inProgress}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Buttons side by side
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF414B5A),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                                        area: widget
                                                            .activeSession!
                                                            .area,
                                                        beforePhotoPath: widget
                                                            .activeSession!
                                                            .beforePhotoPath,
                                                        onStopSession: widget
                                                            .onStopSession,
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
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'Resume',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Stop button
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            // Navigate to timer page (finish cleaning flow)
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    DeepCleaningTimerPage(
                                                      area: widget
                                                          .activeSession!
                                                          .area,
                                                      beforePhotoPath: widget
                                                          .activeSession!
                                                          .beforePhotoPath,
                                                      onStopSession:
                                                          widget.onStopSession,
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
                                              vertical: 10,
                                            ),
                                            child: Icon(
                                              Icons.stop_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
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

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),

          // Collapsed header (appears when scrolling)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: collapsedHeaderOpacity < 0.5,
              child: Opacity(
                opacity: collapsedHeaderOpacity,
                child: Container(
                  height: topPadding + kToolbarHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F7),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5),
                    ),
                  ),
                  padding: EdgeInsets.only(top: topPadding),
                  alignment: Alignment.center,
                  child: const Text(
                    'KeepJoy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Original header (fades out when scrolling)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 16,
                  top: topPadding + 12,
                ),
                child: Opacity(
                  opacity: headerOpacity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Large greeting on the left
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                              letterSpacing: -0.5,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'ready to start your declutter joy',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                      // Profile Icon on the right
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                onLocaleChange: widget.onLocaleChange,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB794F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xE6FFFFFF), // 90% opacity
            height: 1.2,
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
