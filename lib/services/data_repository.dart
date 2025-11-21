import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/models/hive/memory_hive.dart';
import 'package:keepjoy_app/models/hive/deep_cleaning_session_hive.dart';
import 'package:keepjoy_app/models/hive/declutter_item_hive.dart';
import 'package:keepjoy_app/models/hive/resell_item_hive.dart';
import 'package:keepjoy_app/models/hive/planned_session_hive.dart';
import 'package:keepjoy_app/services/auth_service.dart';
import 'package:keepjoy_app/services/hive_service.dart';
import 'package:keepjoy_app/services/sync_service.dart';
import 'package:keepjoy_app/services/device_id_service.dart';

/// Local-First Data Repository
/// All operations write to Hive first, then sync to cloud in background
class DataRepository {
  final _authService = AuthService();
  final _hiveService = HiveService.instance;
  final _deviceIdService = DeviceIdService.instance;

  String? get _userId => _authService.currentUserId;
  String get _requiredUserId => _authService.requireUserId();

  /// Schedule background sync after data change
  /// 5-second delay to batch multiple rapid changes and reduce Supabase requests
  void _scheduleSyncAfterDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      SyncService.instance.syncAll();
    });
  }

  /// Delete a local image file if it exists
  Future<void> _deleteImageFile(String? photoPath) async {
    if (photoPath == null || photoPath.isEmpty) return;
    // Don't delete cloud URLs
    if (photoPath.startsWith('http')) return;

    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Deleted image file: $photoPath');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to delete image file: $e');
    }
  }

  // ========================================================================
  // DECLUTTER ITEMS (Local-First)
  // ========================================================================

  /// Fetch all declutter items from local Hive database
  /// Only returns items that are NOT soft-deleted
  Future<List<DeclutterItem>> fetchDeclutterItems() async {
    if (_userId == null) return [];

    final hiveItems = _hiveService.getAllItems(userId: _userId!);
    // Filter out soft-deleted items
    final activeItems = hiveItems
        .where((h) => h.deletedAt == null)
        .map((h) => h.toItem())
        .toList();
    return activeItems..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Create a new declutter item (writes to Hive, syncs later)
  Future<DeclutterItem> createDeclutterItem(DeclutterItem item) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final itemWithUser = item.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Save to Hive (local-first)
    final hive = DeclutterItemHive.fromItem(itemWithUser, isDirty: true);
    await _hiveService.saveItem(hive);

    debugPrint('💾 Created item locally: ${item.id} [device: $deviceId]');

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return itemWithUser;
  }

  /// Update a declutter item (writes to Hive, syncs later)
  Future<DeclutterItem> updateDeclutterItem(DeclutterItem item) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final itemWithUser = item.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Update in Hive
    final hive = DeclutterItemHive.fromItem(itemWithUser, isDirty: true);
    await _hiveService.saveItem(hive);

    debugPrint('💾 Updated item locally: ${item.id} [device: $deviceId]');

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return itemWithUser;
  }

  /// Delete a declutter item (soft delete in Hive, syncs later)
  Future<void> deleteDeclutterItem(String id) async {
    final _ = _requiredUserId;

    // Get item for image cleanup
    final hive = _hiveService.getItem(id);
    if (hive != null) {
      await _deleteImageFile(hive.photoPath);
    }

    // Soft delete in Hive
    await _hiveService.deleteItem(id);

    debugPrint('🗑️ Deleted item locally: $id');

    // Schedule background sync
    _scheduleSyncAfterDelay();
  }

  // ========================================================================
  // RESELL ITEMS (Local-First)
  // ========================================================================

  /// Fetch all resell items from local Hive database
  /// Only returns resell items where the linked declutter_item is NOT deleted
  Future<List<ResellItem>> fetchResellItems() async {
    if (_userId == null) return [];

    final hiveItems = _hiveService.getAllResellItems(userId: _userId!);
    final resellItems = hiveItems.map((h) => h.toItem()).toList();

    // Filter out resell items linked to deleted declutter items
    final validResellItems = <ResellItem>[];
    for (final resellItem in resellItems) {
      // Skip soft-deleted resell items
      if (resellItem.deletedAt != null) continue;

      // Check if the linked declutter item exists and is not deleted
      final declutterItem = _hiveService.getItem(resellItem.declutterItemId);
      if (declutterItem != null && declutterItem.deletedAt == null) {
        validResellItems.add(resellItem);
      }
    }

    return validResellItems..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Create a new resell item (writes to Hive, syncs later)
  Future<ResellItem> createResellItem(ResellItem item) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final itemWithUser = item.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Save to Hive
    final hive = ResellItemHive.fromItem(itemWithUser, isDirty: true);
    await _hiveService.saveResellItem(hive);

    debugPrint(
      '💾 Created resell item locally: ${item.id} [device: $deviceId]',
    );

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return itemWithUser;
  }

  /// Update a resell item (writes to Hive, syncs later)
  Future<ResellItem> updateResellItem(ResellItem item) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final itemWithUser = item.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Update in Hive
    final hive = ResellItemHive.fromItem(itemWithUser, isDirty: true);
    await _hiveService.saveResellItem(hive);

    debugPrint(
      '💾 Updated resell item locally: ${item.id} [device: $deviceId]',
    );

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return itemWithUser;
  }

  /// Delete a resell item (soft delete in Hive, syncs later)
  Future<void> deleteResellItem(String id) async {
    final _ = _requiredUserId;

    // Soft delete in Hive
    await _hiveService.deleteResellItem(id);

    debugPrint('🗑️ Deleted resell item locally: $id');

    // Schedule background sync
    _scheduleSyncAfterDelay();
  }

  // ========================================================================
  // DEEP CLEANING SESSIONS (Local-First)
  // ========================================================================

  /// Fetch all deep cleaning sessions from local Hive database
  Future<List<DeepCleaningSession>> fetchDeepCleaningSessions() async {
    if (_userId == null) return [];

    final hiveSessions = _hiveService.getAllSessions(userId: _userId!);
    // Filter out soft-deleted sessions
    final activeSessions = hiveSessions
        .where((h) => h.deletedAt == null)
        .map((h) => h.toSession())
        .toList();
    return activeSessions..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  /// Create a new deep cleaning session (writes to Hive, syncs later)
  Future<DeepCleaningSession> createDeepCleaningSession(
    DeepCleaningSession session,
  ) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final sessionWithUser = session.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Save to Hive
    final hive = DeepCleaningSessionHive.fromSession(
      sessionWithUser,
      isDirty: true,
    );
    await _hiveService.saveSession(hive);

    debugPrint('💾 Created session locally: ${session.id} [device: $deviceId]');

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return sessionWithUser;
  }

  /// Update a deep cleaning session (writes to Hive, syncs later)
  Future<DeepCleaningSession> updateDeepCleaningSession(
    DeepCleaningSession session,
  ) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final sessionWithUser = session.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Update in Hive
    final hive = DeepCleaningSessionHive.fromSession(
      sessionWithUser,
      isDirty: true,
    );
    await _hiveService.saveSession(hive);

    debugPrint('💾 Updated session locally: ${session.id} [device: $deviceId]');

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return sessionWithUser;
  }

  /// Delete a deep cleaning session (soft delete in Hive, syncs later)
  Future<void> deleteDeepCleaningSession(String id) async {
    final _ = _requiredUserId;

    // Get session for image cleanup
    final hive = _hiveService.getSession(id);
    if (hive != null) {
      await _deleteImageFile(hive.beforePhotoPath);
      await _deleteImageFile(hive.afterPhotoPath);
    }

    // Soft delete in Hive
    await _hiveService.deleteSession(id);

    debugPrint('🗑️ Deleted session locally: $id');

    // Schedule background sync
    _scheduleSyncAfterDelay();
  }

  // ========================================================================
  // MEMORIES (Local-First)
  // ========================================================================

  /// Fetch all memories from local Hive database
  /// Only returns memories that are NOT soft-deleted
  Future<List<Memory>> fetchMemories() async {
    if (_userId == null) return [];

    final hiveMemories = _hiveService.getAllMemories(userId: _userId!);
    // Filter out soft-deleted memories
    final activeMemories = hiveMemories
        .where((h) => h.deletedAt == null)
        .map((h) => h.toMemory())
        .toList();
    return activeMemories..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Create a new memory (writes to Hive, syncs later)
  Future<Memory> createMemory(Memory memory) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final memoryWithUser = memory.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Save to Hive
    final hive = MemoryHive.fromMemory(memoryWithUser, isDirty: true);
    await _hiveService.saveMemory(hive);

    debugPrint('💾 Created memory locally: ${memory.id} [device: $deviceId]');

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return memoryWithUser;
  }

  /// Update a memory (writes to Hive, syncs later)
  Future<Memory> updateMemory(Memory memory) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final memoryWithUser = memory.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Update in Hive
    final hive = MemoryHive.fromMemory(memoryWithUser, isDirty: true);
    await _hiveService.saveMemory(hive);

    debugPrint('💾 Updated memory locally: ${memory.id} [device: $deviceId]');

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return memoryWithUser;
  }

  /// Delete a memory (soft delete in Hive, syncs later)
  Future<void> deleteMemory(String id) async {
    final _ = _requiredUserId;

    // Get memory for image cleanup
    final hive = _hiveService.getMemory(id);
    if (hive != null) {
      await _deleteImageFile(hive.photoPath);
    }

    // Soft delete in Hive
    await _hiveService.deleteMemory(id);

    debugPrint('🗑️ Deleted memory locally: $id');

    // Schedule background sync
    _scheduleSyncAfterDelay();
  }

  // ========================================================================
  // PLANNED SESSIONS (Local-First)
  // ========================================================================

  /// Fetch all planned sessions from local Hive database
  /// Only returns sessions that are NOT soft-deleted
  Future<List<PlannedSession>> fetchPlannedSessions() async {
    if (_userId == null) return [];

    final hiveSessions = _hiveService.getAllPlannedSessions(userId: _userId!);
    // Filter out soft-deleted sessions
    final activeSessions = hiveSessions
        .where((h) => h.deletedAt == null)
        .map((h) => h.toSession())
        .toList();
    return activeSessions..sort((a, b) {
      // Sort by scheduled date, nulls last
      if (a.scheduledDate == null && b.scheduledDate == null) {
        return a.createdAt.compareTo(b.createdAt);
      }
      if (a.scheduledDate == null) return 1;
      if (b.scheduledDate == null) return -1;
      return a.scheduledDate!.compareTo(b.scheduledDate!);
    });
  }

  /// Create a new planned session (writes to Hive, syncs later)
  Future<PlannedSession> createPlannedSession(PlannedSession session) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    final sessionWithUser = session.copyWith(
      userId: userId,
      updatedAt: DateTime.now(),
      deviceId: deviceId,
    );

    // Save to Hive
    final hive = PlannedSessionHive.fromSession(sessionWithUser, isDirty: true);
    await _hiveService.savePlannedSession(hive);

    debugPrint(
      '💾 Created planned session locally: ${session.id} [device: $deviceId]',
    );

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return sessionWithUser;
  }

  /// Update a planned session (writes to Hive, syncs later)
  Future<PlannedSession> updatePlannedSession(PlannedSession session) async {
    final userId = _requiredUserId;
    final deviceId = await _deviceIdService.getDeviceId();

    // Create a new session to ensure deletedAt is cleared
    // We can't use copyWith because it preserves null values
    final sessionWithUser = PlannedSession(
      id: session.id,
      userId: userId,
      title: session.title,
      area: session.area,
      scheduledDate: session.scheduledDate,
      scheduledTime: session.scheduledTime,
      createdAt: session.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: null, // Always null when updating
      deviceId: deviceId,
      notes: session.notes,
      isCompleted: session.isCompleted,
      completedAt: session.completedAt,
      priority: session.priority,
      mode: session.mode,
      goal: session.goal,
    );

    // Update in Hive
    final hive = PlannedSessionHive.fromSession(sessionWithUser, isDirty: true);
    await _hiveService.savePlannedSession(hive);

    debugPrint(
      '💾 Updated planned session locally: ${session.id} [device: $deviceId]',
    );

    // Schedule background sync
    _scheduleSyncAfterDelay();

    return sessionWithUser;
  }

  /// Delete a planned session (soft delete in Hive, syncs later)
  Future<void> deletePlannedSession(String id) async {
    final _ = _requiredUserId;

    // Soft delete in Hive
    await _hiveService.deletePlannedSession(id);

    debugPrint('🗑️ Deleted planned session locally: $id');

    // Schedule background sync
    _scheduleSyncAfterDelay();
  }

  /// Fetch today's incomplete tasks
  Future<List<PlannedSession>> fetchTodayTasks() async {
    if (_userId == null) return [];

    final allTasks = await fetchPlannedSessions();
    return allTasks.where((task) => task.isForToday).toList();
  }

  /// Fetch today's completed tasks
  Future<List<PlannedSession>> fetchTodayCompletedTasks() async {
    if (_userId == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final hiveSessions = _hiveService.getAllPlannedSessions(userId: _userId!);
    return hiveSessions
        .map((h) => h.toSession())
        .where(
          (task) =>
              task.isCompleted &&
              task.completedAt != null &&
              task.completedAt!.isAfter(startOfDay),
        )
        .toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  /// Toggle task completion
  Future<PlannedSession> toggleTaskCompletion(PlannedSession task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    return updatePlannedSession(updated);
  }

  // ========================================================================
  // BATCH OPERATIONS
  // ========================================================================

  /// Get all data from local Hive database
  Future<Map<String, dynamic>> syncAllData() async {
    final results = await Future.wait([
      fetchDeclutterItems(),
      fetchResellItems(),
      fetchDeepCleaningSessions(),
      fetchMemories(),
      fetchPlannedSessions(),
    ]);

    return {
      'declutterItems': results[0],
      'resellItems': results[1],
      'deepCleaningSessions': results[2],
      'memories': results[3],
      'plannedSessions': results[4],
    };
  }

  /// Force immediate sync
  Future<void> forceSync() async {
    await SyncService.instance.forceSync();
  }

  /// Get sync status
  SyncStatus get syncStatus => SyncService.instance.currentStatus;

  /// Stream of sync status changes
  Stream<SyncStatus> get syncStatusStream => SyncService.instance.statusStream;
}
