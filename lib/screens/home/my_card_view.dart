/// MyCardView
/// Displays a scrollable list of "card groups" used to categorize wallets.
/// Each card shows:
/// - Total balance of associated wallets
/// - Optional background image and color
/// - Actions: select (double-tap), edit, or delete
///
/// Allows creating and editing card groups using bottom sheets.

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/card_group.dart';
import '../../database/providers/card_group_provider.dart';
import '../../database/providers/user_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../utils/currency_symbols.dart';
import '../../wallet/card_create_sheet.dart';

class MyCardView extends StatelessWidget {
  final VoidCallback? onCardSelected;

  const MyCardView({super.key, this.onCardSelected});

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardGroupProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final cardGroups = cardProvider.cardGroups;
    final selectedId = cardProvider.selectedCardGroup?.id;

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D49),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.touch_app_outlined, color: Colors.white54, size: 16),
                SizedBox(width: 8),
                Text(
                  "Double tap a card to select it",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
                  cardGroups.isEmpty
                      ? Center(
                        child: const Text(
                          'Create your first card',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: cardGroups.length,
                        itemBuilder: (context, index) {
                          final card = cardGroups[index];
                          final isSelected = card.id == selectedId;
                          return _buildCardItem(
                            context,
                            card,
                            cardProvider,
                            walletProvider,
                            isSelected,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B3B52),
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    CardGroup card,
    CardGroupProvider cardProvider,
    WalletProvider walletProvider,
    bool isSelected,
  ) {
    final hasImage =
        card.imagePath != null && File(card.imagePath!).existsSync();
    final chartItems = walletProvider.chartItemsForCardGroup(card.id);
    final totalAmount = chartItems.fold(0.0, (sum, item) => sum + item.amount);

    final userProvider = Provider.of<UserProvider>(context);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final symbol = currencySymbols[currencyCode] ?? currencyCode;

    return GestureDetector(
      onDoubleTap: () {
        cardProvider.selectCardGroup(card);
        onCardSelected?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 160,
        decoration: BoxDecoration(
          color: Color(int.parse(card.colorHex.replaceFirst('#', '0x'))),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
          image:
              hasImage
                  ? DecorationImage(
                    image: FileImage(File(card.imagePath!)),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  )
                  : null,
        ),
        child: Stack(
          children: [
            // Shine effect
            Positioned(
              left: 60,
              top: 20,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 80,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$symbol${totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.id.replaceAll("-", " ").substring(0, 19),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Action icons
            Positioned(
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  const Icon(
                    Icons.wallet_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showEditSheet(context, card),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap:
                        () => _showConfirmDeleteDialog(
                          context,
                          card,
                          cardProvider,
                          walletProvider,
                        ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CardCreateSheet(),
    );
  }

  void _showEditSheet(BuildContext context, CardGroup card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardCreateSheet(existingCard: card),
    );
  }

  void _showConfirmDeleteDialog(
    BuildContext context,
    CardGroup card,
    CardGroupProvider cardProvider,
    WalletProvider walletProvider,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2D2D3F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Delete Card?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "This will delete the card and all wallets inside it. Are you sure?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () {
                  final walletsToDelete =
                      walletProvider.wallets
                          .where((w) => w.cardGroupId == card.id)
                          .toList();
                  for (var wallet in walletsToDelete) {
                    walletProvider.deleteWallet(wallet.key);
                  }

                  cardProvider.deleteCardGroup(card.id);
                  Navigator.pop(ctx);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
    );
  }
}
