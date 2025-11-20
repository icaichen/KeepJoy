// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_cleaning_session_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeepCleaningSessionHiveAdapter
    extends TypeAdapter<DeepCleaningSessionHive> {
  @override
  final int typeId = 1;

  @override
  DeepCleaningSessionHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeepCleaningSessionHive(
      id: fields[0] as String,
      userId: fields[1] as String,
      area: fields[2] as String,
      startTime: fields[3] as DateTime,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime?,
      beforePhotoPath: fields[6] as String?,
      afterPhotoPath: fields[7] as String?,
      elapsedSeconds: fields[8] as int?,
      itemsCount: fields[9] as int?,
      focusIndex: fields[10] as int?,
      moodIndex: fields[11] as int?,
      beforeMessinessIndex: fields[12] as double?,
      afterMessinessIndex: fields[13] as double?,
      syncedAt: fields[14] as DateTime?,
      isDirty: fields[15] as bool,
      isDeleted: fields[16] as bool,
      localBeforePhotoPath: fields[17] as String?,
      remoteBeforePhotoPath: fields[18] as String?,
      localAfterPhotoPath: fields[19] as String?,
      remoteAfterPhotoPath: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeepCleaningSessionHive obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.area)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.beforePhotoPath)
      ..writeByte(7)
      ..write(obj.afterPhotoPath)
      ..writeByte(8)
      ..write(obj.elapsedSeconds)
      ..writeByte(17)
      ..write(obj.localBeforePhotoPath)
      ..writeByte(18)
      ..write(obj.remoteBeforePhotoPath)
      ..writeByte(19)
      ..write(obj.localAfterPhotoPath)
      ..writeByte(20)
      ..write(obj.remoteAfterPhotoPath)
      ..writeByte(9)
      ..write(obj.itemsCount)
      ..writeByte(10)
      ..write(obj.focusIndex)
      ..writeByte(11)
      ..write(obj.moodIndex)
      ..writeByte(12)
      ..write(obj.beforeMessinessIndex)
      ..writeByte(13)
      ..write(obj.afterMessinessIndex)
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
      other is DeepCleaningSessionHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
