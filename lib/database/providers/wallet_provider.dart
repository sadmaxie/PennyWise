// wallet_provider.dart
// Provider class for managing wallet state and transactions using Hive.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pennywise/database/models/wallet.dart';
import 'package:pennywise/database/models/transaction_item.dart';

import '../../utils/toast_util.dart';

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
  List<ProgressItemWithPercentage> chartItemsForCardGroup(String cardGroupId) {
    final groupWallets =
        wallets.where((w) => w.cardGroupId == cardGroupId).toList();
    final total = groupWallets.fold(0.0, (sum, w) => sum + w.amount);

    return groupWallets.map((wallet) {
      final percent = total == 0 ? 0.0 : (wallet.amount / total) * 100;
      return ProgressItemWithPercentage(
        name: wallet.name,
        amount: wallet.amount,
        percentage: percent,
        color: wallet.color,
        wallet: wallet,
      );
    }).toList();
  }

  /// Sums up income percentages of all wallets excluding one (for validation).
  double totalIncomePercentExcluding(Wallet? excludeWallet) {
    final currentCardGroupId = excludeWallet?.cardGroupId;

    return wallets
        .where(
          (wallet) =>
              wallet != excludeWallet &&
              wallet.cardGroupId == currentCardGroupId &&
              wallet.incomePercent != null,
        )
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

  /// Updates wallet by Hive key.
  Future<void> updateWalletByKey(dynamic key, Wallet updated) async {
    await _walletBox.put(key, updated);
    notifyListeners();
  }

  /// Deletes a wallet by Hive key.
  Future<void> deleteWalletByKey(dynamic key) async {
    await _walletBox.delete(key);
    notifyListeners();
  }

  TransactionItem? _lastTransaction;
  Wallet? _lastFromWallet;
  Wallet? _lastToWallet;

  void recordLastTransaction({
    required TransactionItem tx,
    Wallet? fromWallet,
    Wallet? toWallet,
  }) {
    _lastTransaction = tx;
    _lastFromWallet = fromWallet;
    _lastToWallet = toWallet;
  }

  List<TransactionItem>? _lastBatchTransactions;
  List<Wallet>? _lastBatchWallets;

  /// Undo the last action.
  void undoLastAction() {
    if (_lastBatchTransactions != null && _lastBatchWallets != null) {
      for (int i = 0; i < _lastBatchTransactions!.length; i++) {
        final tx = _lastBatchTransactions![i];
        final wallet = _lastBatchWallets![i];

        final updated = wallet.copyWith(
          amount: (wallet.amount - tx.amount).clamp(0, double.infinity),
          history: wallet.history..remove(tx),
        );

        updateWalletByKey(wallet.key, updated);
      }

      _lastBatchTransactions = null;
      _lastBatchWallets = null;

      showToast("Income distribution undone", color: Colors.orangeAccent);
      return;
    }

    if (_lastTransaction == null) {
      showToast("Nothing to undo", color: Colors.redAccent);
      return;
    }

    final tx = _lastTransaction!;
    final from = _lastFromWallet;
    final to = _lastToWallet;

    if (from != null && to != null) {
      // Move transaction: reverse transfer
      final updatedFrom = from.copyWith(
        amount: from.amount + tx.amount,
        history: from.history..remove(tx),
      );

      final updatedTo = to.copyWith(
        amount: (to.amount - tx.amount).clamp(0, double.infinity),
        history: to.history..remove(tx),
      );

      updateWalletByKey(from.key, updatedFrom);
      updateWalletByKey(to.key, updatedTo);
      showToast("Last move transaction undone", color: Color(0xFFF79B72));
    } else {
      // Income or expense
      final wallet = _findWalletWithTx(tx);
      if (wallet != null) {
        final adjustedAmount =
            tx.isIncome
                ? (wallet.amount - tx.amount)
                : (wallet.amount + tx.amount);

        final updated = wallet.copyWith(
          amount: adjustedAmount,
          history: wallet.history..remove(tx),
        );
        updateWalletByKey(wallet.key, updated);

        showToast(
          tx.isIncome ? "Last income undone" : "Last expense undone",
          color: Color(0xFFF79B72),
        );
      }
    }

    _lastTransaction = null;
    _lastFromWallet = null;
    _lastToWallet = null;
  }

  void recordLastDistribution({
    required List<TransactionItem> transactions,
    required List<Wallet> updatedWallets,
  }) {
    _lastBatchTransactions = transactions;
    _lastBatchWallets = updatedWallets;
  }

  Wallet? _findWalletWithTx(TransactionItem tx) {
    try {
      return wallets.firstWhere((w) => w.history.contains(tx));
    } catch (_) {
      return null;
    }
  }
}

/// Model for progress bar chart visualization.
class ProgressItemWithPercentage {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final Wallet wallet;

  ProgressItemWithPercentage({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.wallet,
  });
}
