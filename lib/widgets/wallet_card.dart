// wallet_card.dart
// A clickable card widget to display wallet info with edit, delete, and share progress.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/models/wallet.dart';
import '../database/providers/card_group_provider.dart';
import '../database/providers/user_provider.dart';
import '../database/providers/wallet_provider.dart';
import '../models/wallet_delete_dialog.dart';
import '../screens/wallets/wallet_details_page.dart';
import '../utils/currency_symbols.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final int? index;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WalletCard({
    Key? key,
    required this.wallet,
    this.index,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String created =
        wallet.createdAt != null
            ? DateFormat.yMMMd().format(wallet.createdAt!)
            : 'N/A';
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final cardGroupProvider = Provider.of<CardGroupProvider>(
      context,
      listen: false,
    );
    final currentCard = cardGroupProvider.selectedCardGroup;

    final chartItems =
        currentCard != null
            ? walletProvider.chartItemsForCardGroup(currentCard.id)
            : [];

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final matchingItem = chartItems.firstWhere(
      (item) => item.wallet == wallet,
      orElse:
          () => ProgressItemWithPercentage(
            name: wallet.name,
            amount: wallet.amount,
            percentage: 0,
            color: wallet.color,
            wallet: wallet,
          ),
    );

    final double share = matchingItem.percentage / 100;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WalletDetailsPage(walletKey: wallet.key),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              wallet.color.withOpacity(0.25),
              wallet.color.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet icon or image
            CircleAvatar(
              radius: 28,
              backgroundColor: wallet.color,
              backgroundImage:
                  (wallet.imagePath != null &&
                          File(wallet.imagePath!).existsSync())
                      ? FileImage(File(wallet.imagePath!))
                      : null,
              child:
                  wallet.imagePath == null
                      ? const Icon(Icons.wallet, color: Colors.white)
                      : null,
            ),
            const SizedBox(width: 16),

            // Wallet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$currencySymbol${wallet.amount.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Created: $created",
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          wallet.isGoal
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      wallet.isGoal
                          ? wallet.goalAmount != null
                              ? "Goal Wallet • \$${wallet.goalAmount!.toStringAsFixed(2)}"
                              : "Goal Wallet"
                          : "Normal Wallet",
                      style: TextStyle(
                        fontSize: 12,
                        color: wallet.isGoal ? Colors.amber : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit/Delete actions + share indicator
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        onPressed:
                            () => showDeleteWalletDialog(
                              context: context,
                              onConfirm: onDelete!,
                            ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 55,
                      height: 55,
                      child: CircularProgressIndicator(
                        value: share,
                        strokeWidth: 5,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(wallet.color),
                      ),
                    ),
                    Text(
                      "${(share * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
