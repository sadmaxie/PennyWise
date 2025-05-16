// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models/card_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardGroupAdapter extends TypeAdapter<CardGroup> {
  @override
  final int typeId = 3;

  @override
  CardGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      imagePath: fields[3] as String?,
      colorHex: fields[4] as String,
      isDefault: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CardGroup obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.colorHex)
      ..writeByte(5)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
