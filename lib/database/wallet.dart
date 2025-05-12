import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pennywise/database/transaction_item.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class Wallet extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double amount;

  @HiveField(2)
  bool isGoal;

  @HiveField(3)
  double? goalAmount;

  @HiveField(4)
  String? description;

  @HiveField(5)
  int colorValue; // we store color as int

  @HiveField(6)
  String? icon; // optional - can be extended

  @HiveField(7)
  double? incomePercent;

  @HiveField(8)
  List<TransactionItem> history;

  Wallet({
    required this.name,
    required this.amount,
    required this.isGoal,
    this.goalAmount,
    this.description,
    required this.colorValue,
    this.icon,
    this.incomePercent,
    required this.history,
  });

  /// Helper to get the actual Color object from the stored int
  Color get color => Color(colorValue);
}
