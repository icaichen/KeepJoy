import 'package:hive/hive.dart';
import 'package:keepjoy_app/models/planned_session.dart';

part 'planned_session_hive.g.dart';

/// Hive model for PlannedSession
@HiveType(typeId: 4)
class PlannedSessionHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String area;

  @HiveField(4)
  DateTime? scheduledDate;

  @HiveField(5)
  String? scheduledTime;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? updatedAt;

  @HiveField(8)
  String? notes;

  @HiveField(9)
  bool isCompleted;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  String priority; // Store as string (enum name)

  @HiveField(12)
  String mode; // Store as string (enum name)

  @HiveField(13)
  String? goal;

  @HiveField(14)
  DateTime? syncedAt;

  @HiveField(15)
  bool isDirty;

  @HiveField(16)
  bool isDeleted; // Deprecated - use deletedAt

  @HiveField(17)
  DateTime? deletedAt; // Soft delete timestamp

  @HiveField(18)
  String? deviceId; // Device that made the last change

  PlannedSessionHive({
    required this.id,
    required this.userId,
    required this.title,
    required this.area,
    this.scheduledDate,
    this.scheduledTime,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
    required this.priority,
    required this.mode,
    this.goal,
    this.syncedAt,
    this.isDirty = false,
    this.isDeleted = false,
    this.deletedAt,
    this.deviceId,
  });

  /// Convert from domain PlannedSession model
  factory PlannedSessionHive.fromSession(
    PlannedSession session, {
    bool isDirty = false,
  }) {
    return PlannedSessionHive(
      id: session.id,
      userId: session.userId,
      title: session.title,
      area: session.area,
      scheduledDate: session.scheduledDate,
      scheduledTime: session.scheduledTime,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      notes: session.notes,
      isCompleted: session.isCompleted,
      completedAt: session.completedAt,
      priority: session.priority.name,
      mode: session.mode.name,
      goal: session.goal,
      syncedAt: isDirty ? null : DateTime.now(),
      isDirty: isDirty,
      isDeleted: session.deletedAt != null, // Backward compatibility
      deletedAt: session.deletedAt,
      deviceId: session.deviceId,
    );
  }

  /// Convert to domain PlannedSession model
  PlannedSession toSession() {
    return PlannedSession(
      id: id,
      userId: userId,
      title: title,
      area: area,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt ?? (isDeleted ? DateTime.now() : null), // Migrate old isDeleted
      deviceId: deviceId,
      notes: notes,
      isCompleted: isCompleted,
      completedAt: completedAt,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => TaskPriority.someday,
      ),
      mode: SessionMode.values.firstWhere(
        (e) => e.name == mode,
        orElse: () => SessionMode.deepCleaning,
      ),
      goal: goal,
    );
  }

  /// Mark as dirty (needs sync)
  void markDirty() {
    isDirty = true;
    updatedAt = DateTime.now();
  }

  /// Mark as synced
  void markSynced() {
    isDirty = false;
    syncedAt = DateTime.now();
  }

  /// Soft delete
  void markDeleted() {
    deletedAt = DateTime.now();
    isDeleted = true; // Keep for backward compatibility
    isDirty = true;
    updatedAt = DateTime.now();
  }
}
