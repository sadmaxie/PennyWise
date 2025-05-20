// wallet_provider.dart
// Provider class for managing wallet state and transactions using Hive.

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pennywise/database/models/wallet.dart';
import 'package:pennywise/database/models/transaction_item.dart';

import '../../utils/toast_util.dart';

class WalletProvider extends ChangeNotifier {
  Box<Wallet> get _walletBox => Hive.box<Wallet>('walletsBox');

  List<Wallet> get wallets => _walletBox.values.toList();

  double get totalBalance =>
      wallets.fold(0.0, (sum, wallet) => sum + wallet.amount);

  double get overallTotalAmountForTopChart => totalBalance;

  Future<void> addWallet(Wallet wallet) async {
    await _walletBox.add(wallet);
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
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

  double totalIncomePercentExcluding({
    Wallet? excludeWallet,
    required String cardGroupId,
  }) {
    return wallets
        .where((wallet) =>
    wallet != excludeWallet &&
        wallet.cardGroupId == cardGroupId &&
        wallet.incomePercent != null)
        .map((wallet) => wallet.incomePercent!.toDouble())
        .fold(0.0, (sum, percent) => sum + percent);
  }


  List<TransactionItem> get allTransactions {
    return wallets.expand((wallet) => wallet.history).toList();
  }

  List<Wallet> get goalWallets {
    return wallets.where((wallet) => wallet.isGoal).toList();
  }

  List<TransactionItem> get goalWalletTransactions {
    return goalWallets.expand((wallet) => wallet.history).toList();
  }

  Future<void> updateWalletByKey(dynamic key, Wallet updated) async {
    await _walletBox.put(key, updated);
    notifyListeners();
  }

  Future<void> deleteWalletByKey(dynamic key) async {
    await _walletBox.delete(key);
    notifyListeners();
  }

  TransactionItem? _lastTransaction;
  Wallet? _lastFromWallet;
  Wallet? _lastToWallet;

  List<TransactionItem>? _lastBatchTransactions;
  List<MapEntry<dynamic, Wallet>>? _lastBatchWallets;

  void recordLastTransaction({
    required TransactionItem tx,
    Wallet? fromWallet,
    Wallet? toWallet,
  }) {
    _lastTransaction = tx;
    _lastFromWallet = fromWallet;
    _lastToWallet = toWallet;
  }

  void recordLastDistribution({
    required List<TransactionItem> transactions,
    required List<Wallet> updatedWallets,
  }) {
    _lastBatchTransactions = transactions;

    _lastBatchWallets =
        updatedWallets.map((wallet) {
          final txsToUndo =
              transactions.where((tx) => wallet.history.contains(tx)).toList();

          final originalAmount =
              wallet.amount - txsToUndo.fold(0.0, (sum, tx) => sum + tx.amount);
          final originalHistory = List<TransactionItem>.from(wallet.history)
            ..removeWhere((tx) => txsToUndo.contains(tx));

          final originalWallet = wallet.copyWith(
            amount: originalAmount,
            history: originalHistory,
          );

          return MapEntry(wallet.key, originalWallet);
        }).toList();
  }

  void undoLastAction() {
    if (_lastBatchTransactions != null && _lastBatchWallets != null) {
      for (final originalWallet in _lastBatchWallets!) {
        final key = originalWallet.key;
        if (key is int || key is String) {
          for (final entry in _lastBatchWallets!) {
            final key = entry.key;
            final wallet = entry.value;
            if (key is int || key is String) {
              updateWalletByKey(key, wallet);
            }
          }
        } else {
          debugPrint("Invalid key type: $key");
        }
      }

      _lastBatchTransactions = null;
      _lastBatchWallets = null;

      showToast("Income distribution undone", color: Color(0xFFF79B72));
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
