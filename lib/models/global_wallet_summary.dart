import 'dart:io';

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

    final allTransactions =
        walletProvider.allTransactions
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
        child: Text(
          "No transactions yet.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          transactions.take(10).map((tx) {
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
      children:
          goals.map((goal) {
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
    final transactions =
        provider.allTransactions..sort((a, b) => b.date.compareTo(a.date));

    if (transactions.isEmpty) {
      return const Text(
        "No transactions yet.",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children:
          transactions.take(4).map((tx) {
            final isMove = tx.fromWallet != null && tx.toWallet != null;

            final icon =
                isMove
                    ? Icons.currency_exchange_outlined
                    : tx.isDistribution
                    ? Icons.paid_outlined
                    : tx.isIncome
                    ? Icons.arrow_downward
                    : Icons.arrow_upward;

            final color =
                isMove
                    ? Colors.orangeAccent.shade200
                    : tx.isDistribution
                    ? Colors.lightBlueAccent.shade100
                    : tx.isIncome
                    ? Colors.greenAccent
                    : Colors.redAccent;

            // New wallet label for move transactions
            final walletLabel =
                isMove
                    ? "${tx.fromWallet} ➤ ${tx.toWallet}"
                    : provider.wallets
                        .firstWhere(
                          (w) => w.history.contains(tx),
                          orElse:
                              () => Wallet(
                                name: "Unknown Wallet",
                                amount: 0,
                                isGoal: false,
                                colorValue: Colors.grey.value,
                                history: [],
                              ),
                        )
                        .name;

            // Show note only if there's one
            final showNote = tx.note.trim().isNotEmpty;
            final noteText = tx.note.trim();

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
                          walletLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (showNote)
                          Text(
                            noteText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
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
                    (tx.isIncome ? "+ " : "- ") +
                        "\$${tx.amount.toStringAsFixed(2)}",
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
    final goals =
        provider.goalWallets..sort((a, b) {
          final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

    if (goals.isEmpty) {
      return const Text(
        "No goal wallets yet.",
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          goals.take(4).map((wallet) {
            final total = wallet.goalAmount ?? 0.0;
            final current = wallet.amount;
            final amountLeft = (total - current).clamp(0.0, double.infinity);
            final progress =
                (total == 0) ? 0.0 : (current / total).clamp(0.0, 1.0);
            final hasImage =
                wallet.imagePath != null &&
                File(wallet.imagePath!).existsSync();

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    wallet.color.withOpacity(0.08),
                    wallet.color.withOpacity(0.09),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar on the left
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: wallet.color.withOpacity(0.3),
                    backgroundImage:
                        hasImage ? FileImage(File(wallet.imagePath!)) : null,
                    child:
                        !hasImage
                            ? const Icon(
                              Icons.flag_outlined,
                              color: Colors.white,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),

                  // Wallet info + progress
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wallet.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${current.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "of \$${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            wallet.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${(progress * 100).toStringAsFixed(0)}% Reached",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              "\$${amountLeft.toStringAsFixed(2)} left",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
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
