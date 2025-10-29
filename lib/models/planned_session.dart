/// Model for a planned decluttering session
class PlannedSession {
  PlannedSession({
    required this.id,
    this.userId = 'local_user',
    required this.title,
    required this.area,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  final String id;
  final String userId; // Foreign key to auth.users
  final String title;
  final String area;
  final DateTime scheduledDate;
  final String scheduledTime; // e.g., "2:00 PM"
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'area': area,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': scheduledTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  // Create from JSON from Supabase
  factory PlannedSession.fromJson(Map<String, dynamic> json) {
    return PlannedSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      area: json['area'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledTime: json['scheduled_time'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      notes: json['notes'] as String?,
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
    );
  }
}
