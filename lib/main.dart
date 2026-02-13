import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:keepjoy_app/features/onboarding/new_onboarding_screen.dart';
import 'features/auth/reset_password_page.dart';
import 'ui/paywall/paywall_page.dart';
import 'l10n/app_localizations.dart';
import 'theme/typography.dart';
import 'package:keepjoy_app/models/activity_entry.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepjoy_app/services/data_repository.dart';
import 'package:keepjoy_app/services/hive_service.dart';
import 'package:keepjoy_app/services/connectivity_service.dart';
import 'package:keepjoy_app/services/sync_service.dart';
import 'services/notification_service_stub.dart'
    if (dart.library.io) 'services/notification_service_mobile.dart';
import 'package:keepjoy_app/services/reminder_service.dart';
import 'services/premium_access_service.dart';
import 'services/subscription_service.dart';
import 'services/image_cache_service.dart';
import 'providers/subscription_provider.dart';
import 'config/flavor_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor (default to global for direct run)
  FlavorConfig.setFlavor(Flavor.global);

  // Initialize Hive local database
  await HiveService.instance.init();

  // Initialize connectivity monitoring
  await ConnectivityService.instance.init();

  // Initialize Supabase
  await AuthService.initialize();
  await NotificationService.instance.ensureInitialized();

  // Initialize RevenueCat (handles both subscriptions and trials)
  await SubscriptionService.configure();

  // Check onboarding status
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

  // If user is already logged in, login to RevenueCat and start sync
  final authService = AuthService();
  final currentUserId = authService.currentUserId;
  if (currentUserId != null) {
    try {
      await SubscriptionService.loginUser(currentUserId);
    } catch (e) {
      // Silently fail - not critical for app startup
    }

    // Initialize sync service and trigger initial sync
    await SyncService.instance.init();
    // Trigger initial sync immediately (connectivity is already initialized)
    SyncService.instance.syncAll();

    // Run automatic cache cleanup if needed (non-blocking)
    ImageCacheService.instance.autoCleanup().catchError((e) {
      print('Warning: Cache cleanup failed: $e');
    });

    // Run automatic database cleanup for old soft-deleted records (non-blocking)
    HiveService.instance.autoCleanupOldRecords().catchError((e) {
      print('Warning: Database cleanup failed: $e');
    });
  }

  runApp(KeepJoyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class KeepJoyApp extends StatefulWidget {
  final bool hasSeenOnboarding;

  const KeepJoyApp({super.key, this.hasSeenOnboarding = false});

  @override
  State<KeepJoyApp> createState() => _KeepJoyAppState();
}

class _KeepJoyAppState extends State<KeepJoyApp> with WidgetsBindingObserver {
  Locale? _locale;
  final _authService = AuthService();
  StreamSubscription? _authSubscription;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Listen to auth state changes
    _authSubscription = _authService.authStateChanges?.listen((event) {
      // Handle password reset flow - when user comes from email link
      // Supabase automatically handles code exchange, but we need to check
      // if we're in a password recovery flow
      final session = event.session;
      if (session != null && event.event == AuthChangeEvent.passwordRecovery) {
        // User is in password recovery mode - navigate to reset password page
        if (mounted) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/reset-password',
            (route) => false,
          );
        }
        return;
      }

      // When user logs out (session becomes null), navigate to welcome
      if (session == null &&
          mounted &&
          event.event == AuthChangeEvent.signedOut) {
        // User logged out - navigate to welcome and clear stack
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      }
      // Rebuild when auth state changes
      if (mounted) {
        setState(() {});
      }
    });

    // Check initial deep link for password reset
    _checkInitialDeepLink();
  }

  void _checkInitialDeepLink() {
    // Supabase SDK handles deep links automatically, but we can check
    // if we're starting from a password reset link
    final authService = AuthService();
    if (authService.client != null) {
      // Get the initial session to see if it's a recovery session
      final session = authService.client!.auth.currentSession;
      // Note: We'll handle password recovery in the auth state listener
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, trigger sync
    if (state == AppLifecycleState.resumed) {
      final authService = AuthService();
      if (authService.isAuthenticated) {
        SyncService.instance.onAppResumed();
      }
    }
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
        // Use home instead of initialRoute so it rebuilds on auth state change
        home: _authService.isAuthenticated
            ? MainNavigator(onLocaleChange: _setLocale)
            : const NewOnboardingScreen(),
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/reset-password': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args is Map<String, dynamic>) {
              return ResetPasswordPage(
                accessToken: args['access_token'] as String?,
                refreshToken: args['refresh_token'] as String?,
                type: args['type'] as String?,
                code: args['code'] as String?,
              );
            }
            return const ResetPasswordPage();
          },
          '/home': (context) => MainNavigator(onLocaleChange: _setLocale),
        },
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key, required this.onLocaleChange});

  final void Function(Locale) onLocaleChange;

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator>
    with WidgetsBindingObserver {
  final _authService = AuthService();
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
  void _rebuildActivityHistoryFromData() {
    final entries = <ActivityEntry>[];

    // Deep cleaning sessions
    for (final session in _completedSessions) {
      entries.add(
        ActivityEntry(
          type: ActivityType.deepCleaning,
          timestamp: session.startTime.toLocal(),
          description: session.area,
          itemCount: session.itemsCount,
        ),
      );
    }

    // Decluttered items (treat as joy declutter by default)
    for (final item in _declutteredItems) {
      entries.add(
        ActivityEntry(
          type: ActivityType.joyDeclutter,
          timestamp: item.createdAt.toLocal(),
          description: item.displayName(context),
          itemCount: 1,
        ),
      );
    }

    // Sort by time desc and keep latest 20
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _activityHistory
      ..clear()
      ..addAll(entries.take(20));
  }

  void _rebuildActivityDatesFromData() {
    _activityDates.clear();

    void addDate(DateTime dt) {
      final d = dt.toLocal();
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      _activityDates.add(dateStr);
    }

    for (final item in _declutteredItems) {
      addDate(item.createdAt);
    }
    for (final session in _completedSessions) {
      addDate(session.startTime);
    }
  }

  bool _hasFullAccess = false; // Default to false until verified
  StreamSubscription<SyncStatus>? _syncSubscription;
  DateTime? _lastLocalUpdate; // Track when user made a local change

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPremiumAccess();
    _loadUserData(); // 加载用户数据
    unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));

    // Listen to sync status changes
    _syncSubscription = SyncService.instance.statusStream.listen((status) {
      if (status == SyncStatus.success && mounted) {
        // Check if user made a local update in the last 3 seconds
        final now = DateTime.now();
        final recentLocalUpdate =
            _lastLocalUpdate != null &&
            now.difference(_lastLocalUpdate!).inSeconds < 3;

        if (recentLocalUpdate) {
          debugPrint(
            '✅ Sync completed, but skipping reload (recent local update)',
          );
        } else {
          debugPrint('✅ Sync completed, reloading data from other devices');
          _loadUserData();
        }
      }
    });

    // Listen to subscription provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      );
      subscriptionProvider.addListener(() {
        if (mounted) {
          setState(() {
            _hasFullAccess = subscriptionProvider.isPremium;
          });
        }
      });
    });
  }

  /// 从数据库加载所有用户数据
  Future<void> _loadUserData() async {
    debugPrint('📥 [LOAD] _loadUserData called - reloading all data from Hive');
    try {
      final repository = DataRepository();

      // 并行加载所有数据
      final results = await Future.wait([
        repository.fetchDeclutterItems(),
        repository.fetchMemories(),
        repository.fetchResellItems(),
        repository.fetchDeepCleaningSessions(),
        repository.fetchPlannedSessions(),
      ]);

      if (mounted) {
        setState(() {
          _declutteredItems.clear();
          _declutteredItems.addAll(results[0] as List<DeclutterItem>);

          _memories.clear();
          _memories.addAll(results[1] as List<Memory>);

          debugPrint(
            '📥 [LOAD] Replacing _resellItems with ${(results[2] as List<ResellItem>).length} items from Hive',
          );
          _resellItems.clear();
          _resellItems.addAll(results[2] as List<ResellItem>);

          // Log first few resell items to see their status
          for (var i = 0; i < _resellItems.length && i < 3; i++) {
            final item = _resellItems[i];
            debugPrint(
              '📥 [LOAD] ResellItem[$i]: id=${item.id}, status=${item.status.name}',
            );
          }

          _completedSessions.clear();
          _completedSessions.addAll(results[3] as List<DeepCleaningSession>);

          _plannedSessions.clear();
          _plannedSessions.addAll(results[4] as List<PlannedSession>);

          _rebuildActivityDatesFromData();
          _rebuildActivityHistoryFromData();
        });

        debugPrint(
          '✅ 用户数据加载成功: ${_declutteredItems.length} 个物品, ${_memories.length} 个回忆, ${_plannedSessions.length} 个计划',
        );
      }
    } catch (e) {
      debugPrint('❌ 加载用户数据失败: $e');
      // 不抛出错误，让应用继续运行
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshPremiumAccess() async {
    final hasAccess = await PremiumAccessService.hasPremiumAccess();

    if (!mounted) return;
    setState(() {
      _hasFullAccess = hasAccess;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_activeSession != null) {
        ReminderService.scheduleActiveSessionReminder(context);
      }
    } else if (state == AppLifecycleState.resumed) {
      ReminderService.cancelActiveSessionReminder();
      unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));
      _refreshPremiumAccess();
      // Reload data when app resumes to get any changes synced from other devices
      _loadUserData();
    }
  }

  String get _currentUserId {
    final userId = _authService.currentUserId;
    if (userId == null) {
      debugPrint(
        '❌ ERROR: _currentUserId called but user is null! Stack trace:',
      );
      debugPrint(StackTrace.current.toString());

      // User is logged out - immediately navigate to welcome
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/welcome', (route) => false);
        }
      });

      throw StateError(
        'MainNavigator requires an authenticated Supabase user.',
      );
    }
    return userId;
  }

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
        userId: _currentUserId,
        area: area,
        startTime: DateTime.now(),
        localBeforePhotoPath: beforePhotoPath,
        remoteBeforePhotoPath: null,
      );
    });
  }

  Future<void> _stopSession({
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  }) async {
    final session = _activeSession;
    if (session != null) {
      // Update session with metrics
      final updatedSession = session.copyWith(
        localAfterPhotoPath: afterPhotoPath,
        remoteAfterPhotoPath: null,
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

      // 保存到数据库
      try {
        final repository = DataRepository();
        final savedSession = await repository.createDeepCleaningSession(
          updatedSession,
        );

        setState(() {
          _completedSessions.insert(0, savedSession);

          // Mark corresponding planned session as completed
          final plannedSessionIndex = _plannedSessions.indexWhere(
            (s) =>
                !s.isCompleted &&
                s.area == updatedSession.area &&
                s.mode == SessionMode.deepCleaning,
          );

          if (plannedSessionIndex != -1) {
            final completedPlannedSession =
                _plannedSessions[plannedSessionIndex].copyWith(
                  isCompleted: true,
                  completedAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
            _plannedSessions[plannedSessionIndex] = completedPlannedSession;
            // 保存 PlannedSession 更新
            unawaited(repository.updatePlannedSession(completedPlannedSession));
          }
          _activeSession = null;
        });

        debugPrint('✅ 深度清洁会话已保存: ${savedSession.id}');
      } catch (e) {
        debugPrint('❌ 保存深度清洁会话失败: $e');
        // 失败时仍然保存到本地
        setState(() {
          _completedSessions.insert(0, updatedSession);
          _activeSession = null;
        });
      }

      ReminderService.cancelActiveSessionReminder();
      unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));
    }
  }

  Future<void> _addDeclutteredItem(DeclutterItem item) async {
    _lastLocalUpdate = DateTime.now(); // Track local update time

    // Record activity based on which flow created the item
    final localizedName = item.displayName(context);
    _recordActivity(
      ActivityType.joyDeclutter,
      description: localizedName,
      itemCount: 1,
    );

    // Update UI immediately
    setState(() {
      _declutteredItems.insert(0, item);
    });

    // Save to database in background (non-blocking)
    final repository = DataRepository();
    unawaited(
      repository
          .createDeclutterItem(item)
          .then((savedItem) {
            // Update with saved item if different
            setState(() {
              final index = _declutteredItems.indexWhere(
                (i) => i.id == item.id,
              );
              if (index != -1) {
                _declutteredItems[index] = savedItem;
              }

              // If item is marked for resell, create a ResellItem
              if (savedItem.status == DeclutterStatus.resell) {
                final resellItem = ResellItem(
                  id: const Uuid().v4(),
                  userId: _currentUserId,
                  declutterItemId: savedItem.id,
                  status: ResellStatus.toSell,
                  createdAt: DateTime.now(),
                );
                _resellItems.insert(0, resellItem);
                // 同时保存 resell item 到数据库
                unawaited(repository.createResellItem(resellItem));
              }
            });
            debugPrint('✅ 物品已保存到数据库: ${savedItem.id}');
          })
          .catchError((e) {
            debugPrint('❌ 保存物品失败: $e');
          }),
    );

    unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));
  }

  Future<void> _onItemCompleted(DeclutterItem item) async {
    try {
      final repository = DataRepository();
      await repository.updateDeclutterItem(item);

      // If status changed to resell, create ResellItem if not exists
      if (item.status == DeclutterStatus.resell) {
        final hasResellItem = _resellItems.any(
          (r) => r.declutterItemId == item.id,
        );
        if (!hasResellItem) {
          final resellItem = ResellItem(
            id: const Uuid().v4(),
            userId: _currentUserId,
            declutterItemId: item.id,
            status: ResellStatus.toSell,
            createdAt: DateTime.now(),
          );
          await repository.createResellItem(resellItem);
        }
      }

      // Reload from Hive immediately after save
      await _reloadDeclutterItems();
      await _reloadResellItems();
      debugPrint('✅ 物品已更新并重新加载: ${item.id}');
    } catch (e) {
      debugPrint('❌ 更新物品失败: $e');
    }
  }

  Future<void> _reloadDeclutterItems() async {
    final repository = DataRepository();
    final items = await repository.fetchDeclutterItems();
    if (mounted) {
      setState(() {
        _declutteredItems.clear();
        _declutteredItems.addAll(items);
      });
    }
  }

  Future<void> _updateResellItem(ResellItem item) async {
    try {
      debugPrint('🔄 开始更新转售物品: ${item.id}, status=${item.status.name}');
      _lastLocalUpdate = DateTime.now(); // Track local update time

      final repository = DataRepository();
      await repository.updateResellItem(item);

      // Reload from Hive immediately after save to get the updated item
      await _reloadResellItems();
      debugPrint('✅ 转售物品已更新并重新加载: ${item.id}');
    } catch (e) {
      debugPrint('❌ 更新转售物品失败: $e');
    }
  }

  Future<void> _reloadResellItems() async {
    final repository = DataRepository();
    final items = await repository.fetchResellItems();
    if (mounted) {
      setState(() {
        _resellItems.clear();
        _resellItems.addAll(items);
      });
    }
  }

  Future<void> _deleteResellItem(ResellItem item) async {
    try {
      _lastLocalUpdate = DateTime.now(); // Track local update time
      final repository = DataRepository();
      await repository.deleteResellItem(item.id);

      setState(() {
        _resellItems.removeWhere((r) => r.id == item.id);
      });
      debugPrint('✅ 转售物品已删除: ${item.id}');
    } catch (e) {
      debugPrint('❌ 删除转售物品失败: $e');
    }
  }

  Future<void> _deleteDeclutterItem(String itemId) async {
    try {
      _lastLocalUpdate = DateTime.now(); // Track local update time
      final repository = DataRepository();
      await repository.deleteDeclutterItem(itemId);

      setState(() {
        _declutteredItems.removeWhere((item) => item.id == itemId);
        _resellItems.removeWhere((r) => r.declutterItemId == itemId);
      });
      debugPrint('✅ 物品已删除: $itemId');
    } catch (e) {
      debugPrint('❌ 删除物品失败: $e');
    }
  }

  Future<void> _deleteDeepCleaningSession(DeepCleaningSession session) async {
    try {
      _lastLocalUpdate = DateTime.now(); // Track local update time
      final repository = DataRepository();
      await repository.deleteDeepCleaningSession(session.id);

      setState(() {
        _completedSessions.removeWhere((s) => s.id == session.id);
      });
      debugPrint('🗑️ 深度清洁会话已删除: ${session.id}');
    } catch (e) {
      debugPrint('❌ 删除深度清洁会话失败: $e');
    }
  }

  Future<void> _showUpgradeDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final isChinese = l10n.localeName.toLowerCase().startsWith('zh');

    // Get current subscription status to show appropriate message
    String message;
    try {
      final customerInfo = await SubscriptionService.getCustomerInfo();
      final premiumEntitlement = customerInfo.entitlements.all['premium'];

      if (premiumEntitlement != null && !premiumEntitlement.isActive) {
        // Had premium but it expired
        message = l10n.premiumExpiredMessage;
      } else {
        // Never had premium or trial ended
        message = l10n.premiumRequiredMessage;
      }
    } catch (e) {
      // Silently fail and show default message
      message = l10n.premiumRequiredMessage;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                l10n.premiumRequiredTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Upgrade Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => const PaywallPage(),
                        fullscreenDialog: true,
                      ),
                    );
                    _refreshPremiumAccess();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B5CE7), Color(0xFF5ECFB8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        isChinese ? '升级至高级版' : 'Upgrade to Premium',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel Button
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          hasFullAccess: _hasFullAccess,
          onRequestUpgrade: _showUpgradeDialog,
        ),
      ),
    );
  }

  Future<void> _onMemoryDeleted(Memory memory) async {
    try {
      final repository = DataRepository();
      await repository.deleteMemory(memory.id);

      setState(() {
        _memories.removeWhere((m) => m.id == memory.id);
      });
      debugPrint('✅ 回忆已删除: ${memory.id}');
    } catch (e) {
      debugPrint('❌ 删除回忆失败: $e');
    }
  }

  Future<void> _onMemoryUpdated(Memory memory) async {
    try {
      final repository = DataRepository();
      await repository.updateMemory(memory);

      setState(() {
        final index = _memories.indexWhere((m) => m.id == memory.id);
        if (index != -1) {
          _memories[index] = memory;
        }
      });
      debugPrint('✅ 回忆已更新: ${memory.id}');
    } catch (e) {
      debugPrint('❌ 更新回忆失败: $e');
    }
  }

  Future<void> _onMemoryCreated(Memory memory) async {
    // Update UI immediately
    setState(() {
      _memories.insert(0, memory);
    });

    // Save to database in background (non-blocking)
    final repository = DataRepository();
    unawaited(
      repository
          .createMemory(memory)
          .then((savedMemory) {
            // Update with saved memory if different
            setState(() {
              final index = _memories.indexWhere((m) => m.id == memory.id);
              if (index != -1) {
                _memories[index] = savedMemory;
              }
            });
            debugPrint('✅ 回忆已保存: ${savedMemory.id}');
          })
          .catchError((e) {
            debugPrint('❌ 保存回忆失败: $e');
          }),
    );
  }

  Future<void> _addPlannedSession(PlannedSession session) async {
    try {
      _lastLocalUpdate = DateTime.now(); // Track local update time
      final repository = DataRepository();
      final savedSession = await repository.createPlannedSession(session);

      setState(() {
        _plannedSessions.insert(0, savedSession);
      });
      debugPrint('✅ 计划任务已保存: ${savedSession.id}');
    } catch (e) {
      debugPrint('❌ 保存计划任务失败: $e');
      // 失败时仍然添加到本地
      setState(() {
        _plannedSessions.insert(0, session);
      });
    }

    unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));
  }

  Future<void> _deletePlannedSession(PlannedSession session) async {
    // Remove locally first so Dismissible items disappear immediately
    setState(() {
      _plannedSessions.removeWhere((s) => s.id == session.id);
    });

    try {
      _lastLocalUpdate = DateTime.now(); // Track local update time
      final repository = DataRepository();
      await repository.deletePlannedSession(session.id);
      debugPrint('✅ 计划任务已删除: ${session.id}');
    } catch (e) {
      debugPrint('❌ 删除计划任务失败: $e');
    }

    unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));
  }

  Future<void> _togglePlannedSession(PlannedSession session) async {
    try {
      final repository = DataRepository();
      final updatedSession = session.copyWith(
        isCompleted: !session.isCompleted,
        completedAt: !session.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );
      await repository.updatePlannedSession(updatedSession);

      // Reload from Hive immediately after save
      await _reloadPlannedSessions();
      debugPrint('✅ 计划任务状态已更新并重新加载: ${session.id}');
    } catch (e) {
      debugPrint('❌ 更新计划任务状态失败: $e');
    }

    unawaited(ReminderService.evaluateAndScheduleGeneralReminder(context));
  }

  Future<void> _reloadPlannedSessions() async {
    final repository = DataRepository();
    final sessions = await repository.fetchPlannedSessions();
    if (mounted) {
      setState(() {
        _plannedSessions.clear();
        _plannedSessions.addAll(sessions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Debug: Log when MainNavigator rebuilds
    debugPrint(
      '🔄 MainNavigator build - selectedIndex: $_selectedIndex, authenticated: ${_authService.isAuthenticated}',
    );

    // CRITICAL: If user is not authenticated, don't build MainNavigator
    // Navigate to welcome immediately
    if (!_authService.isAuthenticated) {
      debugPrint(
        '❌ User not authenticated in MainNavigator - navigating to welcome',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/welcome', (route) => false);
        }
      });
      // Return empty scaffold while navigating
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        onAddItem: _addDeclutteredItem,
        hasFullAccess: _hasFullAccess,
        onRequestUpgrade: () => _showUpgradeDialog(),
        onDeleteDeepCleaningSession: _deleteDeepCleaningSession,
      ),
      ItemsScreen(
        items: List.unmodifiable(_declutteredItems),
        onItemCompleted: _onItemCompleted,
        onMemoryCreated: _onMemoryCreated,
        onDeleteItem: _deleteDeclutterItem,
      ),
      // Placeholder for center button (not used)
      Center(child: Text(l10n.add)),
      ResellScreen(
        items: List.unmodifiable(_declutteredItems),
        resellItems: List.unmodifiable(_resellItems),
        onUpdateResellItem: _updateResellItem,
        onDeleteItem: _deleteDeclutterItem,
      ),
      MemoriesPage(
        memories: List.unmodifiable(_memories),
        onMemoryDeleted: _onMemoryDeleted,
        onMemoryUpdated: _onMemoryUpdated,
        onMemoryCreated: _onMemoryCreated,
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Prevent back navigation
        if (didPop) return;
      },
      child: Scaffold(
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
                  isScrollControlled: true,
                  builder: (sheetContext) {
                    final bottomPadding = MediaQuery.of(
                      sheetContext,
                    ).viewPadding.bottom;
                    return FractionallySizedBox(
                      heightFactor: 0.68,
                      child: Container(
                        margin: EdgeInsets.only(bottom: bottomPadding),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          color: Colors.white,
                        ),
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EA),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l10n.chooseFlowTitle,
                                      style: const TextStyle(
                                        fontFamily: 'SF Pro Display',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1C1E),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l10n.chooseFlowSubtitle,
                                      style: const TextStyle(
                                        fontFamily: 'SF Pro Text',
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildCleaningModeButton(
                                    icon: Icons.flash_on_rounded,
                                    title: l10n.quickDeclutterTitle,
                                    subtitle:
                                        l10n.quickDeclutterFlowDescription,
                                    buttonLabel: l10n.startAction,
                                    colors: const [
                                      Color(0xFFFF8A65),
                                      Color(0xFFFFB74D),
                                    ],
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      _openQuickDeclutter(context);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCleaningModeButton(
                                    icon: Icons.auto_awesome_rounded,
                                    title: l10n.joyDeclutterTitle,
                                    subtitle: l10n.joyDeclutterFlowDescription,
                                    buttonLabel: l10n.startAction,
                                    colors: const [
                                      Color(0xFF5B8CFF),
                                      Color(0xFF61D1FF),
                                    ],
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      _openJoyDeclutter(context);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCleaningModeButton(
                                    icon: Icons.cleaning_services_rounded,
                                    title: l10n.deepCleaningTitle,
                                    subtitle: l10n.deepCleaningFlowDescription,
                                    buttonLabel: l10n.startAction,
                                    colors: const [
                                      Color(0xFF34E27A),
                                      Color(0xFF0BBF75),
                                    ],
                                    onTap: () {
                                      // Deep cleaning is FREE - no premium check needed
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
          child: SafeArea(
            top: false,
            bottom: true,
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
                      icon: Icons.sell_outlined,
                      activeIcon: Icons.sell,
                      label: l10n.routeResell,
                      index: 3,
                      isActive: _selectedIndex == 3,
                      onTap: () => setState(() => _selectedIndex = 3),
                    ),
                  ),
                  Expanded(
                    child: _buildNavBarItem(
                      icon: Icons.bookmark_border,
                      activeIcon: Icons.bookmark,
                      label: l10n.memories,
                      index: 4,
                      isActive: _selectedIndex == 4,
                      onTap: () {
                        if (!_hasFullAccess) {
                          _showUpgradeDialog();
                          return;
                        }
                        setState(() => _selectedIndex = 4);
                      },
                    ),
                  ),
                ],
              ),
            ),
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
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
    required String buttonLabel,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Text',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getQuoteOfDay(AppLocalizations l10n) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final quotes = <String>[
      l10n.quote1,
      l10n.quote2,
      l10n.quote3,
      l10n.quote4,
      l10n.quote5,
      l10n.quote6,
      l10n.quote7,
      l10n.quote8,
      l10n.quote9,
      l10n.quote10,
      l10n.quote11,
      l10n.quote12,
      l10n.quote13,
      l10n.quote14,
      l10n.quote15,
    ];
    return quotes[dayOfYear % quotes.length];
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

  String? _activitySubtitle(ActivityEntry entry, AppLocalizations l10n) {
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
    return parts.join(l10n.activitySeparator);
  }

  String _formatActivityTime(DateTime timestamp, AppLocalizations l10n) {
    final formatter = DateFormat.yMMMd(l10n.localeName).add_jm();
    return formatter.format(timestamp);
  }

  void _showActivityHistory(BuildContext context, AppLocalizations l10n) {
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
                      l10n.noRecentActivity,
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
                      final subtitle = _activitySubtitle(entry, l10n);
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
                            _formatActivityTime(entry.timestamp, l10n),
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
                    l10n.startOrganizing,
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
                    subtitle: l10n.joyDeclutterModeSubtitle,
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
                    subtitle: l10n.quickDeclutterModeSubtitle,
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
                    subtitle: l10n.deepCleaningModeSubtitle,
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

    const headerHeight = 100.0;

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
                                // Top row: "Active Session" and current mode
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
                                      l10n.deepCleaningTitle,
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
                                                  builder: (_) => DeepCleaningTimerPage(
                                                    area: widget
                                                        .activeSession!
                                                        .area,
                                                    beforePhotoPath:
                                                        widget
                                                            .activeSession!
                                                            .localBeforePhotoPath ??
                                                        widget
                                                            .activeSession!
                                                            .remoteBeforePhotoPath,
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
                                                builder: (_) => DeepCleaningTimerPage(
                                                  area: widget
                                                      .activeSession!
                                                      .area,
                                                  beforePhotoPath:
                                                      widget
                                                          .activeSession!
                                                          .localBeforePhotoPath ??
                                                      widget
                                                          .activeSession!
                                                          .remoteBeforePhotoPath,
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

          // Collapsed header (appears when scrolling) - only this rebuilds on scroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                final scrollProgress = (scrollOffset / headerHeight).clamp(
                  0.0,
                  1.0,
                );
                final collapsedHeaderOpacity = scrollProgress >= 1.0
                    ? 1.0
                    : 0.0;
                return IgnorePointer(
                  ignoring: collapsedHeaderOpacity < 0.5,
                  child: Opacity(opacity: collapsedHeaderOpacity, child: child),
                );
              },
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

          // Original header (fades out when scrolling) - only this rebuilds on scroll
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, child) {
                final scrollOffset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                final scrollProgress = (scrollOffset / headerHeight).clamp(
                  0.0,
                  1.0,
                );
                final headerOpacity = (1.0 - scrollProgress).clamp(0.0, 1.0);
                return Opacity(opacity: headerOpacity, child: child);
              },
              child: SizedBox(
                height: 120,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 16,
                    top: topPadding + 12,
                  ),
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
                          Text(
                            l10n.startYourDeclutterJourney,
                            style: const TextStyle(
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
