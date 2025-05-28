// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models/notification_time.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationTimeAdapter extends TypeAdapter<NotificationTime> {
  @override
  final int typeId = 4;

  @override
  NotificationTime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationTime(
      hour: fields[0] as int,
      minute: fields[1] as int,
      isEnabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationTime obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.hour)
      ..writeByte(1)
      ..write(obj.minute)
      ..writeByte(2)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
