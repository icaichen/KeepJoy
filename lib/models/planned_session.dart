/// Priority level for tasks
enum TaskPriority {
  today,
  thisWeek,
  someday;

  String get displayName {
    switch (this) {
      case TaskPriority.today:
        return 'Today';
      case TaskPriority.thisWeek:
        return 'This Week';
      case TaskPriority.someday:
        return 'Someday';
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
    );
  }
}

