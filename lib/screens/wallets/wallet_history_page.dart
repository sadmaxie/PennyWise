/// WalletHistoryPage
/// Displays the full transaction history of a specific wallet.
/// Shows each transaction with date, amount, note, and income/expense type.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../database/models/transaction_item.dart';
import '../../database/providers/user_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../utils/currency_symbols.dart';
import '../../widgets/edit_transaction_sheet.dart';

class WalletHistoryPage extends StatelessWidget {
  final dynamic walletKey;

  const WalletHistoryPage({super.key, required this.walletKey});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    // Always fetch latest wallet by key
    final wallet = walletProvider.wallets.firstWhere(
          (w) => w.key == walletKey,
    );

    final history = wallet.history.reversed.toList();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, wallet),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                child: Text(
                  "No transactions found",
                  style: TextStyle(color: Colors.white54),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tx = history[index];
                  final isIncome = tx.isIncome;
                  final icon = isIncome
                      ? Icons.arrow_circle_down
                      : Icons.arrow_circle_up;
                  final color =
                  isIncome ? Colors.greenAccent : Colors.redAccent;
                  final amountText =
                      "${isIncome ? '+' : '-'}$currencySymbol${tx.amount.toStringAsFixed(2)}";

                  return Card(
                    color: const Color(0xFF292A3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: Icon(icon, color: color),
                      title: Text(
                        tx.note,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        DateFormat.yMMMd().format(tx.date),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            amountText,
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              showEditTransactionSheet(
                                context,
                                tx,
                                wallet,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, wallet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      color: const Color(0xFF2D2D49),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "${wallet.name} History",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
