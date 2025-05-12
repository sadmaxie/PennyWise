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
    ProgressItem(name: "red", color: Colors.red, amount: 1350.00),
  ];
}

// History

class Transaction {
  final String type;
  final double amount;
  final String date;
  final bool isIncome;

  Transaction({
    required this.type,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}

List<Transaction> getTransactionHistory() {
  return [
    Transaction(type: "Tip From Alex", amount: 200, date: "15 Feb", isIncome: true),
    Transaction(type: "Cat Food", amount: 20, date: "14 Feb", isIncome: false),
    Transaction(type: "Freelance", amount: 500, date: "16 Feb", isIncome: true),
    Transaction(type: "Groceries", amount: 120, date: "15 Feb", isIncome: false),
    // Add more as needed
  ];
}

List<Transaction> getRecentTransactions() {
  final all = getTransactionHistory();
  if (all.length <= 2) return all.reversed.toList();
  return all.sublist(all.length - 2).reversed.toList();
}

// Goal
class Goal {
  final String name;
  final double currentAmount;
  final double totalAmount;

  Goal({
    required this.name,
    required this.currentAmount,
    required this.totalAmount,
  });
}

List<Goal> getAllGoals() {
  return [
    Goal(name: "MacBook Pro", currentAmount: 1200, totalAmount: 2200),
    Goal(name: "Vacation", currentAmount: 800, totalAmount: 1500),
    Goal(name: "New Desk", currentAmount: 100, totalAmount: 400),
    Goal(name: "Gaming Chair", currentAmount: 50, totalAmount: 300),
  ];
}

List<Goal> getRecentGoals() {
  final all = getAllGoals();
  return all.length <= 2 ? all : all.sublist(all.length - 2).reversed.toList();
}
