// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryHiveAdapter extends TypeAdapter<MemoryHive> {
  @override
  final int typeId = 0;

  @override
  MemoryHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryHive(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String?,
      photoPath: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
      type: fields[7] as String,
      itemName: fields[8] as String?,
      category: fields[9] as String?,
      notes: fields[10] as String?,
      sentiment: fields[11] as String?,
      syncedAt: fields[12] as DateTime?,
      isDirty: fields[13] as bool,
      isDeleted: fields[14] as bool,
      localPhotoPath: fields[23] as String?,
      remotePhotoPath: fields[24] as String?,
      deletedAt: fields[25] as DateTime?,
      deviceId: fields[26] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.photoPath)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(23)
      ..write(obj.localPhotoPath)
      ..writeByte(24)
      ..write(obj.remotePhotoPath)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.itemName)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.sentiment)
      ..writeByte(12)
      ..write(obj.syncedAt)
      ..writeByte(13)
      ..write(obj.isDirty)
      ..writeByte(14)
      ..write(obj.isDeleted)
      ..writeByte(25)
      ..write(obj.deletedAt)
      ..writeByte(26)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
