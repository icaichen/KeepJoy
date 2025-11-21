// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_session_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannedSessionHiveAdapter extends TypeAdapter<PlannedSessionHive> {
  @override
  final int typeId = 4;

  @override
  PlannedSessionHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedSessionHive(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      area: fields[3] as String,
      scheduledDate: fields[4] as DateTime?,
      scheduledTime: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime?,
      notes: fields[8] as String?,
      isCompleted: fields[9] as bool,
      completedAt: fields[10] as DateTime?,
      priority: fields[11] as String,
      mode: fields[12] as String,
      goal: fields[13] as String?,
      syncedAt: fields[14] as DateTime?,
      isDirty: fields[15] as bool,
      isDeleted: fields[16] as bool,
      deletedAt: fields[17] as DateTime?,
      deviceId: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedSessionHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.area)
      ..writeByte(4)
      ..write(obj.scheduledDate)
      ..writeByte(5)
      ..write(obj.scheduledTime)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.isCompleted)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.priority)
      ..writeByte(12)
      ..write(obj.mode)
      ..writeByte(13)
      ..write(obj.goal)
      ..writeByte(14)
      ..write(obj.syncedAt)
      ..writeByte(15)
      ..write(obj.isDirty)
      ..writeByte(16)
      ..write(obj.isDeleted)
      ..writeByte(17)
      ..write(obj.deletedAt)
      ..writeByte(18)
      ..write(obj.deviceId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedSessionHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
