import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:keepjoy_app/models/declutter_item.dart';
import 'package:keepjoy_app/models/resell_item.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';
import 'package:keepjoy_app/models/memory.dart';
import 'package:keepjoy_app/models/planned_session.dart';
import 'package:keepjoy_app/services/auth_service.dart';

/// Data Repository
/// Handles all CRUD operations with Supabase database
class DataRepository {
  final _authService = AuthService();
  SupabaseClient? get _client => _authService.client;

  String? get _userId => _authService.currentUserId;
  String get _requiredUserId => _authService.requireUserId();

  // ========================================================================
  // DECLUTTER ITEMS
  // ========================================================================

  /// Fetch all declutter items for current user
  Future<List<DeclutterItem>> fetchDeclutterItems() async {
    if (_userId == null || _client == null) return [];

    final response = await _client!
        .from('declutter_items')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DeclutterItem.fromJson(json))
        .toList();
  }

  /// Create a new declutter item
  Future<DeclutterItem> createDeclutterItem(DeclutterItem item) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('declutter_items')
        .insert(item.copyWith(userId: userId).toJson())
        .select()
        .single();

    return DeclutterItem.fromJson(response);
  }

  /// Update a declutter item
  Future<DeclutterItem> updateDeclutterItem(DeclutterItem item) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('declutter_items')
        .update(item.copyWith(userId: userId).toJson())
        .eq('id', item.id)
        .select()
        .single();

    return DeclutterItem.fromJson(response);
  }

  /// Delete a declutter item
  Future<void> deleteDeclutterItem(String id) async {
    final _ = _requiredUserId;
    if (_client == null) return;
    await _client!.from('declutter_items').delete().eq('id', id);
  }

  // ========================================================================
  // RESELL ITEMS
  // ========================================================================

  /// Fetch all resell items for current user
  Future<List<ResellItem>> fetchResellItems() async {
    if (_userId == null || _client == null) return [];

    final response = await _client!
        .from('resell_items')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ResellItem.fromJson(json)).toList();
  }

  /// Create a new resell item
  Future<ResellItem> createResellItem(ResellItem item) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('resell_items')
        .insert(item.copyWith(userId: userId).toJson())
        .select()
        .single();

    return ResellItem.fromJson(response);
  }

  /// Update a resell item
  Future<ResellItem> updateResellItem(ResellItem item) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('resell_items')
        .update(item.copyWith(userId: userId).toJson())
        .eq('id', item.id)
        .select()
        .single();

    return ResellItem.fromJson(response);
  }

  /// Delete a resell item
  Future<void> deleteResellItem(String id) async {
    final _ = _requiredUserId;
    if (_client == null) return;
    await _client!.from('resell_items').delete().eq('id', id);
  }

  // ========================================================================
  // DEEP CLEANING SESSIONS
  // ========================================================================

  /// Fetch all deep cleaning sessions for current user
  Future<List<DeepCleaningSession>> fetchDeepCleaningSessions() async {
    if (_userId == null || _client == null) return [];

    final response = await _client!
        .from('deep_cleaning_sessions')
        .select()
        .eq('user_id', _userId!)
        .order('start_time', ascending: false);

    return (response as List)
        .map((json) => DeepCleaningSession.fromJson(json))
        .toList();
  }

  /// Create a new deep cleaning session
  Future<DeepCleaningSession> createDeepCleaningSession(
    DeepCleaningSession session,
  ) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('deep_cleaning_sessions')
        .insert(session.copyWith(userId: userId).toJson())
        .select()
        .single();

    return DeepCleaningSession.fromJson(response);
  }

  /// Update a deep cleaning session
  Future<DeepCleaningSession> updateDeepCleaningSession(
    DeepCleaningSession session,
  ) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('deep_cleaning_sessions')
        .update(session.copyWith(userId: userId).toJson())
        .eq('id', session.id)
        .select()
        .single();

    return DeepCleaningSession.fromJson(response);
  }

  /// Delete a deep cleaning session
  Future<void> deleteDeepCleaningSession(String id) async {
    final _ = _requiredUserId;
    if (_client == null) return;
    await _client!.from('deep_cleaning_sessions').delete().eq('id', id);
  }

  // ========================================================================
  // MEMORIES
  // ========================================================================

  /// Fetch all memories for current user
  Future<List<Memory>> fetchMemories() async {
    if (_userId == null || _client == null) return [];

    final response = await _client!
        .from('memories')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Memory.fromJson(json)).toList();
  }

  /// Create a new memory
  Future<Memory> createMemory(Memory memory) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('memories')
        .insert(memory.copyWith(userId: userId).toJson())
        .select()
        .single();

    return Memory.fromJson(response);
  }

  /// Update a memory
  Future<Memory> updateMemory(Memory memory) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('memories')
        .update(memory.copyWith(userId: userId).toJson())
        .eq('id', memory.id)
        .select()
        .single();

    return Memory.fromJson(response);
  }

  /// Delete a memory
  Future<void> deleteMemory(String id) async {
    final _ = _requiredUserId;
    if (_client == null) return;
    await _client!.from('memories').delete().eq('id', id);
  }

  // ========================================================================
  // PLANNED SESSIONS
  // ========================================================================

  /// Fetch all planned sessions for current user
  Future<List<PlannedSession>> fetchPlannedSessions() async {
    if (_userId == null || _client == null) return [];

    final response = await _client!
        .from('planned_sessions')
        .select()
        .eq('user_id', _userId!)
        .order('scheduled_date', ascending: true);

    return (response as List)
        .map((json) => PlannedSession.fromJson(json))
        .toList();
  }

  /// Create a new planned session
  Future<PlannedSession> createPlannedSession(PlannedSession session) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('planned_sessions')
        .insert(session.copyWith(userId: userId).toJson())
        .select()
        .single();

    return PlannedSession.fromJson(response);
  }

  /// Update a planned session
  Future<PlannedSession> updatePlannedSession(PlannedSession session) async {
    final userId = _requiredUserId;
    if (_client == null) throw StateError('Supabase client is not available');
    final response = await _client!
        .from('planned_sessions')
        .update(session.copyWith(userId: userId).toJson())
        .eq('id', session.id)
        .select()
        .single();

    return PlannedSession.fromJson(response);
  }

  /// Delete a planned session
  Future<void> deletePlannedSession(String id) async {
    final _ = _requiredUserId;
    if (_client == null) return;
    await _client!.from('planned_sessions').delete().eq('id', id);
  }

  /// Fetch today's incomplete tasks (scheduled for today OR marked as "today" priority)
  Future<List<PlannedSession>> fetchTodayTasks() async {
    if (_userId == null || _client == null) return [];

    // Fetch all incomplete tasks and filter in memory for flexibility
    final response = await _client!
        .from('planned_sessions')
        .select()
        .eq('user_id', _userId!)
        .eq('is_completed', false)
        .order('created_at', ascending: true);

    final allTasks = (response as List)
        .map((json) => PlannedSession.fromJson(json))
        .toList();

    // Filter for today's tasks
    return allTasks.where((task) => task.isForToday).toList();
  }

  /// Fetch today's completed tasks
  Future<List<PlannedSession>> fetchTodayCompletedTasks() async {
    if (_userId == null || _client == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final response = await _client!
        .from('planned_sessions')
        .select()
        .eq('user_id', _userId!)
        .eq('is_completed', true)
        .gte('completed_at', startOfDay.toIso8601String())
        .order('completed_at', ascending: false);

    return (response as List)
        .map((json) => PlannedSession.fromJson(json))
        .toList();
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

  /// Sync all data from Supabase
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

  /// Clear all user data from Supabase
  Future<void> clearAllData() async {
    final userId = _requiredUserId;
    if (_client == null) return;

    // Delete all data for the current user in parallel
    await Future.wait([
      _client!.from('declutter_items').delete().eq('user_id', userId),
      _client!.from('resell_items').delete().eq('user_id', userId),
      _client!.from('deep_cleaning_sessions').delete().eq('user_id', userId),
      _client!.from('memories').delete().eq('user_id', userId),
      _client!.from('planned_sessions').delete().eq('user_id', userId),
    ]);
  }
}
