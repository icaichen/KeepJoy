class DeepCleaningSession {
  final String area;
  final DateTime startTime;
  final String? beforePhotoPath;
  String? afterPhotoPath;
  int? elapsedSeconds;
  int? itemsCount;
  int? focusIndex; // 1-10
  int? moodIndex; // 1-10
  double? beforeMessinessIndex; // AI analysis
  double? afterMessinessIndex; // AI analysis

  DeepCleaningSession({
    required this.area,
    required this.startTime,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.elapsedSeconds,
    this.itemsCount,
    this.focusIndex,
    this.moodIndex,
    this.beforeMessinessIndex,
    this.afterMessinessIndex,
  });

  DeepCleaningSession copyWith({
    String? area,
    DateTime? startTime,
    String? beforePhotoPath,
    String? afterPhotoPath,
    int? elapsedSeconds,
    int? itemsCount,
    int? focusIndex,
    int? moodIndex,
    double? beforeMessinessIndex,
    double? afterMessinessIndex,
  }) {
    return DeepCleaningSession(
      area: area ?? this.area,
      startTime: startTime ?? this.startTime,
      beforePhotoPath: beforePhotoPath ?? this.beforePhotoPath,
      afterPhotoPath: afterPhotoPath ?? this.afterPhotoPath,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      itemsCount: itemsCount ?? this.itemsCount,
      focusIndex: focusIndex ?? this.focusIndex,
      moodIndex: moodIndex ?? this.moodIndex,
      beforeMessinessIndex: beforeMessinessIndex ?? this.beforeMessinessIndex,
      afterMessinessIndex: afterMessinessIndex ?? this.afterMessinessIndex,
    );
  }
}
