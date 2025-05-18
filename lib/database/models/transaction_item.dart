// transaction_item.dart
// Model representing a single transaction (income, expense, transfer, or distribution).

import 'package:hive/hive.dart';

part '../transaction_item.g.dart';

@HiveType(typeId: 1)
class TransactionItem {
  @HiveField(0)
  double amount;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String note;

  @HiveField(3)
  bool isIncome;

  @HiveField(4)
  String? fromWallet;

  @HiveField(5)
  String? toWallet;

  @HiveField(6)
  bool isDistribution;

  TransactionItem({
    required this.amount,
    required this.date,
    required this.note,
    required this.isIncome,
    this.fromWallet,
    this.toWallet,
    this.isDistribution = false,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransactionItem &&
            amount == other.amount &&
            date == other.date &&
            note == other.note &&
            isIncome == other.isIncome &&
            fromWallet == other.fromWallet &&
            toWallet == other.toWallet &&
            isDistribution == other.isDistribution;
  }

  @override
  int get hashCode =>
      amount.hashCode ^
      date.hashCode ^
      note.hashCode ^
      isIncome.hashCode ^
      fromWallet.hashCode ^
      toWallet.hashCode ^
      isDistribution.hashCode;
}
