// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 0;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      name: fields[0] as String,
      amount: fields[1] as double,
      isGoal: fields[2] as bool,
      goalAmount: fields[3] as double?,
      description: fields[4] as String?,
      colorValue: fields[5] as int,
      icon: fields[6] as String?,
      incomePercent: fields[7] as double?,
      history: (fields[8] as List).cast<TransactionItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.isGoal)
      ..writeByte(3)
      ..write(obj.goalAmount)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.icon)
      ..writeByte(7)
      ..write(obj.incomePercent)
      ..writeByte(8)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
