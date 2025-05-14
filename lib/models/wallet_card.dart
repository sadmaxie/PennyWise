import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:pennywise/models/wallet_details_page.dart';
import 'package:pennywise/database/wallet.dart';
import '../database/wallet_provider.dart';
import '../models/wallet_delete_dialog.dart';

class WalletCard extends StatefulWidget {
  final Wallet wallet;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WalletCard({
    super.key,
    required this.wallet,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);
    final wallet = widget.wallet;
    final totalBalance = provider.totalBalance;

    final share = totalBalance == 0
        ? 0.0
        : (wallet.amount / totalBalance * 100).clamp(0.0, 100.0);
    final created = wallet.createdAt != null
        ? DateFormat.yMMMd().format(wallet.createdAt!)
        : 'No Date';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: wallet.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: wallet.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalletDetailsPage(wallet: wallet),
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Icon
                CircleAvatar(
                  radius: 26,
                  backgroundColor: wallet.color,
                  backgroundImage: (wallet.imagePath != null &&
                      File(wallet.imagePath!).existsSync())
                      ? FileImage(File(wallet.imagePath!))
                      : null,
                  child: wallet.imagePath == null
                      ? const Icon(Icons.wallet, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),

                // Wallet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${wallet.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        created,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: wallet.isGoal
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wallet.isGoal ? "Goal Wallet" : "Normal Wallet",
                          style: TextStyle(
                            fontSize: 12,
                            color: wallet.isGoal ? Colors.amber : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit / Delete & Circular Indicator
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                        IconButton(
                          onPressed: () => showDeleteWalletDialog(
                            context: context,
                            onConfirm: widget.onDelete,
                          ),
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: share / 100,
                            strokeWidth: 4,
                            backgroundColor: Colors.white12,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(wallet.color),
                          ),
                          Text(
                            '${share.toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expanded info (description + recent transactions)
          if (isExpanded) ...[
            const SizedBox(height: 16),
            if (wallet.description?.isNotEmpty == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  wallet.description!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: wallet.history.reversed.take(4).map(
                    (item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      item.isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: item.isIncome
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                    title: Text(item.note ?? '',
                        style: const TextStyle(color: Colors.white)),
                    trailing: Text('\$${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white)),
                  );
                },
              ).toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full history screen
                },
                child: const Text("Show All",
                    style: TextStyle(color: Colors.white70)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
