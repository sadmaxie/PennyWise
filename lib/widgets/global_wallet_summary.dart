// global_wallet_summary.dart
// Displays transaction history and goal wallet progress summaries.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/database/models/wallet.dart';
import 'package:pennywise/database/models/transaction_item.dart';
import 'package:intl/intl.dart';

import '../database/providers/card_group_provider.dart';
import '../database/providers/user_provider.dart';
import '../database/providers/wallet_provider.dart';
import '../utils/currency_symbols.dart';

class GlobalWalletSummary extends StatelessWidget {
  const GlobalWalletSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final currentCard = cardGroupProvider.selectedCardGroup;

    final userProvider = Provider.of<UserProvider>(context);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    if (currentCard == null) {
      return const Center(
        child: Text(
          "Please create a card group first.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Consumer<WalletProvider>(
      builder: (context, walletProvider, _) {
        final goalWallets = walletProvider.goalWallets
            .where((w) => w.cardGroupId == currentCard.id)
            .toList();

        final allTransactions = walletProvider.allTransactions
            .where((tx) {
          final wallet = walletProvider.wallets.firstWhere(
                (w) => w.history.contains(tx),
            orElse: () => Wallet(
              name: "Unknown",
              amount: 0,
              isGoal: false,
              colorValue: Colors.grey.value,
              history: [],
              cardGroupId: "unknown",
            ),
          );
          return wallet.cardGroupId == currentCard.id;
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildHistorySection(allTransactions, currencySymbol)),
            const SizedBox(width: 20),
            Expanded(child: _buildGoalsSection(goalWallets, currencySymbol)),
          ],
        );
      },
    );
  }


  Widget _buildHistorySection(
    List<TransactionItem> transactions,
    String currencySymbol,
  ) {
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
                        '${tx.isIncome ? '+ ' : '- '}$currencySymbol${tx.amount.toStringAsFixed(2)}',
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

  Widget _buildGoalsSection(List<Wallet> goals, String currencySymbol) {
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
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Missing: $currencySymbol${missing.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.amber),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Goal: $currencySymbol${total.toStringAsFixed(2)}',
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
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final currentCard = cardGroupProvider.selectedCardGroup;

    final userProvider = Provider.of<UserProvider>(context);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final transactions =
        provider.allTransactions.where((tx) {
            final wallet = provider.wallets.firstWhere(
              (w) => w.history.contains(tx),
              orElse:
                  () => Wallet(
                    name: "Unknown",
                    amount: 0,
                    isGoal: false,
                    colorValue: Colors.grey.value,
                    history: [],
                    cardGroupId: "unknown",
                  ),
            );
            return wallet.cardGroupId == currentCard?.id;
          }).toList()
          ..sort((a, b) => b.date.compareTo(a.date));

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
                                cardGroupId: "unknown",
                              ),
                        )
                        .name;

            final showNote = tx.note.trim().isNotEmpty;

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
                          ),
                        ),
                        if (showNote)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              tx.note.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
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
                    "${tx.isIncome ? '+ ' : '- '}$currencySymbol${tx.amount.toStringAsFixed(2)}",
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
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final currentCard = cardGroupProvider.selectedCardGroup;

    final userProvider = Provider.of<UserProvider>(context);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    if (currentCard == null) {
      return const Center(
        child: Text(
          "Please create a card group first.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final goals =
        provider.goalWallets
            .where((w) => w.cardGroupId == currentCard.id)
            .toList()
          ..sort((a, b) {
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

            final formattedCurrent =
                "$currencySymbol${current.toStringAsFixed(2)}";
            final formattedGoal = "$currencySymbol${total.toStringAsFixed(2)}";
            final formattedLeft =
                "$currencySymbol${amountLeft.toStringAsFixed(2)}";

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
                              formattedCurrent,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "of $formattedGoal",
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
                              "$formattedLeft left",
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
