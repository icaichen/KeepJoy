import 'package:hive/hive.dart';
import 'package:keepjoy_app/models/deep_cleaning_session.dart';

part 'deep_cleaning_session_hive.g.dart';

/// Hive model for DeepCleaningSession
@HiveType(typeId: 1)
class DeepCleaningSessionHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String area;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  String? beforePhotoPath; // Deprecated - kept for backward compatibility

  @HiveField(7)
  String? afterPhotoPath; // Deprecated - kept for backward compatibility

  @HiveField(8)
  int? elapsedSeconds;

  @HiveField(17)
  String? localBeforePhotoPath;

  @HiveField(18)
  String? remoteBeforePhotoPath;

  @HiveField(19)
  String? localAfterPhotoPath;

  @HiveField(20)
  String? remoteAfterPhotoPath;

  @HiveField(9)
  int? itemsCount;

  @HiveField(10)
  int? focusIndex;

  @HiveField(11)
  int? moodIndex;

  @HiveField(12)
  double? beforeMessinessIndex;

  @HiveField(13)
  double? afterMessinessIndex;

  @HiveField(14)
  DateTime? syncedAt;

  @HiveField(15)
  bool isDirty;

  @HiveField(16)
  bool isDeleted;

  DeepCleaningSessionHive({
    required this.id,
    required this.userId,
    required this.area,
    required this.startTime,
    required this.createdAt,
    this.updatedAt,
    this.beforePhotoPath, // Deprecated
    this.afterPhotoPath, // Deprecated
    this.elapsedSeconds,
    this.itemsCount,
    this.focusIndex,
    this.moodIndex,
    this.beforeMessinessIndex,
    this.afterMessinessIndex,
    this.syncedAt,
    this.isDirty = false,
    this.isDeleted = false,
    this.localBeforePhotoPath,
    this.remoteBeforePhotoPath,
    this.localAfterPhotoPath,
    this.remoteAfterPhotoPath,
  });

  /// Convert from domain DeepCleaningSession model
  factory DeepCleaningSessionHive.fromSession(
    DeepCleaningSession session, {
    bool isDirty = false,
  }) {
    return DeepCleaningSessionHive(
      id: session.id,
      userId: session.userId,
      area: session.area,
      startTime: session.startTime,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      beforePhotoPath: null, // Deprecated field
      afterPhotoPath: null, // Deprecated field
      elapsedSeconds: session.elapsedSeconds,
      itemsCount: session.itemsCount,
      focusIndex: session.focusIndex,
      moodIndex: session.moodIndex,
      beforeMessinessIndex: session.beforeMessinessIndex,
      afterMessinessIndex: session.afterMessinessIndex,
      syncedAt: isDirty ? null : DateTime.now(),
      isDirty: isDirty,
      isDeleted: false,
      localBeforePhotoPath: session.localBeforePhotoPath,
      remoteBeforePhotoPath: session.remoteBeforePhotoPath,
      localAfterPhotoPath: session.localAfterPhotoPath,
      remoteAfterPhotoPath: session.remoteAfterPhotoPath,
    );
  }

  /// Convert to domain DeepCleaningSession model
  DeepCleaningSession toSession() {
    // Backward compatibility: migrate old photo paths to new fields
    String? localBefore = localBeforePhotoPath;
    String? remoteBefore = remoteBeforePhotoPath;
    String? localAfter = localAfterPhotoPath;
    String? remoteAfter = remoteAfterPhotoPath;

    if (beforePhotoPath != null && beforePhotoPath!.isNotEmpty) {
      if (beforePhotoPath!.startsWith('http')) {
        remoteBefore ??= beforePhotoPath;
      } else {
        localBefore ??= beforePhotoPath;
      }
    }

    if (afterPhotoPath != null && afterPhotoPath!.isNotEmpty) {
      if (afterPhotoPath!.startsWith('http')) {
        remoteAfter ??= afterPhotoPath;
      } else {
        localAfter ??= afterPhotoPath;
      }
    }

    return DeepCleaningSession(
      id: id,
      userId: userId,
      area: area,
      startTime: startTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      localBeforePhotoPath: localBefore,
      remoteBeforePhotoPath: remoteBefore,
      localAfterPhotoPath: localAfter,
      remoteAfterPhotoPath: remoteAfter,
      elapsedSeconds: elapsedSeconds,
      itemsCount: itemsCount,
      focusIndex: focusIndex,
      moodIndex: moodIndex,
      beforeMessinessIndex: beforeMessinessIndex,
      afterMessinessIndex: afterMessinessIndex,
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
    isDeleted = true;
    isDirty = true;
    updatedAt = DateTime.now();
  }
}
