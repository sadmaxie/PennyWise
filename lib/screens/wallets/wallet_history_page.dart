/// WalletHistoryPage
/// Displays the full transaction history of a specific wallet.
/// Shows each transaction with date, amount, note, and income/expense type.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/wallet.dart';

class WalletHistoryPage extends StatelessWidget {
  final Wallet wallet;

  const WalletHistoryPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final history = wallet.history.reversed.toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
                      "${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}";

                  return Card(
                    color: const Color(0xFF292A3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      leading: Icon(icon, color: color),
                      title: Text(tx.note,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        DateFormat.yMMMd().format(tx.date),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      ),
                      trailing: Text(
                        amountText,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildHeader(BuildContext context) {
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
