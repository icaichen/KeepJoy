import 'package:hive/hive.dart';
import 'package:keepjoy_app/models/resell_item.dart';

part 'resell_item_hive.g.dart';

/// Hive model for ResellItem
@HiveType(typeId: 3)
class ResellItemHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String declutterItemId;

  @HiveField(3)
  String status; // Store as string (enum name)

  @HiveField(4)
  String? platform; // Store as string (enum name)

  @HiveField(5)
  double? sellingPrice;

  @HiveField(6)
  double? soldPrice;

  @HiveField(7)
  DateTime? soldDate;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  @HiveField(10)
  DateTime? syncedAt;

  @HiveField(11)
  bool isDirty;

  @HiveField(12)
  bool isDeleted;

  ResellItemHive({
    required this.id,
    required this.userId,
    required this.declutterItemId,
    required this.status,
    this.platform,
    this.sellingPrice,
    this.soldPrice,
    this.soldDate,
    required this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.isDirty = false,
    this.isDeleted = false,
  });

  /// Convert from domain ResellItem model
  factory ResellItemHive.fromItem(ResellItem item, {bool isDirty = false}) {
    return ResellItemHive(
      id: item.id,
      userId: item.userId,
      declutterItemId: item.declutterItemId,
      status: item.status.name,
      platform: item.platform?.name,
      sellingPrice: item.sellingPrice,
      soldPrice: item.soldPrice,
      soldDate: item.soldDate,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      syncedAt: isDirty ? null : DateTime.now(),
      isDirty: isDirty,
      isDeleted: false,
    );
  }

  /// Convert to domain ResellItem model
  ResellItem toItem() {
    return ResellItem(
      id: id,
      userId: userId,
      declutterItemId: declutterItemId,
      status: ResellStatus.values.firstWhere((e) => e.name == status),
      platform: platform != null
          ? ResellPlatform.values.firstWhere((e) => e.name == platform)
          : null,
      sellingPrice: sellingPrice,
      soldPrice: soldPrice,
      soldDate: soldDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
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
