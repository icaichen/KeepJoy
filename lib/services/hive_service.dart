import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keepjoy_app/models/hive/memory_hive.dart';
import 'package:keepjoy_app/models/hive/deep_cleaning_session_hive.dart';
import 'package:keepjoy_app/models/hive/declutter_item_hive.dart';
import 'package:keepjoy_app/models/hive/resell_item_hive.dart';
import 'package:keepjoy_app/models/hive/planned_session_hive.dart';
import 'package:keepjoy_app/models/pending_task.dart';
import 'package:keepjoy_app/services/device_id_service.dart';

/// Hive Local Database Service
/// Manages all local data storage using Hive
class HiveService {
  // Box names
  static const String memoriesBox = 'memories';
  static const String sessionsBox = 'sessions';
  static const String itemsBox = 'items';
  static const String resellItemsBox = 'resell_items';
  static const String plannedSessionsBox = 'planned_sessions';
  static const String pendingTasksBox = 'pending_tasks';
  static const String syncMetadataBox = 'sync_metadata';

  static HiveService? _instance;
  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  HiveService._();

  bool _initialized = false;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    if (_initialized) {
      debugPrint('⚠️ Hive already initialized');
      return;
    }

    try {
      debugPrint('🗄️ Initializing Hive...');

      // Initialize Hive
      await Hive.initFlutter();

      // Register type adapters
      Hive.registerAdapter(MemoryHiveAdapter());
      Hive.registerAdapter(DeepCleaningSessionHiveAdapter());
      Hive.registerAdapter(DeclutterItemHiveAdapter());
      Hive.registerAdapter(ResellItemHiveAdapter());
      Hive.registerAdapter(PlannedSessionHiveAdapter());

      // Open all boxes
      await Hive.openBox<MemoryHive>(memoriesBox);
      await Hive.openBox<DeepCleaningSessionHive>(sessionsBox);
      await Hive.openBox<DeclutterItemHive>(itemsBox);
      await Hive.openBox<ResellItemHive>(resellItemsBox);
      await Hive.openBox<PlannedSessionHive>(plannedSessionsBox);
      await Hive.openBox(pendingTasksBox);
      await Hive.openBox(syncMetadataBox);

      _initialized = true;
      debugPrint('✅ Hive initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Hive: $e');
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _initialized = false;
    debugPrint('📦 Hive boxes closed');
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAll() async {
    debugPrint('🗑️ Clearing all Hive data...');
    await Hive.box<MemoryHive>(memoriesBox).clear();
    await Hive.box<DeepCleaningSessionHive>(sessionsBox).clear();
    await Hive.box<DeclutterItemHive>(itemsBox).clear();
    await Hive.box<ResellItemHive>(resellItemsBox).clear();
    await Hive.box<PlannedSessionHive>(plannedSessionsBox).clear();
    await Hive.box(pendingTasksBox).clear();
    await Hive.box(syncMetadataBox).clear();
    debugPrint('✅ All Hive data cleared');
  }

  // ==========================================================================
  // MEMORIES
  // ==========================================================================

  Box<MemoryHive> get memories => Hive.box<MemoryHive>(memoriesBox);

  Future<void> saveMemory(MemoryHive memory) async {
    // Auto-update metadata
    final deviceId = await DeviceIdService.instance.getDeviceId();
    memory.updatedAt = DateTime.now();
    memory.deviceId = deviceId;
    memory.isDirty = true;

    await memories.put(memory.id, memory);
    debugPrint('💾 Saved memory: ${memory.id} (device: $deviceId)');
  }

  MemoryHive? getMemory(String id) {
    return memories.get(id);
  }

  List<MemoryHive> getAllMemories({
    required String userId,
    bool includeDeleted = false,
  }) {
    final allMemories = memories.values
        .where((m) => m.userId == userId)
        .toList();
    if (includeDeleted) {
      return allMemories;
    }
    return allMemories.where((m) => !m.isDeleted && m.deletedAt == null).toList();
  }

  List<MemoryHive> getDirtyMemories() {
    return memories.values.where((m) => m.isDirty).toList();
  }

  Future<void> deleteMemory(String id) async {
    final memory = memories.get(id);
    if (memory != null) {
      // Auto-update metadata before marking deleted
      final deviceId = await DeviceIdService.instance.getDeviceId();
      memory.deviceId = deviceId;
      memory.markDeleted();
      await memory.save();
      debugPrint('🗑️ Marked memory as deleted: $id (device: $deviceId)');
    }
  }

  Future<void> permanentlyDeleteMemory(String id) async {
    await memories.delete(id);
    debugPrint('🗑️ Permanently deleted memory: $id');
  }

  // ==========================================================================
  // DEEP CLEANING SESSIONS
  // ==========================================================================

  Box<DeepCleaningSessionHive> get sessions =>
      Hive.box<DeepCleaningSessionHive>(sessionsBox);

  Future<void> saveSession(DeepCleaningSessionHive session) async {
    // Auto-update metadata
    final deviceId = await DeviceIdService.instance.getDeviceId();
    session.updatedAt = DateTime.now();
    session.deviceId = deviceId;
    session.isDirty = true;

    await sessions.put(session.id, session);
    debugPrint('💾 Saved session: ${session.id} (device: $deviceId)');
  }

  DeepCleaningSessionHive? getSession(String id) {
    return sessions.get(id);
  }

  List<DeepCleaningSessionHive> getAllSessions({
    required String userId,
    bool includeDeleted = false,
  }) {
    final allSessions = sessions.values
        .where((s) => s.userId == userId)
        .toList();
    if (includeDeleted) {
      return allSessions;
    }
    return allSessions.where((s) => !s.isDeleted && s.deletedAt == null).toList();
  }

  List<DeepCleaningSessionHive> getDirtySessions() {
    return sessions.values.where((s) => s.isDirty).toList();
  }

  Future<void> deleteSession(String id) async {
    final session = sessions.get(id);
    if (session != null) {
      // Auto-update metadata before marking deleted
      final deviceId = await DeviceIdService.instance.getDeviceId();
      session.deviceId = deviceId;
      session.markDeleted();
      await session.save();
      debugPrint('🗑️ Marked session as deleted: $id (device: $deviceId)');
    }
  }

  Future<void> permanentlyDeleteSession(String id) async {
    await sessions.delete(id);
    debugPrint('🗑️ Permanently deleted session: $id');
  }

  // ==========================================================================
  // DECLUTTER ITEMS
  // ==========================================================================

  Box<DeclutterItemHive> get items => Hive.box<DeclutterItemHive>(itemsBox);

  Future<void> saveItem(DeclutterItemHive item) async {
    // Auto-update metadata
    final deviceId = await DeviceIdService.instance.getDeviceId();
    item.updatedAt = DateTime.now();
    item.deviceId = deviceId;
    item.isDirty = true;

    await items.put(item.id, item);
    debugPrint('💾 Saved item: ${item.id} (device: $deviceId)');
  }

  DeclutterItemHive? getItem(String id) {
    return items.get(id);
  }

  List<DeclutterItemHive> getAllItems({
    required String userId,
    bool includeDeleted = false,
  }) {
    final allItems = items.values
        .where((i) => i.userId == userId)
        .toList();
    if (includeDeleted) {
      return allItems;
    }
    return allItems.where((i) => !i.isDeleted && i.deletedAt == null).toList();
  }

  List<DeclutterItemHive> getDirtyItems() {
    return items.values.where((i) => i.isDirty).toList();
  }

  Future<void> deleteItem(String id) async {
    final item = items.get(id);
    if (item != null) {
      // Auto-update metadata before marking deleted
      final deviceId = await DeviceIdService.instance.getDeviceId();
      item.deviceId = deviceId;
      item.markDeleted();
      await item.save();
      debugPrint('🗑️ Marked item as deleted: $id (device: $deviceId)');
    }
  }

  Future<void> permanentlyDeleteItem(String id) async {
    await items.delete(id);
    debugPrint('🗑️ Permanently deleted item: $id');
  }

  // ==========================================================================
  // RESELL ITEMS
  // ==========================================================================

  Box<ResellItemHive> get resellItems =>
      Hive.box<ResellItemHive>(resellItemsBox);

  Future<void> saveResellItem(ResellItemHive item) async {
    // Auto-update metadata
    final deviceId = await DeviceIdService.instance.getDeviceId();
    item.updatedAt = DateTime.now();
    item.deviceId = deviceId;
    item.isDirty = true;

    await resellItems.put(item.id, item);
    debugPrint('💾 Saved resell item: ${item.id} (device: $deviceId)');
  }

  ResellItemHive? getResellItem(String id) {
    return resellItems.get(id);
  }

  List<ResellItemHive> getAllResellItems({
    required String userId,
    bool includeDeleted = false,
  }) {
    final allItems = resellItems.values
        .where((i) => i.userId == userId)
        .toList();
    if (includeDeleted) {
      return allItems;
    }
    return allItems.where((i) => !i.isDeleted && i.deletedAt == null).toList();
  }

  List<ResellItemHive> getDirtyResellItems() {
    return resellItems.values.where((i) => i.isDirty).toList();
  }

  Future<void> deleteResellItem(String id) async {
    final item = resellItems.get(id);
    if (item != null) {
      // Auto-update metadata before marking deleted
      final deviceId = await DeviceIdService.instance.getDeviceId();
      item.deviceId = deviceId;
      item.markDeleted();
      await item.save();
      debugPrint('🗑️ Marked resell item as deleted: $id (device: $deviceId)');
    }
  }

  Future<void> permanentlyDeleteResellItem(String id) async {
    await resellItems.delete(id);
    debugPrint('🗑️ Permanently deleted resell item: $id');
  }

  // ==========================================================================
  // PLANNED SESSIONS
  // ==========================================================================

  Box<PlannedSessionHive> get plannedSessions =>
      Hive.box<PlannedSessionHive>(plannedSessionsBox);

  Box get pendingTasks => Hive.box(pendingTasksBox);
  Box get syncMetadata => Hive.box(syncMetadataBox);

  // ==========================================================================
  // SYNC METADATA
  // ==========================================================================

  Future<void> saveLastRemoteSync(String key, DateTime timestamp) async {
    await syncMetadata.put(key, timestamp.toIso8601String());
  }

  DateTime? getLastRemoteSync(String key) {
    final value = syncMetadata.get(key);
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // ==========================================================================
  // PENDING TASKS
  // ==========================================================================

  Future<void> savePendingTask(PendingTask task) async {
    await pendingTasks.put(task.id, task.toMap());
  }

  PendingTask? getPendingTask(String id) {
    final data = pendingTasks.get(id);
    if (data == null) return null;
    return PendingTask.fromMap(Map<dynamic, dynamic>.from(data));
  }

  List<PendingTask> getAllPendingTasks() {
    return pendingTasks.values
        .whereType<Map>()
        .map((data) => PendingTask.fromMap(Map<dynamic, dynamic>.from(data)))
        .toList();
  }

  Future<void> deletePendingTask(String id) async {
    await pendingTasks.delete(id);
  }

  Future<void> savePlannedSession(PlannedSessionHive session) async {
    // Auto-update metadata
    final deviceId = await DeviceIdService.instance.getDeviceId();
    session.updatedAt = DateTime.now();
    session.deviceId = deviceId;
    session.isDirty = true;

    await plannedSessions.put(session.id, session);
    debugPrint('💾 Saved planned session: ${session.id} (device: $deviceId)');
  }

  PlannedSessionHive? getPlannedSession(String id) {
    return plannedSessions.get(id);
  }

  List<PlannedSessionHive> getAllPlannedSessions({
    required String userId,
    bool includeDeleted = false,
  }) {
    final allSessions = plannedSessions.values
        .where((s) => s.userId == userId)
        .toList();
    if (includeDeleted) {
      return allSessions;
    }
    return allSessions.where((s) => !s.isDeleted && s.deletedAt == null).toList();
  }

  List<PlannedSessionHive> getDirtyPlannedSessions() {
    return plannedSessions.values.where((s) => s.isDirty).toList();
  }

  Future<void> deletePlannedSession(String id) async {
    final session = plannedSessions.get(id);
    if (session != null) {
      // Auto-update metadata before marking deleted
      final deviceId = await DeviceIdService.instance.getDeviceId();
      session.deviceId = deviceId;
      session.markDeleted();
      await session.save();
      debugPrint('🗑️ Marked planned session as deleted: $id (device: $deviceId)');
    }
  }

  Future<void> permanentlyDeletePlannedSession(String id) async {
    await plannedSessions.delete(id);
    debugPrint('🗑️ Permanently deleted planned session: $id');
  }

  // ==========================================================================
  // STATISTICS
  // ==========================================================================

  /// Get database statistics
  Map<String, dynamic> getStats() {
    return {
      'memories': {
        'total': memories.length,
        'active': memories.values.where((m) => !m.isDeleted).length,
        'dirty': memories.values.where((m) => m.isDirty).length,
        'deleted': memories.values.where((m) => m.isDeleted).length,
      },
      'sessions': {
        'total': sessions.length,
        'active': sessions.values.where((s) => !s.isDeleted).length,
        'dirty': sessions.values.where((s) => s.isDirty).length,
        'deleted': sessions.values.where((s) => s.isDeleted).length,
      },
      'items': {
        'total': items.length,
        'active': items.values.where((i) => !i.isDeleted).length,
        'dirty': items.values.where((i) => i.isDirty).length,
        'deleted': items.values.where((i) => i.isDeleted).length,
      },
      'resellItems': {
        'total': resellItems.length,
        'active': resellItems.values.where((i) => !i.isDeleted).length,
        'dirty': resellItems.values.where((i) => i.isDirty).length,
        'deleted': resellItems.values.where((i) => i.isDeleted).length,
      },
      'plannedSessions': {
        'total': plannedSessions.length,
        'active': plannedSessions.values.where((s) => !s.isDeleted).length,
        'dirty': plannedSessions.values.where((s) => s.isDirty).length,
        'deleted': plannedSessions.values.where((s) => s.isDeleted).length,
      },
    };
  }

  /// Print database statistics
  void printStats() {
    final stats = getStats();
    debugPrint('📊 Hive Database Statistics:');
    stats.forEach((box, data) {
      debugPrint('  $box:');
      (data as Map).forEach((key, value) {
        debugPrint('    $key: $value');
      });
    });
  }
}
