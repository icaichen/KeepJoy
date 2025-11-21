import 'package:hive/hive.dart';
import 'package:keepjoy_app/models/declutter_item.dart';

part 'declutter_item_hive.g.dart';

/// Hive model for DeclutterItem
@HiveType(typeId: 2)
class DeclutterItemHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String name;

  @HiveField(3)
  Map<String, String>? nameLocalizations;

  @HiveField(4)
  String category; // Store as string (enum name)

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  @HiveField(7)
  String status; // Store as string (enum name)

  @HiveField(8)
  String? photoPath; // Deprecated - kept for backward compatibility

  @HiveField(9)
  String? notes;

  @HiveField(17)
  String? localPhotoPath;

  @HiveField(18)
  String? remotePhotoPath;

  @HiveField(10)
  int? joyLevel;

  @HiveField(11)
  String? joyNotes;

  @HiveField(12)
  String? purchaseReview; // Store as string (enum name)

  @HiveField(13)
  DateTime? reviewedAt;

  @HiveField(14)
  DateTime? syncedAt;

  @HiveField(15)
  bool isDirty;

  @HiveField(16)
  bool isDeleted;

  @HiveField(19)
  DateTime? deletedAt;

  @HiveField(20)
  String? deviceId;

  DeclutterItemHive({
    required this.id,
    required this.userId,
    required this.name,
    this.nameLocalizations,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    this.photoPath, // Deprecated
    this.notes,
    this.joyLevel,
    this.joyNotes,
    this.purchaseReview,
    this.reviewedAt,
    this.syncedAt,
    this.isDirty = false,
    this.isDeleted = false,
    this.localPhotoPath,
    this.remotePhotoPath,
    this.deletedAt,
    this.deviceId,
  });

  /// Convert from domain DeclutterItem model
  factory DeclutterItemHive.fromItem(
    DeclutterItem item, {
    bool isDirty = false,
  }) {
    return DeclutterItemHive(
      id: item.id,
      userId: item.userId,
      name: item.name,
      nameLocalizations: item.nameLocalizations,
      category: item.category.name,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      status: item.status.name,
      photoPath: null, // Deprecated field
      notes: item.notes,
      joyLevel: item.joyLevel,
      joyNotes: item.joyNotes,
      purchaseReview: item.purchaseReview?.name,
      reviewedAt: item.reviewedAt,
      syncedAt: isDirty ? null : DateTime.now(),
      isDirty: isDirty,
      isDeleted: item.deletedAt != null,
      localPhotoPath: item.localPhotoPath,
      remotePhotoPath: item.remotePhotoPath,
      deletedAt: item.deletedAt,
      deviceId: item.deviceId,
    );
  }

  /// Convert to domain DeclutterItem model
  DeclutterItem toItem() {
    // Backward compatibility: migrate old photoPath to new fields
    String? local = localPhotoPath;
    String? remote = remotePhotoPath;

    if (photoPath != null && photoPath!.isNotEmpty) {
      if (photoPath!.startsWith('http')) {
        remote ??= photoPath;
      } else {
        local ??= photoPath;
      }
    }

    return DeclutterItem(
      id: id,
      userId: userId,
      name: name,
      nameLocalizations: nameLocalizations,
      category: DeclutterCategory.values.firstWhere((e) => e.name == category),
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: DeclutterStatus.values.firstWhere((e) => e.name == status),
      localPhotoPath: local,
      remotePhotoPath: remote,
      notes: notes,
      joyLevel: joyLevel,
      joyNotes: joyNotes,
      purchaseReview: purchaseReview != null
          ? PurchaseReview.values.firstWhere((e) => e.name == purchaseReview)
          : null,
      reviewedAt: reviewedAt,
      deletedAt: deletedAt ?? (isDeleted ? DateTime.now() : null),
      deviceId: deviceId,
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
    isDeleted = true;
    isDirty = true;
    updatedAt = DateTime.now();
  }
}
