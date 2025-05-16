import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/card_group.dart';
import '../../database/providers/card_group_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../wallet/card_form_sheet.dart';
import '../../widgets/wallet_card.dart';

class MyCardView extends StatelessWidget {
  const MyCardView({super.key});

  @override
  Widget build(BuildContext context) {
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    final currentCard = cardGroupProvider.selectedCardGroup;

    // No cards yet — force creation
    if (currentCard == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CardFormSheet(),
            );
          },
          child: const Text('Create Your First Card'),
        ),
      );
    }

    // Filter wallets assigned to this card
    final allWallets = walletProvider.wallets;
    final walletsForCurrentCard = allWallets.where((wallet) {
      return wallet.cardGroupId == currentCard.id;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card switcher dropdown
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButton<CardGroup>(
            isExpanded: true,
            value: currentCard,
            items: cardGroupProvider.cardGroups.map((card) {
              return DropdownMenuItem(
                value: card,
                child: Text(card.name),
              );
            }).toList(),
            onChanged: (newCard) {
              if (newCard != null) {
                cardGroupProvider.selectCardGroup(newCard);
              }
            },
          ),
        ),

        // Wallets list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: walletsForCurrentCard.length,
            itemBuilder: (context, index) {
              final wallet = walletsForCurrentCard[index];
              return WalletCard(wallet: wallet); // uses your existing widget
            },
          ),
        ),

        // Create New Card Button
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const CardFormSheet(),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}
