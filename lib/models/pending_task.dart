import 'dart:convert';

enum PendingTaskType {
  memoryUpload,
  deepCleaningUpload,
  declutterUpload,
  resellUpload,
  plannedSessionUpload,
}

class PendingTask {
  PendingTask({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.retryCount,
    required this.nextAttemptAt,
    this.lastAttemptAt,
  });

  factory PendingTask.fromMap(Map<dynamic, dynamic> map) {
    return PendingTask(
      id: map['id'] as String,
      type: PendingTaskType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => PendingTaskType.memoryUpload,
      ),
      entityId: map['entityId'] as String,
      payload: Map<String, dynamic>.from(
        jsonDecode(map['payload'] as String) as Map,
      ),
      retryCount: map['retryCount'] as int? ?? 0,
      lastAttemptAt: map['lastAttemptAt'] != null
          ? DateTime.parse(map['lastAttemptAt'] as String).toLocal()
          : null,
      nextAttemptAt: DateTime.parse(map['nextAttemptAt'] as String).toLocal(),
    );
  }

  final String id;
  final PendingTaskType type;
  final String entityId;
  final Map<String, dynamic> payload;
  final int retryCount;
  final DateTime? lastAttemptAt;
  final DateTime nextAttemptAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'entityId': entityId,
      'payload': jsonEncode(payload),
      'retryCount': retryCount,
      'lastAttemptAt': lastAttemptAt?.toUtc().toIso8601String(),
      'nextAttemptAt': nextAttemptAt.toUtc().toIso8601String(),
    };
  }

  PendingTask copyWith({
    int? retryCount,
    DateTime? lastAttemptAt,
    DateTime? nextAttemptAt,
    Map<String, dynamic>? payload,
  }) {
    return PendingTask(
      id: id,
      type: type,
      entityId: entityId,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    );
  }
}
