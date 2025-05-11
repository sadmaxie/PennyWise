import 'package:flutter/material.dart';
import '../temp_data.dart';

class ProgressItemWithPercentage {
  final String name;
  final Color color;
  final double amount;
  final double percentage;

  ProgressItemWithPercentage({
    required this.name,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

List<ProgressItemWithPercentage> getProgressWithPercentage() {
  final items = getTempProgressItems();
  final total = items.fold<double>(0, (sum, item) => sum + item.amount);

  return items.map((item) {
    final percentage = total == 0 ? 0.0 : (item.amount / total) * 100;
    return ProgressItemWithPercentage(
      name: item.name,
      color: item.color,
      amount: item.amount,
      percentage: percentage,
    );
  }).toList();
}
