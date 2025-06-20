/// Displays a modal bottom sheet for adding or removing money from a wallet.
/// Requires at least one wallet to be present.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../database/models/wallet.dart';
import '../database/providers/card_group_provider.dart';
import '../database/providers/user_provider.dart';
import '../database/providers/wallet_provider.dart';
import '../database/models/transaction_item.dart';
import '../utils/currency_symbols.dart';
import '../widgets/date_selector.dart';
import '../utils/toast_util.dart';
import 'wallet_fields.dart';

void showMoneyEditBottomSheet({
  required BuildContext context,
  required String type,
}) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  if (walletProvider.wallets.isEmpty) {
    showToast("Please select a card group first.", color: Colors.red);
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MoneyEditSheet(type: type),
  );
}

class _MoneyEditSheet extends StatefulWidget {
  final String type;

  const _MoneyEditSheet({required this.type});

  @override
  State<_MoneyEditSheet> createState() => _MoneyEditSheetState();
}

class _MoneyEditSheetState extends State<_MoneyEditSheet> {
  Wallet? selected;
  double enteredAmount = 0;
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  bool customDate = false;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
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
      return const SizedBox.shrink();
    }

    final wallets =
        walletProvider.wallets
            .where((w) => w.cardGroupId == currentCard.id)
            .toList();

    if (wallets.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToast("No wallets in this card group", color: Colors.red);
        Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final current = selected?.amount ?? 0;
    final updated =
        widget.type == 'add'
            ? current + enteredAmount
            : (current - enteredAmount).clamp(0, double.infinity);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D3F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.type == 'add' ? 'Add Money' : 'Remove Money',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            buildDropdown(
              context,
              wallets,
              selected,
              (val) => setState(() => selected = val),
            ),
            const SizedBox(height: 12),
            buildAmountField(amountController, (val) {
              setState(() => enteredAmount = double.tryParse(val) ?? 0);
            }),
            const SizedBox(height: 12),
            buildNoteField(noteController),
            const SizedBox(height: 12),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: DateSelector(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => setState(() => selectedDate = date),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Before",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "$currencySymbol${current.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "After",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      "$currencySymbol${updated.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAD03DE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed:
                    (selected != null && enteredAmount > 0)
                        ? () => _handleConfirm(walletProvider)
                        : null,
                child: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirm(WalletProvider provider) {
    if (selected == null || amountController.text.isEmpty) {
      showToast(
        "Please select a wallet and enter an amount",
        color: Colors.red,
      );
      return;
    }

    final wallet = selected!;
    final enteredAmount = double.tryParse(amountController.text) ?? 0;

    if (enteredAmount <= 0) {
      showToast("Enter a valid amount", color: Colors.red);
      return;
    }

    if (widget.type == 'remove' && wallet.amount < enteredAmount) {
      showToast("Not enough balance", color: Colors.red);
      return;
    }

    final newAmount =
        widget.type == 'add'
            ? wallet.amount + enteredAmount
            : wallet.amount - enteredAmount;

    final tx = TransactionItem(
      amount: enteredAmount,
      date: customDate ? selectedDate : DateTime.now(),
      note:
          noteController.text.trim().isNotEmpty
              ? noteController.text.trim()
              : wallet.name,
      isIncome: widget.type == 'add',
    );

    if (wallet.isInBox) {
      final updated = wallet.copyWith(
        amount: newAmount,
        history: [...wallet.history, tx],
      );
      provider.updateWalletByKey(wallet.key, updated);
      provider.recordLastTransaction(tx: tx);

    }

    Navigator.pop(context);
    showToast(
      "Money ${widget.type == 'add' ? 'added' : 'removed'} successfully",
      color: const Color(0xFFF79B72),
    );
  }
}
