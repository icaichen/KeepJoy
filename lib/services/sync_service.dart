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

  Timer? _cloudPullTimer; // 5-second cloud→local pull
  Timer? _pendingTaskTimer; // 1-second local→cloud upload
  bool _isSyncing = false;
  bool _isPulling = false;
  StreamSubscription? _connectivitySubscription;

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
        _scheduleSync();
      }
    });

    // Start sync timers
    _startCloudPullTimer(); // 5-second cloud→local
    _startPendingTaskProcessor(); // 1-second local→cloud

    debugPrint('✅ Sync service initialized');
  }

  /// 5-second cloud→local pull cycle
  void _startCloudPullTimer() {
    _cloudPullTimer?.cancel();
    _cloudPullTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => pullFromCloud(),
    );
  }

  /// 1-second local→cloud upload cycle
  void _startPendingTaskProcessor() {
    _pendingTaskTimer?.cancel();
    _pendingTaskTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _processPendingTasks(),
    );
  }

  void _scheduleSync({Duration delay = const Duration(milliseconds: 100)}) {
    Future.delayed(delay, () => syncAll());
  }

  /// Pull changes from cloud (called every 5 seconds)
  Future<void> pullFromCloud() async {
    if (_isPulling) return;
    if (!_connectivityService.isConnected) return;
    if (_userId == null || _client == null) return;

    _isPulling = true;
    try {
      await _downloadRemoteData();
      _setStatus(SyncStatus.success);
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
    debugPrint('⬆️ Uploading dirty data...');

    // Upload memories
    final dirtyMemories = _hiveService.getDirtyMemories();
    for (final memory in dirtyMemories) {
      await _processUploadTask(
        type: PendingTaskType.memoryUpload,
        entityId: memory.id,
        payload: _memoryPayload(memory),
        action: () => _uploadMemory(memory),
      );
    }

    // Upload sessions
    final dirtySessions = _hiveService.getDirtySessions();
    for (final session in dirtySessions) {
      await _processUploadTask(
        type: PendingTaskType.deepCleaningUpload,
        entityId: session.id,
        payload: _sessionPayload(session),
        action: () => _uploadSession(session),
      );
    }

    // Upload items
    final dirtyItems = _hiveService.getDirtyItems();
    for (final item in dirtyItems) {
      await _processUploadTask(
        type: PendingTaskType.declutterUpload,
        entityId: item.id,
        payload: _declutterPayload(item),
        action: () => _uploadItem(item),
      );
    }

    // Upload resell items
    final dirtyResellItems = _hiveService.getDirtyResellItems();
    for (final item in dirtyResellItems) {
      await _processUploadTask(
        type: PendingTaskType.resellUpload,
        entityId: item.id,
        payload: _resellPayload(item),
        action: () => _uploadResellItem(item),
      );
    }

    // Upload planned sessions
    final dirtyPlannedSessions = _hiveService.getDirtyPlannedSessions();
    for (final session in dirtyPlannedSessions) {
      await _processUploadTask(
        type: PendingTaskType.plannedSessionUpload,
        entityId: session.id,
        payload: _plannedPayload(session),
        action: () => _uploadPlannedSession(session),
      );
    }

    debugPrint('✅ Upload complete');
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

    // Always upsert (including soft deletes) - never hard delete
    await _client!.from('declutter_items').upsert(data);

    // Update local Hive with cloud URL - KEEP local path unchanged
    itemHive.remotePhotoPath = cloudPhotoUrl;
    // DO NOT touch localPhotoPath
    itemHive.markSynced();
    await itemHive.save();

    if (itemHive.deletedAt != null) {
      debugPrint('⬆️ Uploaded soft-deleted item: ${item.id}');
    } else {
      debugPrint('⬆️ Uploaded item: ${item.id}');
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

    // Always upsert (including soft deletes) - never hard delete
    await _client!.from('planned_sessions').upsert(data);
    sessionHive.markSynced();
    await sessionHive.save();

    if (sessionHive.deletedAt != null) {
      debugPrint('⬆️ Uploaded soft-deleted planned session: ${session.id}');
    } else {
      debugPrint('⬆️ Uploaded planned session: ${session.id}');
    }
  }

  // ==========================================================================
  // DOWNLOAD (Cloud -> Local)
  // ==========================================================================

  Future<void> _downloadRemoteData() async {
    debugPrint('⬇️ Downloading remote data...');

    await _downloadMemories();
    await _downloadSessions();
    await _downloadItems();
    await _downloadResellItems();
    await _downloadPlannedSessions();

    debugPrint('✅ Download complete');
  }

  Future<void> _downloadMemories() async {
    try {
      // Always fetch all data for now - incremental sync can be added later
      final response = await _client!
          .from('memories')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      DateTime? latestRemote;

      for (final json in response) {
        final memory = Memory.fromJson(json);
        final localHive = _hiveService.getMemory(memory.id);
        latestRemote =
            _maxTimestamp(latestRemote, memory.updatedAt ?? memory.createdAt);

        // Last-write-wins with delete priority
        if (localHive == null ||
            !localHive.isDirty ||
            _shouldReplaceLocal(
              localHive.updatedAt,
              memory.updatedAt,
              localDeletedAt: localHive.deletedAt,
              remoteDeletedAt: memory.deletedAt,
            )) {
          final hive = MemoryHive.fromMemory(memory, isDirty: false);
          // Direct save to avoid auto-metadata injection
          await _hiveService.memories.put(hive.id, hive);
        }
      }

      await _updateLastRemoteSync(_memoriesSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download memories: $e');
    }
  }

  Future<void> _downloadSessions() async {
    try {
      // Always fetch all data for now - incremental sync can be added later
      final response = await _client!
          .from('deep_cleaning_sessions')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      DateTime? latestRemote;

      for (final json in response) {
        final session = DeepCleaningSession.fromJson(json);
        final localHive = _hiveService.getSession(session.id);
        latestRemote =
            _maxTimestamp(latestRemote, session.updatedAt ?? session.createdAt);

        if (localHive == null ||
            !localHive.isDirty ||
            _shouldReplaceLocal(
              localHive.updatedAt,
              session.updatedAt,
              localDeletedAt: localHive.deletedAt,
              remoteDeletedAt: session.deletedAt,
            )) {
          final hive = DeepCleaningSessionHive.fromSession(
            session,
            isDirty: false,
          );
          // Direct save to avoid auto-metadata injection
          await _hiveService.sessions.put(hive.id, hive);
        }
      }

      await _updateLastRemoteSync(_sessionsSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download sessions: $e');
    }
  }

  Future<void> _downloadItems() async {
    try {
      // Always fetch all data for now - incremental sync can be added later
      final response = await _client!
          .from('declutter_items')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      DateTime? latestRemote;

      for (final json in response) {
        final item = DeclutterItem.fromJson(json);
        final localHive = _hiveService.getItem(item.id);
        latestRemote =
            _maxTimestamp(latestRemote, item.updatedAt ?? item.createdAt);

        if (localHive == null ||
            !localHive.isDirty ||
            _shouldReplaceLocal(
              localHive.updatedAt,
              item.updatedAt,
              localDeletedAt: localHive.deletedAt,
              remoteDeletedAt: item.deletedAt,
            )) {
          final hive = DeclutterItemHive.fromItem(item, isDirty: false);
          // Direct save to avoid auto-metadata injection
          await _hiveService.items.put(hive.id, hive);
        }
      }

      await _updateLastRemoteSync(_itemsSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download items: $e');
    }
  }

  Future<void> _downloadResellItems() async {
    try {
      // Always fetch all data for now - incremental sync can be added later
      final response = await _client!
          .from('resell_items')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      DateTime? latestRemote;

      for (final json in response) {
        final item = ResellItem.fromJson(json);
        final localHive = _hiveService.getResellItem(item.id);
        latestRemote =
            _maxTimestamp(latestRemote, item.updatedAt ?? item.createdAt);

        if (localHive == null ||
            !localHive.isDirty ||
            _shouldReplaceLocal(
              localHive.updatedAt,
              item.updatedAt,
              localDeletedAt: localHive.deletedAt,
              remoteDeletedAt: item.deletedAt,
            )) {
          final hive = ResellItemHive.fromItem(item, isDirty: false);
          // Direct save to avoid auto-metadata injection
          await _hiveService.resellItems.put(hive.id, hive);
        }
      }

      await _updateLastRemoteSync(_resellSyncKey, latestRemote);
    } catch (e) {
      debugPrint('❌ Failed to download resell items: $e');
    }
  }

  Future<void> _downloadPlannedSessions() async {
    try {
      // Always fetch all data for now - incremental sync can be added later
      // when we ensure all records have proper updated_at values
      final response = await _client!
          .from('planned_sessions')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);

      debugPrint('📥 Downloaded ${response.length} planned sessions from cloud');

      for (final json in response) {
        final session = PlannedSession.fromJson(json);
        final localHive = _hiveService.getPlannedSession(session.id);

        if (localHive == null ||
            !localHive.isDirty ||
            _shouldReplaceLocal(
              localHive.updatedAt,
              session.updatedAt,
              localDeletedAt: localHive.deletedAt,
              remoteDeletedAt: session.deletedAt,
            )) {
          final hive = PlannedSessionHive.fromSession(session, isDirty: false);
          // Direct save to avoid auto-metadata injection
          await _hiveService.plannedSessions.put(hive.id, hive);
          debugPrint('   Saved planned session: ${session.title}');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to download planned sessions: $e');
    }
  }

  // ==========================================================================
  // CONFLICT RESOLUTION
  // ==========================================================================

  /// Last-write-wins with delete priority
  /// Rules:
  /// 1. If remote has deletedAt, always take remote (delete wins)
  /// 2. If local has deletedAt but remote doesn't, keep local delete
  /// 3. Otherwise, use last-write-wins based on updatedAt
  bool _shouldReplaceLocal(
    DateTime? localUpdatedAt,
    DateTime? remoteUpdatedAt, {
    DateTime? localDeletedAt,
    DateTime? remoteDeletedAt,
  }) {
    // Rule 1: Remote deletion takes priority
    if (remoteDeletedAt != null) return true;

    // Rule 2: Keep local deletion if remote is not deleted
    if (localDeletedAt != null && remoteDeletedAt == null) return false;

    // Rule 3: Last-write-wins based on updatedAt
    if (remoteUpdatedAt == null) return false;
    if (localUpdatedAt == null) return true;
    return remoteUpdatedAt.isAfter(localUpdatedAt);
  }

  // ==========================================================================
  // MANUAL TRIGGERS
  // ==========================================================================

  /// Force immediate sync
  Future<void> forceSync() async {
    debugPrint('🔄 Force sync requested');
    await syncAll();
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

  /// Dispose resources
  void dispose() {
    _cloudPullTimer?.cancel();
    _pendingTaskTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
    debugPrint('🔄 Sync service disposed');
  }
}
