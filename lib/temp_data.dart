import 'package:flutter/material.dart';

class ProgressItem {
  final String name;
  final Color color;
  final double amount;

  ProgressItem({
    required this.name,
    required this.color,
    required this.amount,
  });
}

List<ProgressItem> getTempProgressItems() {
  return [
    ProgressItem(name: "Gold", color: Colors.amber, amount: 1000.00),
    ProgressItem(name: "Silver", color: Colors.cyan, amount: 1600.00),
    ProgressItem(name: "Ruby", color: Colors.pinkAccent, amount: 800.00),
    ProgressItem(name: "Emerald", color: Colors.greenAccent, amount: 1024.00),
    ProgressItem(name: "Platinum", color: Colors.blueGrey, amount: 999.99),
    ProgressItem(name: "Copper", color: Colors.orange, amount: 300.50),
    ProgressItem(name: "Sapphire", color: Colors.teal, amount: 750.00),
    ProgressItem(name: "Garnet", color: Colors.redAccent, amount: 1100.00),
    ProgressItem(name: "Amethyst", color: Colors.purple, amount: 1850.00),
    ProgressItem(name: "Zinc", color: Colors.lime, amount: 1000.00),
  ];
}
