import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepjoy_app/services/auth_service.dart';
import 'package:keepjoy_app/services/hive_service.dart';
import 'package:keepjoy_app/services/connectivity_service.dart';
import 'package:keepjoy_app/services/storage_service.dart';
import 'package:keepjoy_app/services/image_compression_service.dart';
import 'package:keepjoy_app/services/pending_task_service.dart';
import 'package:keepjoy_app/models/hive/memory_hive.dart';
import 'package:keepjoy_app/models/hive/deep_cleaning_session_hive.dart';
import 'package:keepjoy_app/models/hive/declutter_item_hive.dart';
import 'package:keepjoy_app/models/hive/resell_item_hive.dart';
import 'package:keepjoy_app/models/hive/planned_session_hive.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/models/pending_task.dart';

/// Sync status for UI feedback
enum SyncStatus { idle, syncing, success, error }

/// Sync Service
/// Handles bidirectional sync between Hive local database and Supabase
class SyncService {
  static const _memoriesSyncKey = 'memories_remote_sync';
  static const _sessionsSyncKey = 'sessions_remote_sync';
  static const _itemsSyncKey = 'declutter_remote_sync';
  static const _resellSyncKey = 'resell_remote_sync';
  static const _plannedSyncKey = 'planned_sessions_remote_sync';

