import 'package:hive/hive.dart';

part 'transaction_item.g.dart';

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

  TransactionItem({
    required this.amount,
    required this.date,
    required this.note,
    required this.isIncome,
    this.fromWallet,
    this.toWallet,
  });
}
