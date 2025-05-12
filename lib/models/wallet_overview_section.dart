import 'package:flutter/material.dart';
import '../temp_data.dart';

class WalletOverviewSection extends StatelessWidget {
  const WalletOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildWalletHistoryList()),
        SizedBox(width: 20),
        Expanded(child: _buildWalletGoalsList()),
      ],
    );
  }
}

// History Column — UNCHANGED
Widget _buildWalletHistoryList() {
  final transactions = getRecentTransactions();

  return Column(
    children:
        transactions.map((tx) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3F3F58),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9797A4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      tx.isIncome
                          ? Icons.arrow_circle_down_outlined
                          : Icons.arrow_circle_up_outlined,
                      size: 25,
                      color: tx.isIncome ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tx.type,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${tx.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      tx.date,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
  );
}

// Goals Column — Styled like history, but different content inside
Widget _buildWalletGoalsList() {
  final goals = getRecentGoals();

  return Column(
    children:
        goals.map((goal) {
          final missingAmount = goal.totalAmount - goal.currentAmount;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3F3F58),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF9797A4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Spacer()]),
                Text(
                  goal.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Text(
                  'Missing: \$${missingAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.amber),
                ),
                const SizedBox(height: 5),
                Text(
                  'Total: \$${goal.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }).toList(),
  );
}
