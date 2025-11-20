// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'declutter_item_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeclutterItemHiveAdapter extends TypeAdapter<DeclutterItemHive> {
  @override
  final int typeId = 2;

  @override
  DeclutterItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeclutterItemHive(
      id: fields[0] as String,
      userId: fields[1] as String,
      name: fields[2] as String,
      nameLocalizations: (fields[3] as Map?)?.cast<String, String>(),
      category: fields[4] as String,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
      status: fields[7] as String,
      photoPath: fields[8] as String?,
      notes: fields[9] as String?,
      joyLevel: fields[10] as int?,
      joyNotes: fields[11] as String?,
      purchaseReview: fields[12] as String?,
      reviewedAt: fields[13] as DateTime?,
      syncedAt: fields[14] as DateTime?,
      isDirty: fields[15] as bool,
      isDeleted: fields[16] as bool,
      localPhotoPath: fields[17] as String?,
      remotePhotoPath: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeclutterItemHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.nameLocalizations)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.photoPath)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(17)
      ..write(obj.localPhotoPath)
      ..writeByte(18)
      ..write(obj.remotePhotoPath)
      ..writeByte(10)
      ..write(obj.joyLevel)
      ..writeByte(11)
      ..write(obj.joyNotes)
      ..writeByte(12)
      ..write(obj.purchaseReview)
      ..writeByte(13)
      ..write(obj.reviewedAt)
      ..writeByte(14)
      ..write(obj.syncedAt)
      ..writeByte(15)
      ..write(obj.isDirty)
      ..writeByte(16)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeclutterItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
