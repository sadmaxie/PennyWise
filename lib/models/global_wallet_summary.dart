import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/database/wallet.dart';
import 'package:pennywise/database/transaction_item.dart';
import 'package:intl/intl.dart';

import '../database/wallet_provider.dart';

class GlobalWalletSummary extends StatelessWidget {
  const GlobalWalletSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    final allTransactions = walletProvider.allTransactions
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by latest
    final goalWallets = walletProvider.goalWallets;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildHistorySection(allTransactions)),
        const SizedBox(width: 20),
        Expanded(child: _buildGoalsSection(goalWallets)),
      ],
    );
  }

  Widget _buildHistorySection(List<TransactionItem> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text("No transactions yet.", style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: transactions.take(10).map((tx) {
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
                      tx.note,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                    DateFormat.yMMMd().format(tx.date),
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

  Widget _buildGoalsSection(List<Wallet> goals) {
    if (goals.isEmpty) {
      return const Center(
        child: Text("No goals set.", style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: goals.map((goal) {
        final total = goal.totalAmount ?? 0.0;
        final missing = total - goal.amount;

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
              Text(
                goal.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Missing: \$${missing.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.amber),
              ),
              const SizedBox(height: 4),
              Text(
                'Goal: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class TransactionHistoryList extends StatelessWidget {
  const TransactionHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);
    final transactions = provider.allTransactions
      ..sort((a, b) => b.date.compareTo(a.date));

    if (transactions.isEmpty) {
      return const Text("No transactions yet.", style: TextStyle(color: Colors.white70));
    }

    return Column(
      children: transactions.take(4).map((tx) {
        final note = tx.note.toLowerCase();

        IconData icon;
        Color color;

        if (note.contains('→')) {
          // move transaction
          icon = Icons.currency_exchange_outlined;
          color = Colors.orangeAccent.shade200;
        } else if (note.contains('income distribution') || note.contains('remaining income')) {
          icon = Icons.paid_outlined;
          color = Colors.lightBlueAccent.shade100;
        } else if (tx.isIncome) {
          icon = Icons.arrow_downward;
          color = Colors.greenAccent;
        } else {
          icon = Icons.arrow_upward;
          color = Colors.redAccent;
        }



        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.note,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(tx.date),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                (tx.isIncome ? "+ " : "- ") + "\$${tx.amount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}



class GoalWalletList extends StatelessWidget {
  const GoalWalletList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);
    final goals = provider.goalWallets;

    if (goals.isEmpty) {
      return const Text("No goal wallets yet.", style: TextStyle(color: Colors.white70));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: goals.map((goal) {
        final total = goal.totalAmount ?? 0.0;
        final current = goal.amount;
        final missing = total - current;
        final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                goal.color.withOpacity(0.20),
                goal.color.withOpacity(0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: goal.color.withOpacity(0.25),
                child: const Icon(Icons.flag_outlined, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${current.toStringAsFixed(2)} / \$${total.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                    if (missing > 0)
                      Text(
                        "Missing: \$${missing.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

