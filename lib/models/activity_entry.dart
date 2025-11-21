enum ActivityType { deepCleaning, joyDeclutter, quickDeclutter }

class ActivityEntry {
  const ActivityEntry({
    required this.type,
    required this.timestamp,
    this.description,
    this.itemCount,
  });

  final ActivityType type;
  final DateTime timestamp;
  final String? description;
  final int? itemCount;
}