  static SyncService? _instance;
  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }

  SyncService._();

  final _authService = AuthService();
  final _hiveService = HiveService.instance;
  final _connectivityService = ConnectivityService.instance;
  final _storageService = StorageService();
  final _pendingTaskService = PendingTaskService.instance;

  SupabaseClient? get _client => _authService.client;
  String? get _userId => _authService.currentUserId;

  Timer? _cloudPullTimer; // 5-minute cloud→local pull (fallback)
  Timer? _pendingTaskTimer; // periodic pending-task upload worker
  Timer? _scheduledSyncTimer; // debounce for syncAll triggers
  Timer? _scheduledPullTimer; // debounce for pullFromCloud triggers
  bool _isSyncing = false;
  bool _isPulling = false;
  StreamSubscription? _connectivitySubscription;
  final List<RealtimeChannel> _realtimeChannels = [];

  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  /// Initialize sync service
  Future<void> init() async {
    debugPrint('🔄 Initializing sync service...');

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        debugPrint('🌐 Connection restored, scheduling sync...');
        scheduleSync(delay: const Duration(milliseconds: 500));
      }
    });

    // Start sync timers
    _startCloudPullTimer(); // 5-minute cloud→local (fallback)
    _startPendingTaskProcessor(); // periodic local→cloud

    // Setup Realtime subscriptions
    await _setupRealtimeSubscriptions();

    debugPrint('✅ Sync service initialized');
  }

  /// 5-minute cloud→local pull cycle (fallback)
  void _startCloudPullTimer() {
    _cloudPullTimer?.cancel();
    _cloudPullTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => pullFromCloud(),
    );
  }

  /// 5-second local→cloud upload cycle
  void _startPendingTaskProcessor() {
    _pendingTaskTimer?.cancel();
    _pendingTaskTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _processPendingTasks(),
    );
  }

  /// Debounced sync trigger. Multiple calls during [delay] collapse into one.
  void scheduleSync({Duration delay = const Duration(seconds: 3)}) {
    _scheduledSyncTimer?.cancel();
    _scheduledSyncTimer = Timer(delay, () {
      _scheduledSyncTimer = null;
      syncAll();
    });
  }

  void _schedulePullFromCloud({
    Duration delay = const Duration(milliseconds: 800),
  }) {
    _scheduledPullTimer?.cancel();
    _scheduledPullTimer = Timer(delay, () {
      _scheduledPullTimer = null;
      pullFromCloud();
    });
  }

  /// Pull changes from cloud (called every 5 minutes or by Realtime trigger)
  Future<void> pullFromCloud() async {
    if (_isPulling) return;
    if (!_connectivityService.isConnected) return;
    if (_userId == null || _client == null) return;

    _isPulling = true;
    try {
      debugPrint('🔄 [PULL] Starting cloud pull...');
      final hadChanges = await _downloadRemoteData();
      if (hadChanges) {
        debugPrint('🔄 [PULL] Data changed, notifying UI to reload');
        _setStatus(SyncStatus.success);
      } else {
        debugPrint('🔄 [PULL] No changes detected');
      }
    } catch (e) {
      debugPrint('❌ Cloud pull failed: $e');
    } finally {
      _isPulling = false;
    }
  }

  /// Set sync status
  void _setStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  Future<void> _updateLastRemoteSync(String key, DateTime? timestamp) async {
    if (timestamp == null) return;
    await _hiveService.saveLastRemoteSync(key, timestamp);
  }

  DateTime? _maxTimestamp(DateTime? current, DateTime? candidate) {
    if (candidate == null) return current;
    if (current == null || candidate.isAfter(current)) {
      return candidate;
    }
    return current;
  }

  /// Sync all data
  Future<void> syncAll() async {
    debugPrint('🔄 syncAll() called');
    debugPrint('   - _isSyncing: $_isSyncing');
    debugPrint('   - isConnected: ${_connectivityService.isConnected}');
    debugPrint('   - userId: $_userId');
    debugPrint('   - client: ${_client != null ? "exists" : "null"}');

    if (_isSyncing) {
      debugPrint('⚠️ Sync already in progress');
      return;
    }

    if (!_connectivityService.isConnected) {
      debugPrint('📴 No network connection, skipping sync');
      return;
    }

    if (_userId == null || _client == null) {
      debugPrint('⚠️ User not authenticated, skipping sync');
      debugPrint('   - userId is null: ${_userId == null}');
      debugPrint('   - client is null: ${_client == null}');
      return;
    }

    _isSyncing = true;
    _setStatus(SyncStatus.syncing);

    try {
      debugPrint('🔄 Starting full sync...');
      final stopwatch = Stopwatch()..start();

      // Upload local changes first (local-first)
      await _uploadDirtyData();

      // Then download remote changes
      await _downloadRemoteData();

      stopwatch.stop();
      debugPrint('✅ Sync completed in ${stopwatch.elapsedMilliseconds}ms');
      _setStatus(SyncStatus.success);
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      _setStatus(SyncStatus.error);
    } finally {
      _isSyncing = false;
    }
  }

  // ==========================================================================
  // UPLOAD (Local -> Cloud)
  // ==========================================================================

  Future<void> _uploadDirtyData() async {
    debugPrint('⬆️ [PUSH] Uploading dirty data...');

    final dirtyMemories = _hiveService.getDirtyMemories();
    debugPrint('   Found ${dirtyMemories.length} dirty memories');
    for (final memory in dirtyMemories) {
      await _processUploadTask(
        type: PendingTaskType.memoryUpload,
        entityId: memory.id,
        payload: _memoryPayload(memory),
        action: () => _uploadMemory(memory),
      );
    }

    final dirtySessions = _hiveService.getDirtySessions();
    debugPrint('   Found ${dirtySessions.length} dirty sessions');
    for (final session in dirtySessions) {
      await _processUploadTask(
        type: PendingTaskType.deepCleaningUpload,
        entityId: session.id,
        payload: _sessionPayload(session),
        action: () => _uploadSession(session),
      );
    }

    final dirtyItems = _hiveService.getDirtyItems();
    debugPrint('   Found ${dirtyItems.length} dirty items');
    for (final item in dirtyItems) {
      await _processUploadTask(
        type: PendingTaskType.declutterUpload,
        entityId: item.id,
        payload: _declutterPayload(item),
        action: () => _uploadItem(item),
      );
    }

    final dirtyResellItems = _hiveService.getDirtyResellItems();
    debugPrint('   Found ${dirtyResellItems.length} dirty resell items');
    for (final item in dirtyResellItems) {
      await _processUploadTask(
        type: PendingTaskType.resellUpload,
        entityId: item.id,
        payload: _resellPayload(item),
        action: () => _uploadResellItem(item),
      );
    }

    final dirtyPlannedSessions = _hiveService.getDirtyPlannedSessions();
    debugPrint('   Found ${dirtyPlannedSessions.length} dirty planned sessions');
    for (final session in dirtyPlannedSessions) {
      await _processUploadTask(
        type: PendingTaskType.plannedSessionUpload,
        entityId: session.id,
        payload: _plannedPayload(session),
        action: () => _uploadPlannedSession(session),
      );
    }

    debugPrint('✅ [PUSH] Upload complete');
  }

  Map<String, dynamic> _memoryPayload(MemoryHive memory) =>
      memory.toMemory().toJson();

  Map<String, dynamic> _sessionPayload(DeepCleaningSessionHive session) =>
      session.toSession().toJson();

  Map<String, dynamic> _declutterPayload(DeclutterItemHive item) =>
      item.toItem().toJson();

  Map<String, dynamic> _resellPayload(ResellItemHive item) =>
      item.toItem().toJson();

  Map<String, dynamic> _plannedPayload(PlannedSessionHive session) =>
      session.toSession().toJson();

  Future<void> _processUploadTask({
    required PendingTaskType type,
    required String entityId,
    required Map<String, dynamic> payload,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
      await _pendingTaskService.clearTask(type, entityId);
    } catch (e) {
      debugPrint('❌ Upload failed for ${type.name}:$entityId - $e');
      await _pendingTaskService.recordFailure(
        type: type,
        entityId: entityId,
        payload: payload,
      );
    }
  }

  Future<void> _processPendingTasks() async {
    if (!_connectivityService.isConnected) return;
    final dueTasks = _pendingTaskService.getDueTasks(DateTime.now());
    if (dueTasks.isEmpty) return;

    for (final task in dueTasks) {
      await _executePendingTask(task);
    }
  }

  Future<void> _executePendingTask(PendingTask task) async {
    final entityId = task.entityId;
    switch (task.type) {
      case PendingTaskType.memoryUpload:
        final memory = _hiveService.getMemory(entityId);
        if (memory == null) {
          await _pendingTaskService.clearTask(task.type, entityId);
          return;
        }
        await _processUploadTask(
          type: PendingTaskType.memoryUpload,
          entityId: entityId,
          payload: _memoryPayload(memory),
          action: () => _uploadMemory(memory),
        );
        break;
      case PendingTaskType.deepCleaningUpload:
        final session = _hiveService.getSession(entityId);
        if (session == null) {
          await _pendingTaskService.clearTask(task.type, entityId);
          return;
        }
        await _processUploadTask(
          type: PendingTaskType.deepCleaningUpload,
          entityId: entityId,
          payload: _sessionPayload(session),
          action: () => _uploadSession(session),
        );
        break;
      case PendingTaskType.declutterUpload:
        final item = _hiveService.getItem(entityId);
        if (item == null) {
          await _pendingTaskService.clearTask(task.type, entityId);
          return;
        }
        await _processUploadTask(
          type: PendingTaskType.declutterUpload,
          entityId: entityId,
          payload: _declutterPayload(item),
          action: () => _uploadItem(item),
        );
        break;
      case PendingTaskType.resellUpload:
        final resell = _hiveService.getResellItem(entityId);
        if (resell == null) {
          await _pendingTaskService.clearTask(task.type, entityId);
          return;
        }
        await _processUploadTask(
          type: PendingTaskType.resellUpload,
          entityId: entityId,
          payload: _resellPayload(resell),
          action: () => _uploadResellItem(resell),
        );
        break;
      case PendingTaskType.plannedSessionUpload:
        final planned = _hiveService.getPlannedSession(entityId);
        if (planned == null) {
          await _pendingTaskService.clearTask(task.type, entityId);
          return;
        }
        await _processUploadTask(
          type: PendingTaskType.plannedSessionUpload,
          entityId: entityId,
          payload: _plannedPayload(planned),
          action: () => _uploadPlannedSession(planned),
        );
        break;
    }
  }

  Future<void> _uploadMemory(MemoryHive memoryHive) async {
    final memory = memoryHive.toMemory();

    // Handle image upload if needed - only upload local files
    String? cloudPhotoUrl = memory.remotePhotoPath;
    if (memory.localPhotoPath != null &&
        memory.localPhotoPath!.isNotEmpty &&
        !memory.localPhotoPath!.startsWith('http')) {
      // Local file needs upload
      final file = File(memory.localPhotoPath!);
      if (file.existsSync()) {
        final compressed = await ImageCompressionService.compressMemoryImage(
          file,
        );
        cloudPhotoUrl = await _storageService.uploadMemoryImage(compressed);
      }
    }

    final data = memory.toJson();
    data['photo_path'] = cloudPhotoUrl;

    // Always upsert (including soft deletes) - never hard delete
    // This ensures deletedAt timestamp is synced to cloud for conflict resolution
    await _client!.from('memories').upsert(data);

    // Update local Hive with cloud URL - KEEP local path unchanged
    memoryHive.remotePhotoPath = cloudPhotoUrl;
    // DO NOT touch localPhotoPath - this is the key to local-first
    memoryHive.markSynced();
    await memoryHive.save();

    if (memoryHive.deletedAt != null) {
      debugPrint('⬆️ Uploaded soft-deleted memory: ${memory.id}');
    } else {
      debugPrint('⬆️ Uploaded memory: ${memory.id}');
    }
  }

  Future<void> _uploadSession(DeepCleaningSessionHive sessionHive) async {
    final session = sessionHive.toSession();

    // Handle before photo upload - only upload local files
    String? cloudBeforeUrl = session.remoteBeforePhotoPath;
    if (session.localBeforePhotoPath != null &&
        !session.localBeforePhotoPath!.startsWith('http')) {
      final file = File(session.localBeforePhotoPath!);
      if (file.existsSync()) {
        final compressed = await ImageCompressionService.compressSessionImage(
          file,
        );
        cloudBeforeUrl = await _storageService.uploadSessionImage(compressed);
      }
    }

    // Handle after photo upload - only upload local files
    String? cloudAfterUrl = session.remoteAfterPhotoPath;
    if (session.localAfterPhotoPath != null &&
        !session.localAfterPhotoPath!.startsWith('http')) {
      final file = File(session.localAfterPhotoPath!);
      if (file.existsSync()) {
        final compressed = await ImageCompressionService.compressSessionImage(
          file,
        );
        cloudAfterUrl = await _storageService.uploadSessionImage(compressed);
      }
    }

    final data = session.toJson();
    data['before_photo_path'] = cloudBeforeUrl;
    data['after_photo_path'] = cloudAfterUrl;

    // Always upsert (including soft deletes) - never hard delete
    await _client!.from('deep_cleaning_sessions').upsert(data);

    // Update local Hive with cloud URLs - KEEP local paths unchanged
    sessionHive.remoteBeforePhotoPath = cloudBeforeUrl;
    sessionHive.remoteAfterPhotoPath = cloudAfterUrl;
    // DO NOT touch localBeforePhotoPath/localAfterPhotoPath
    sessionHive.markSynced();
    await sessionHive.save();

    if (sessionHive.deletedAt != null) {
      debugPrint('⬆️ Uploaded soft-deleted session: ${session.id}');
    } else {
      debugPrint('⬆️ Uploaded session: ${session.id}');
    }
  }

  Future<void> _uploadItem(DeclutterItemHive itemHive) async {
    final item = itemHive.toItem();

    debugPrint('⬆️ Uploading item: ${item.name} (${item.id.substring(0, 8)})');
    debugPrint('   updated=${item.updatedAt}, deleted=${item.deletedAt}, device=${item.deviceId}');

    // Handle photo upload - only upload local files
    String? cloudPhotoUrl = item.remotePhotoPath;
    if (item.localPhotoPath != null && !item.localPhotoPath!.startsWith('http')) {
      final file = File(item.localPhotoPath!);
      if (file.existsSync()) {
        final compressed = await ImageCompressionService.compressItemImage(
          file,
        );
        cloudPhotoUrl = await _storageService.uploadItemImage(compressed);
      }
    }

    final data = item.toJson();
    data['photo_path'] = cloudPhotoUrl;

    debugPrint('   Upserting to Supabase...');
    // Always upsert (including soft deletes) - never hard delete
    await _client!.from('declutter_items').upsert(data);

    // Update local Hive with cloud URL - KEEP local path unchanged
    itemHive.remotePhotoPath = cloudPhotoUrl;
    // DO NOT touch localPhotoPath
    itemHive.markSynced();
    await itemHive.save();

    if (itemHive.deletedAt != null) {
      debugPrint('   ✅ Uploaded soft-deleted item: ${item.name}');
    } else {
      debugPrint('   ✅ Uploaded item: ${item.name}');
    }
  }

  Future<void> _uploadResellItem(ResellItemHive itemHive) async {
    final item = itemHive.toItem();
    final data = item.toJson();

    // Always upsert (including soft deletes) - never hard delete
    await _client!.from('resell_items').upsert(data);
    itemHive.markSynced();
    await itemHive.save();

    if (itemHive.deletedAt != null) {
      debugPrint('⬆️ Uploaded soft-deleted resell item: ${item.id}');
    } else {
      debugPrint('⬆️ Uploaded resell item: ${item.id}');
    }
  }

  Future<void> _uploadPlannedSession(PlannedSessionHive sessionHive) async {
    final session = sessionHive.toSession();
    final data = session.toJson();

    debugPrint('⬆️ [UPLOAD] PlannedSession ${session.id}: isCompleted=${session.isCompleted}, updatedAt=${session.updatedAt}');

    await _client!.from('planned_sessions').upsert(data);
    sessionHive.markSynced();
    await sessionHive.save();

    if (sessionHive.deletedAt != null) {
      debugPrint('✅ Uploaded soft-deleted planned session: ${session.id}');
    } else {
      debugPrint('✅ Uploaded planned session: ${session.id}');
    }
  }

  // ==========================================================================
  // DOWNLOAD (Cloud -> Local)
  // ==========================================================================

  Future<bool> _downloadRemoteData() async {
    debugPrint('⬇️ [PULL] Starting cloud→local sync...');

    bool hadChanges = false;
    hadChanges |= await _downloadMemories();
    hadChanges |= await _downloadSessions();
    hadChanges |= await _downloadItems();
    hadChanges |= await _downloadResellItems();
    hadChanges |= await _downloadPlannedSessions();

    debugPrint('✅ [PULL] Cloud→local sync complete, hadChanges=$hadChanges');
    return hadChanges;
  }

  Future<bool> _downloadMemories() async {
    bool hadChanges = false;
    try {
      final response = await _client!
          .from('memories')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      debugPrint('📥 Downloaded ${response.length} memories from cloud');
      DateTime? latestRemote;

      for (final json in response) {
        final memory = Memory.fromJson(json);
        final localHive = _hiveService.getMemory(memory.id);
        latestRemote =
            _maxTimestamp(latestRemote, memory.updatedAt ?? memory.createdAt);

        if (localHive == null) {
          final hive = MemoryHive.fromMemory(memory, isDirty: false);
          await _hiveService.memories.put(hive.id, hive);
          debugPrint('   ✅ Created memory: ${memory.title}');
          hadChanges = true;
        } else {
          // CRITICAL: Never overwrite dirty local data
          if (localHive.isDirty) {
            debugPrint('   ⏭️ Skipping memory - local is dirty (pending upload)');
            continue;
          }

          if (_shouldReplaceLocal(
            localHive.updatedAt,
            memory.updatedAt,
            localDeletedAt: localHive.deletedAt,
            remoteDeletedAt: memory.deletedAt,
            localIsDirty: localHive.isDirty,
          )) {
            final hive = MemoryHive.fromMemory(memory, isDirty: false);
            await _hiveService.memories.put(hive.id, hive);
            debugPrint('   ✅ Updated memory: ${memory.title}');
            hadChanges = true;
          }
        }
      }

      await _updateLastRemoteSync(_memoriesSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download memories: $e');
    }
    return hadChanges;
  }

  Future<bool> _downloadSessions() async {
    bool hadChanges = false;
    try {
      final response = await _client!
          .from('deep_cleaning_sessions')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      debugPrint('📥 Downloaded ${response.length} sessions from cloud');
      DateTime? latestRemote;

      for (final json in response) {
        final session = DeepCleaningSession.fromJson(json);
        final localHive = _hiveService.getSession(session.id);
        latestRemote =
            _maxTimestamp(latestRemote, session.updatedAt ?? session.createdAt);

        if (localHive == null) {
          final hive = DeepCleaningSessionHive.fromSession(
            session,
            isDirty: false,
          );
          await _hiveService.sessions.put(hive.id, hive);
          debugPrint('   ✅ Created session: ${session.area}');
          hadChanges = true;
        } else {
          // CRITICAL: Never overwrite dirty local data
          if (localHive.isDirty) {
            debugPrint('   ⏭️ Skipping session - local is dirty (pending upload)');
            continue;
          }

          if (_shouldReplaceLocal(
            localHive.updatedAt,
            session.updatedAt,
            localDeletedAt: localHive.deletedAt,
            remoteDeletedAt: session.deletedAt,
            localIsDirty: localHive.isDirty,
          )) {
            final hive = DeepCleaningSessionHive.fromSession(
              session,
              isDirty: false,
            );
            await _hiveService.sessions.put(hive.id, hive);
            debugPrint('   ✅ Updated session: ${session.area}');
            hadChanges = true;
          }
        }
      }

      await _updateLastRemoteSync(_sessionsSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download sessions: $e');
    }
    return hadChanges;
  }

  Future<bool> _downloadItems() async {
    bool hadChanges = false;
    try {
      final response = await _client!
          .from('declutter_items')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      debugPrint('📥 Downloaded ${response.length} items from cloud');
      DateTime? latestRemote;

      for (final json in response) {
        final item = DeclutterItem.fromJson(json);
        final localHive = _hiveService.getItem(item.id);
        latestRemote =
            _maxTimestamp(latestRemote, item.updatedAt ?? item.createdAt);

        debugPrint('   🔍 Item: ${item.name} (${item.id.substring(0, 8)})');
        debugPrint('      Remote: updated=${item.updatedAt}, deleted=${item.deletedAt}, device=${item.deviceId}');

        if (localHive == null) {
          final hive = DeclutterItemHive.fromItem(item, isDirty: false);
          await _hiveService.items.put(hive.id, hive);
          debugPrint('   ✅ Created item: ${item.name}');
          hadChanges = true;
        } else {
          debugPrint('      Local: updated=${localHive.updatedAt}, deleted=${localHive.deletedAt}, device=${localHive.deviceId}, dirty=${localHive.isDirty}');

          // CRITICAL: Never overwrite dirty local data (not yet uploaded)
          if (localHive.isDirty) {
            debugPrint('   ⏭️ Skipping - local is dirty (pending upload)');
            continue;
          }

          if (_shouldReplaceLocal(
            localHive.updatedAt,
            item.updatedAt,
            localDeletedAt: localHive.deletedAt,
            remoteDeletedAt: item.deletedAt,
            localIsDirty: localHive.isDirty,
          )) {
            final hive = DeclutterItemHive.fromItem(item, isDirty: false);
            await _hiveService.items.put(hive.id, hive);
            debugPrint('   ✅ Updated item: ${item.name}');
            hadChanges = true;
          } else {
            debugPrint('   ⏭️ Kept local item: ${item.name}');
          }
        }
      }

      await _updateLastRemoteSync(_itemsSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download items: $e');
    }
    return hadChanges;
  }

  Future<bool> _downloadResellItems() async {
    bool hadChanges = false;
    try {
      final response = await _client!
          .from('resell_items')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      debugPrint('📥 Downloaded ${response.length} resell items from cloud');
      DateTime? latestRemote;

      for (final json in response) {
        final item = ResellItem.fromJson(json);
        final localHive = _hiveService.getResellItem(item.id);
        latestRemote =
            _maxTimestamp(latestRemote, item.updatedAt ?? item.createdAt);

        debugPrint('   🔍 ResellItem: ${item.id.substring(0, 8)}');
        debugPrint('      Remote: status=${item.status.name}, updated=${item.updatedAt}, deleted=${item.deletedAt}');

        if (localHive == null) {
          final hive = ResellItemHive.fromItem(item, isDirty: false);
          await _hiveService.resellItems.put(hive.id, hive);
          debugPrint('   ✅ Created resell item: ${item.id}');
          hadChanges = true;
        } else {
          debugPrint('      Local: status=${localHive.status}, updated=${localHive.updatedAt}, deleted=${localHive.deletedAt}, dirty=${localHive.isDirty}');

          // CRITICAL: Never overwrite dirty local data (not yet uploaded)
          if (localHive.isDirty) {
            debugPrint('   ⏭️ Skipping - local is dirty (pending upload)');
            continue;
          }

          if (_shouldReplaceLocal(
            localHive.updatedAt,
            item.updatedAt,
            localDeletedAt: localHive.deletedAt,
            remoteDeletedAt: item.deletedAt,
            localIsDirty: localHive.isDirty,
          )) {
            final hive = ResellItemHive.fromItem(item, isDirty: false);
            await _hiveService.resellItems.put(hive.id, hive);
            debugPrint('   ✅ Updated resell item: ${item.id}');
            hadChanges = true;
          } else {
            debugPrint('   ⏭️ Kept local resell item: ${item.id}');
          }
        }
      }

      await _updateLastRemoteSync(_resellSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download resell items: $e');
    }
    return hadChanges;
  }

  Future<bool> _downloadPlannedSessions() async {
    bool hadChanges = false;
    try {
      final response = await _client!
          .from('planned_sessions')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      debugPrint('📥 Downloaded ${response.length} planned sessions from cloud');

      for (final json in response) {
        final session = PlannedSession.fromJson(json);
        final localHive = _hiveService.getPlannedSession(session.id);

        debugPrint('   Checking session: ${session.title} (${session.id})');

        if (localHive == null) {
          final hive = PlannedSessionHive.fromSession(session, isDirty: false);
          await _hiveService.plannedSessions.put(hive.id, hive);
          debugPrint('   ✅ Created planned session: ${session.title}');
          hadChanges = true;
        } else {
          // CRITICAL: Never overwrite dirty local data
          if (localHive.isDirty) {
            debugPrint('   ⏭️ Skipping planned session - local is dirty (pending upload)');
            continue;
          }

          if (_shouldReplaceLocal(
            localHive.updatedAt,
            session.updatedAt,
            localDeletedAt: localHive.deletedAt,
          remoteDeletedAt: session.deletedAt,
          localIsDirty: localHive.isDirty,
        )) {
          final hive = PlannedSessionHive.fromSession(session, isDirty: false);
            await _hiveService.plannedSessions.put(hive.id, hive);
            debugPrint('   ✅ Updated planned session: ${session.title} (remote newer)');
            hadChanges = true;
          } else {
            debugPrint('   ⏭️ Kept local planned session: ${session.title}');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to download planned sessions: $e');
    }
    return hadChanges;
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  /// Last-write-wins with delete priority
  /// Rules:
  /// 0. CRITICAL: If local is dirty, NEVER replace (prevent data loss)
  /// 1. If remote has deletedAt, always take remote (delete wins)
  /// 2. If local has deletedAt but remote doesn't, keep local delete
  /// 3. Otherwise, use last-write-wins based on updatedAt
  bool _shouldReplaceLocal(
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt, {
    DateTime? localDeletedAt,
    DateTime? remoteDeletedAt,
    bool localIsDirty = false,
  }) {
    // CRITICAL: If local data is dirty (not yet uploaded), NEVER replace it
    // This prevents user's unsaved edits from being overwritten by stale cloud data
    if (localIsDirty) {
      debugPrint('   🔒 Local is dirty - protecting user edits, NOT replacing');
      return false;
    }

    if (remoteDeletedAt != null && localDeletedAt != null) {
      final result = remoteDeletedAt.isAfter(localDeletedAt);
      debugPrint('   📊 Both deleted: remote=${remoteDeletedAt}, local=${localDeletedAt}, replace=$result');
      return result;
    }

    if (remoteDeletedAt != null) {
      debugPrint('   📊 Remote deleted, replacing local');
      return true;
    }

    if (localDeletedAt != null && remoteDeletedAt == null) {
      debugPrint('   📊 Local deleted but remote not, keeping local delete');
      return false;
    }

    if (remoteUpdatedAt == null) {
      debugPrint('   📊 Remote has no updatedAt, keeping local');
      return false;
    }
    if (localUpdatedAt == null) {
      debugPrint('   📊 Local has no updatedAt, taking remote');
      return true;
    }

    final result = remoteUpdatedAt.isAfter(localUpdatedAt);
    debugPrint('   📊 Comparing: remote=${remoteUpdatedAt.toIso8601String()}, local=${localUpdatedAt.toIso8601String()}, replace=$result');
    return result;
  }

  // ==========================================================================
  // MANUAL TRIGGERS
  // ==========================================================================

  /// Force immediate sync
  Future<void> forceSync() async {
    debugPrint('🔄 Force sync requested');
    await syncAll();
  }

  /// Called when app resumes from background
  Future<void> onAppResumed() async {
    debugPrint('📱 App resumed, triggering sync...');
    await pullFromCloud();
  }

  /// Sync specific entity type
  Future<void> syncMemories() async {
    if (!_connectivityService.isConnected) return;
    final dirty = _hiveService.getDirtyMemories();
    for (final m in dirty) {
      await _processUploadTask(
        type: PendingTaskType.memoryUpload,
        entityId: m.id,
        payload: _memoryPayload(m),
        action: () => _uploadMemory(m),
      );
    }
    await _downloadMemories();
  }

  // ==========================================================================
  // REALTIME SUBSCRIPTIONS
  // ==========================================================================

  /// Setup Supabase Realtime subscriptions for all tables
  Future<void> _setupRealtimeSubscriptions() async {
    if (_client == null || _userId == null) {
      debugPrint('⚠️ Cannot setup Realtime - client or userId is null');
      return;
    }

    debugPrint('🔴 Setting up Realtime subscriptions...');

    try {
      // Subscribe to memories table
      final memoriesChannel = _client!
          .channel('memories_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'memories',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _userId,
            ),
            callback: (payload) {
              debugPrint('🔴 [Realtime] Memories changed: ${payload.eventType}');
              _schedulePullFromCloud();
            },
          )
          .subscribe();
      _realtimeChannels.add(memoriesChannel);

      // Subscribe to deep_cleaning_sessions table
      final sessionsChannel = _client!
          .channel('sessions_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'deep_cleaning_sessions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _userId,
            ),
            callback: (payload) {
              debugPrint('🔴 [Realtime] Sessions changed: ${payload.eventType}');
              _schedulePullFromCloud();
            },
          )
          .subscribe();
      _realtimeChannels.add(sessionsChannel);

      // Subscribe to declutter_items table
      final itemsChannel = _client!
          .channel('items_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'declutter_items',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _userId,
            ),
            callback: (payload) {
              debugPrint('🔴 [Realtime] Items changed: ${payload.eventType}');
              _schedulePullFromCloud();
            },
          )
          .subscribe();
      _realtimeChannels.add(itemsChannel);

      // Subscribe to resell_items table
      final resellChannel = _client!
          .channel('resell_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'resell_items',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _userId,
            ),
            callback: (payload) {
              debugPrint('🔴 [Realtime] Resell items changed: ${payload.eventType}');
              _schedulePullFromCloud();
            },
          )
          .subscribe();
      _realtimeChannels.add(resellChannel);

      // Subscribe to planned_sessions table
      final plannedChannel = _client!
          .channel('planned_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'planned_sessions',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: _userId,
            ),
            callback: (payload) {
              debugPrint('🔴 [Realtime] Planned sessions changed: ${payload.eventType}');
              _schedulePullFromCloud();
            },
          )
          .subscribe();
      _realtimeChannels.add(plannedChannel);

      debugPrint('✅ Realtime subscriptions setup complete (${_realtimeChannels.length} channels)');
    } catch (e) {
      debugPrint('❌ Failed to setup Realtime subscriptions: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _cloudPullTimer?.cancel();
    _pendingTaskTimer?.cancel();
    _scheduledSyncTimer?.cancel();
    _scheduledPullTimer?.cancel();
    _connectivitySubscription?.cancel();

    // Unsubscribe from all Realtime channels
    for (final channel in _realtimeChannels) {
      _client?.removeChannel(channel);
    }
    _realtimeChannels.clear();

    _statusController.close();
    debugPrint('🔄 Sync service disposed');
  }
}
