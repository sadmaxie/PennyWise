// wallet_provider.dart
// Provider class for managing wallet state and transactions using Hive.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pennywise/database/wallet.dart';
import 'package:pennywise/database/transaction_item.dart';

class WalletProvider extends ChangeNotifier {
  Box<Wallet> get _walletBox => Hive.box<Wallet>('walletsBox');

  /// Returns all wallets stored in Hive.
  List<Wallet> get wallets => _walletBox.values.toList();

  /// Total balance across all wallets.
  double get totalBalance =>
      wallets.fold(0.0, (sum, wallet) => sum + wallet.amount);

  /// Alias for totalBalance (used for top chart).
  double get overallTotalAmountForTopChart => totalBalance;

  /// Adds a new wallet and updates listeners.
  Future<void> addWallet(Wallet wallet) async {
    await _walletBox.add(wallet);
    notifyListeners();
  }

  /// Forces UI to update from Hive box.
  void refresh() {
    notifyListeners();
  }

  /// Updates wallet at index with new data.
  Future<void> updateWallet(int index, Wallet updated) async {
    await _walletBox.putAt(index, updated);
    notifyListeners();
  }

  /// Deletes a wallet by index.
  Future<void> deleteWallet(int index) async {
    await _walletBox.deleteAt(index);
    notifyListeners();
  }

  /// Adds a transaction to a wallet, updating amount and history.
  Future<void> addTransaction(int walletIndex, TransactionItem tx) async {
    final wallet = _walletBox.getAt(walletIndex);
    if (wallet == null) return;

    wallet.history.add(tx);
    wallet.amount += tx.isIncome ? tx.amount : -tx.amount;

    await wallet.save();
    notifyListeners();
  }

  /// Calculates percentage share of a wallet relative to total.
  double getWalletShare(Wallet wallet) {
    if (totalBalance == 0) return 0;
    return (wallet.amount / totalBalance) * 100;
  }

  /// Converts wallets into progress bar data with percentages.
  List<ProgressItemWithPercentage> get chartItems {
    final total = totalBalance;
    return wallets.map((wallet) {
      final percent = total == 0 ? 0.0 : (wallet.amount / total) * 100;
      return ProgressItemWithPercentage(
        name: wallet.name,
        amount: wallet.amount,
        percentage: percent,
        color: wallet.color,
      );
    }).toList();
  }

  /// Sums up income percentages of all wallets excluding one (for validation).
  double totalIncomePercentExcluding(Wallet? excludeWallet) {
    return wallets
        .where((wallet) => wallet != excludeWallet && wallet.incomePercent != null)
        .map((wallet) => wallet.incomePercent!)
        .fold(0.0, (sum, percent) => sum + percent);
  }

  /// Returns all transactions from all wallets.
  List<TransactionItem> get allTransactions {
    return wallets.expand((wallet) => wallet.history).toList();
  }

  /// Filters only goal-based wallets.
  List<Wallet> get goalWallets {
    return wallets.where((wallet) => wallet.isGoal).toList();
  }

  /// Returns all transactions from goal wallets.
  List<TransactionItem> get goalWalletTransactions {
    return goalWallets.expand((wallet) => wallet.history).toList();
  }
}

/// Model for progress bar chart visualization.
class ProgressItemWithPercentage {
  final String name;
  final double amount;
  final double percentage;
  final Color color;

  ProgressItemWithPercentage({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}
