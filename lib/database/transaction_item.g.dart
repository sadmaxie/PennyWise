// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionItemAdapter extends TypeAdapter<TransactionItem> {
  @override
  final int typeId = 1;

  @override
  TransactionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionItem(
      amount: fields[0] as double,
      date: fields[1] as DateTime,
      note: fields[2] as String,
      isIncome: fields[3] as bool,
      fromWallet: fields[4] as String?,
      toWallet: fields[5] as String?,
      isDistribution: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.isIncome)
      ..writeByte(4)
      ..write(obj.fromWallet)
      ..writeByte(5)
      ..write(obj.toWallet)
      ..writeByte(6)
      ..write(obj.isDistribution);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
