/// Model for a planned decluttering session
class PlannedSession {
  PlannedSession({
    required this.id,
    required this.title,
    required this.area,
    required this.scheduledDate,
    required this.scheduledTime,
    this.notes,
  });

  final String id;
  final String title;
  final String area;
  final DateTime scheduledDate;
  final String scheduledTime; // e.g., "2:00 PM"
  final String? notes;

  PlannedSession copyWith({
    String? id,
    String? title,
    String? area,
    DateTime? scheduledDate,
    String? scheduledTime,
    String? notes,
  }) {
    return PlannedSession(
      id: id ?? this.id,
      title: title ?? this.title,
      area: area ?? this.area,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      notes: notes ?? this.notes,
    );
  }
}
