import 'package:keepjoy_app/l10n/app_localizations.dart';

/// Priority level for tasks
enum TaskPriority {
  today,
  thisWeek,
  someday;

  String displayName(AppLocalizations l10n) {
    switch (this) {
      case TaskPriority.today:
        return l10n.priorityToday;
      case TaskPriority.thisWeek:
        return l10n.priorityThisWeek;
      case TaskPriority.someday:
        return l10n.prioritySomeday;
    }
  }
}

/// Session mode type
enum SessionMode {
  deepCleaning,
  joyDeclutter,
  quickDeclutter;

  String displayName(AppLocalizations l10n) {
    switch (this) {
      case SessionMode.deepCleaning:
        return l10n.deepCleaningTitle;
      case SessionMode.joyDeclutter:
        return l10n.joyDeclutterTitle;
      case SessionMode.quickDeclutter:
        return l10n.quickDeclutterTitle;
    }
  }
}

/// Model for a planned decluttering session or task
class PlannedSession {
  PlannedSession({
    required this.id,
    this.userId = 'local_user',
    required this.title,
    required this.area,
    this.scheduledDate,
    this.scheduledTime,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
    this.priority = TaskPriority.someday,
    this.mode = SessionMode.deepCleaning,
    this.goal,
  });

  final String id;
  final String userId; // Foreign key to auth.users
  final String title;
  final String area;
  final DateTime? scheduledDate; // Optional for flexible tasks
  final String? scheduledTime; // e.g., "2:00 PM", optional
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;
  final TaskPriority priority;
  final SessionMode mode; // Deep Cleaning, Joy Declutter, or Quick Declutter
  final String? goal; // e.g., "Declutter 50 items"

  /// Check if this task should appear in "Today's Focus"
  bool get isForToday {
    if (isCompleted) return false;

    // Tasks explicitly marked as "today" priority
    if (priority == TaskPriority.today) return true;

    // Tasks scheduled for today
    if (scheduledDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
      );
      return taskDate == today;
    }

    return false;
  }

  /// Check if this task is scheduled
  bool get isScheduled => scheduledDate != null;

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'area': area,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'scheduled_time': scheduledTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'priority': priority.name,
      'mode': mode.name,
      'goal': goal,
    };
  }

  // Create from JSON from Supabase
  factory PlannedSession.fromJson(Map<String, dynamic> json) {
    return PlannedSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      area: json['area'] as String,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : null,
      scheduledTime: json['scheduled_time'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      notes: json['notes'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      priority: json['priority'] != null
          ? TaskPriority.values.firstWhere(
              (e) => e.name == json['priority'],
              orElse: () => TaskPriority.someday,
            )
          : TaskPriority.someday,
      mode: json['mode'] != null
          ? SessionMode.values.firstWhere(
              (e) => e.name == json['mode'],
              orElse: () => SessionMode.deepCleaning,
            )
          : SessionMode.deepCleaning,
      goal: json['goal'] as String?,
    );
  }

  PlannedSession copyWith({
    String? id,
    String? userId,
    String? title,
    String? area,
    DateTime? scheduledDate,
    String? scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
    TaskPriority? priority,
    SessionMode? mode,
    String? goal,
  }) {
    return PlannedSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      area: area ?? this.area,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      mode: mode ?? this.mode,
      goal: goal ?? this.goal,
    );
  }
}
