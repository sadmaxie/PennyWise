import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pennywise/database/wallet.dart';
import 'package:pennywise/database/transaction_item.dart';

class WalletProvider extends ChangeNotifier {
  final Box<Wallet> _walletBox = Hive.box<Wallet>('walletsBox');

  List<Wallet> get wallets => _walletBox.values.toList();

  /// Total value across all wallets
  double get totalBalance =>
      wallets.fold(0.0, (sum, wallet) => sum + wallet.amount);

  /// Add a new wallet
  Future<void> addWallet(Wallet wallet) async {
    await _walletBox.add(wallet);
    notifyListeners();
  }

  /// Update an existing wallet
  Future<void> updateWallet(int index, Wallet updated) async {
    await _walletBox.putAt(index, updated);
    notifyListeners();
  }

  /// Delete wallet
  Future<void> deleteWallet(int index) async {
    await _walletBox.deleteAt(index);
    notifyListeners();
  }

  /// Add transaction to a wallet by index
  Future<void> addTransaction(int walletIndex, TransactionItem tx) async {
    final wallet = _walletBox.getAt(walletIndex);
    if (wallet == null) return;

    wallet.history.add(tx);

    // Adjust amount
    wallet.amount += tx.isIncome ? tx.amount : -tx.amount;

    await wallet.save();
    notifyListeners();
  }

  /// Get wallet share (percentage from total)
  double getWalletShare(Wallet wallet) {
    if (totalBalance == 0) return 0;
    return (wallet.amount / totalBalance) * 100;
  }
}
