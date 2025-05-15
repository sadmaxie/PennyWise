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
  int colorValue;

  @HiveField(6)
  String? icon;

  @HiveField(7)
  double? incomePercent;

  @HiveField(8)
  List<TransactionItem> history;

  @HiveField(10)
  String? imagePath;

  @HiveField(11)
  DateTime? createdAt;

  @HiveField(12)
  double? totalAmount;
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
    this.imagePath,
    this.createdAt,
    this.totalAmount,
  });

  Wallet copyWith({
    String? name,
    double? amount,
    bool? isGoal,
    double? goalAmount,
    double? incomePercent,
    String? description,
    String? icon,
    int? colorValue,
    List<TransactionItem>? history,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Wallet(
      name: name ?? this.name,
      amount: (amount ?? this.amount).toDouble(),
      isGoal: isGoal ?? this.isGoal,
      goalAmount: (goalAmount ?? this.goalAmount)?.toDouble(),
      incomePercent: (incomePercent ?? this.incomePercent)?.toDouble(),
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      history: history ?? this.history,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Color get color => Color(colorValue);
}
