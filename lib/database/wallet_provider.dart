import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pennywise/database/wallet.dart';
import 'package:pennywise/database/transaction_item.dart';

class WalletProvider extends ChangeNotifier {
  Box<Wallet> get _walletBox => Hive.box<Wallet>('walletsBox');

  List<Wallet> get wallets => _walletBox.values.toList();

  double get totalBalance =>
      wallets.fold(0.0, (sum, wallet) => sum + wallet.amount);

  double get overallTotalAmountForTopChart {
    return wallets.fold(0.0, (sum, wallet) => sum + wallet.amount);
  }

  Future<void> addWallet(Wallet wallet) async {
    await _walletBox.add(wallet);
    notifyListeners();
  }

  void refresh() {
    notifyListeners(); // Forces UI to update with fresh box values
  }

  Future<void> updateWallet(int index, Wallet updated) async {
    await _walletBox.putAt(index, updated);
    notifyListeners();
  }

  Future<void> deleteWallet(int index) async {
    await _walletBox.deleteAt(index);
    notifyListeners();
  }

  Future<void> addTransaction(int walletIndex, TransactionItem tx) async {
    final wallet = _walletBox.getAt(walletIndex);
    if (wallet == null) return;

    wallet.history.add(tx);
    wallet.amount += tx.isIncome ? tx.amount : -tx.amount;

    await wallet.save();
    notifyListeners();
  }

  double getWalletShare(Wallet wallet) {
    if (totalBalance == 0) return 0;
    return (wallet.amount / totalBalance) * 100;
  }

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

  double totalIncomePercentExcluding(Wallet? excludeWallet) {
    return wallets
        .where((wallet) =>
    wallet != excludeWallet && wallet.incomePercent != null)
        .map((wallet) => wallet.incomePercent!)
        .fold(0.0, (sum, percent) => sum + percent);
  }
}

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
