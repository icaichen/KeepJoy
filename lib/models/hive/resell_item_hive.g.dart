// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resell_item_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResellItemHiveAdapter extends TypeAdapter<ResellItemHive> {
  @override
  final int typeId = 3;

  @override
  ResellItemHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResellItemHive(
      id: fields[0] as String,
      userId: fields[1] as String,
      declutterItemId: fields[2] as String,
      status: fields[3] as String,
      platform: fields[4] as String?,
      sellingPrice: fields[5] as double?,
      soldPrice: fields[6] as double?,
      soldDate: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime?,
      syncedAt: fields[10] as DateTime?,
      isDirty: fields[11] as bool,
      isDeleted: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ResellItemHive obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.declutterItemId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.platform)
      ..writeByte(5)
      ..write(obj.sellingPrice)
      ..writeByte(6)
      ..write(obj.soldPrice)
      ..writeByte(7)
      ..write(obj.soldDate)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.syncedAt)
      ..writeByte(11)
      ..write(obj.isDirty)
      ..writeByte(12)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResellItemHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
