/// Displays a modal bottom sheet that distributes a user-entered income
/// across wallets based on each wallet's configured income percentage.

import 'package:flutter/material.dart';
import 'package:pennywise/wallet/wallet_fields.dart';
import 'package:provider/provider.dart';

import '../database/models/wallet.dart';
import '../database/providers/card_group_provider.dart';
import '../database/providers/user_provider.dart';
import '../database/providers/wallet_provider.dart';
import '../database/models/transaction_item.dart';
import '../utils/currency_symbols.dart';
import '../widgets/date_selector.dart';
import '../utils/toast_util.dart';

void showDistributeIncomeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DistributeIncomeSheet(),
  );
}

class _DistributeIncomeSheet extends StatefulWidget {
  const _DistributeIncomeSheet();

  @override
  State<_DistributeIncomeSheet> createState() => _DistributeIncomeSheetState();
}

class _DistributeIncomeSheetState extends State<_DistributeIncomeSheet> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  double enteredAmount = 0;
  bool customDate = false;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cardGroupProvider = Provider.of<CardGroupProvider>(
      context,
      listen: false,
    );
    final currentCard = cardGroupProvider.selectedCardGroup;

    if (currentCard == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast("You must create a card group first", color: Colors.red);
        Navigator.pop(context);
      });
      return const SizedBox();
    }

    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final wallets =
        walletProvider.wallets
            .where((w) => w.cardGroupId == currentCard.id)
            .toList();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final incomeWallets =
        wallets.where((w) => (w.incomePercent ?? 0) > 0).toList();

    final totalPercent = incomeWallets.fold<double>(
      0,
      (sum, w) => sum + (w.incomePercent ?? 0),
    );

    final remainingPercent = double.parse(
      (100 - totalPercent).clamp(0, 100).toStringAsFixed(2),
    );
    final incomeRemainingExists = wallets.any(
      (w) => w.name == "Income Remaining",
    );

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D3F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Distribute Income",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Amount field
            buildAmountField(amountController, (val) {
              setState(() => enteredAmount = double.tryParse(val) ?? 0);
            }),
            const SizedBox(height: 12),

            // Optional note field
            TextField(
              controller: noteController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Optional note",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF3B3B52),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // Custom date toggle
            SwitchListTile.adaptive(
              value: customDate,
              onChanged: (val) => setState(() => customDate = val),
              title: const Text(
                "Pick custom date",
                style: TextStyle(color: Colors.white),
              ),
              contentPadding: EdgeInsets.zero,
            ),

            if (customDate)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DateSelector(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => setState(() => selectedDate = date),
                ),
              ),

            const SizedBox(height: 12),

            // Wallet breakdown
            ...incomeWallets.map((w) {
              final percent = w.incomePercent!;
              final amount = (percent / 100) * enteredAmount;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  w.name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  "$currencySymbol${amount.toStringAsFixed(2)} (${percent.toStringAsFixed(0)}%)",
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              );
            }),

            if (remainingPercent > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  "Income Remaining",
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  "$currencySymbol${((remainingPercent / 100) * enteredAmount).toStringAsFixed(2)} "
                  "(${remainingPercent.toStringAsFixed(0)}%)",
                  style: const TextStyle(color: Colors.white54),
                ),
              ),

            const SizedBox(height: 20),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (enteredAmount <= 0) {
                    showToast("Enter a valid amount", color: Colors.red);
                    return;
                  }

                  final rawNote = noteController.text.trim();

                  String getNoteForWallet(Wallet wallet) {
                    return rawNote.isEmpty ? "Income distribution" : rawNote;
                  }

                  // Distribute to income wallets
                  for (final wallet in incomeWallets) {
                    final amount =
                        (wallet.incomePercent! / 100) * enteredAmount;
                    final tx = TransactionItem(
                      amount: amount,
                      date: customDate ? selectedDate : DateTime.now(),
                      note: getNoteForWallet(wallet),
                      isIncome: true,
                      isDistribution: true,
                    );

                    final updated = wallet.copyWith(
                      amount: wallet.amount + amount,
                      history: [...wallet.history, tx],
                    );

                    if (wallet.isInBox) {
                      walletProvider.updateWalletByKey(wallet.key, updated);
                    }
                  }

                  // Handle income remaining
                  if (remainingPercent > 0) {
                    final amount = (remainingPercent / 100) * enteredAmount;
                    final tx = TransactionItem(
                      amount: amount,
                      date: DateTime.now(),
                      note: rawNote.isEmpty ? "Income distribution" : rawNote,
                      isIncome: true,
                      isDistribution: true,
                    );

                    final existing = walletProvider.wallets.firstWhere(
                      (w) =>
                          w.name == "Income Remaining" &&
                          w.cardGroupId == currentCard.id,
                      orElse:
                          () => Wallet(
                            name: "Income Remaining",
                            amount: 0,
                            isGoal: false,
                            goalAmount: null,
                            incomePercent: null,
                            description: "System wallet for unallocated income",
                            colorValue: Colors.grey.shade600.value,
                            icon: 'wallet',
                            history: [],
                            createdAt: DateTime.now(),
                            cardGroupId: currentCard.id,
                          ),
                    );

                    final updated = existing.copyWith(
                      amount: existing.amount + amount,
                      history: [...existing.history, tx],
                    );

                    final index = walletProvider.wallets.indexOf(existing);
                    if (index != -1) {
                      walletProvider.updateWallet(index, updated);
                    } else {
                      walletProvider.addWallet(updated);
                    }
                  }

                  Navigator.pop(context);
                  showToast(
                    "Income distributed successfully",
                    color: const Color(0xFFF79B72),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAD03DE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Distribute",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
