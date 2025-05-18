/// Opens a modal bottom sheet to move money from one wallet to another.
/// Requires at least two wallets to proceed.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/wallet.dart';
import '../database/models/transaction_item.dart';
import '../database/providers/card_group_provider.dart';
import '../database/providers/user_provider.dart';
import '../database/providers/wallet_provider.dart';
import '../utils/currency_symbols.dart';
import '../widgets/date_selector.dart';
import '../utils/toast_util.dart';
import 'wallet_fields.dart';

void showMoveMoneyBottomSheet(BuildContext context) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  final cardGroupProvider = Provider.of<CardGroupProvider>(context, listen: false);
  final currentCard = cardGroupProvider.selectedCardGroup;

  if (currentCard == null) {
    showToast("Please select a card group first", color: Colors.red);
    return;
  }

  final wallets = walletProvider.wallets.where((w) => w.cardGroupId == currentCard.id).toList();

  if (wallets.length < 2) {
    showToast("You need at least 2 wallets in this card group.", color: Colors.red);
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MoveMoneySheet(wallets: wallets),
  );
}

class _MoveMoneySheet extends StatefulWidget {
  final List<Wallet> wallets;
  const _MoveMoneySheet({required this.wallets});

  @override
  State<_MoveMoneySheet> createState() => _MoveMoneySheetState();
}

class _MoveMoneySheetState extends State<_MoveMoneySheet> {
  Wallet? fromWallet;
  Wallet? toWallet;
  late String currencySymbol;

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  double enteredAmount = 0;
  bool customDate = false;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final fromBefore = fromWallet?.amount ?? 0;
    final toBefore = toWallet?.amount ?? 0;
    final fromAfter = (fromBefore - enteredAmount).clamp(0, double.infinity).toDouble();
    final toAfter = toBefore + enteredAmount;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

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
            const Text("Move Money", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // From Wallet
            buildDropdown(context, widget.wallets, fromWallet, (val) {
              setState(() {
                fromWallet = val;
                if (fromWallet == toWallet) toWallet = null;
              });
            }),
            const SizedBox(height: 12),

            // To Wallet
            buildDropdown(
              context,
              widget.wallets.where((w) => w != fromWallet).toList(),
              toWallet,
                  (val) => setState(() => toWallet = val),
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
              title: const Text("Pick custom date", style: TextStyle(color: Colors.white)),
              contentPadding: EdgeInsets.zero,
            ),

            if (customDate)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DateSelector(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => setState(() => selectedDate = date),
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWalletChange("From Wallet", fromBefore, fromAfter, Colors.redAccent),
                _buildWalletChange("To Wallet", toBefore, toAfter, Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (fromWallet != null && toWallet != null && enteredAmount > 0) ? _handleConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAD03DE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Confirm", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletChange(String label, double before, double after, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Row(
          children: [
            Text("$currencySymbol${before.toStringAsFixed(2)}", style: TextStyle(color: color)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_right_alt, color: color, size: 18),
            const SizedBox(width: 4),
            Text("$currencySymbol${after.toStringAsFixed(2)}", style: TextStyle(color: color)),
          ],
        ),
      ],
    );
  }

  void _handleConfirm() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (fromWallet == null || toWallet == null) {
      showToast("Please select two different wallets", color: Colors.red);
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0 || fromWallet!.amount < amount) {
      showToast("Invalid or insufficient amount", color: Colors.red);
      return;
    }

    final note = noteController.text.trim().isEmpty
        ? "Moved $currencySymbol${amount.toStringAsFixed(2)} to ${toWallet!.name}"
        : noteController.text.trim();

    final tx = TransactionItem(
      amount: amount,
      date: customDate ? selectedDate : DateTime.now(),
      note: note,
      isIncome: false,
      fromWallet: fromWallet!.name,
      toWallet: toWallet!.name,
    );

    // Update source wallet (subtract amount, add tx)
    final updatedFrom = fromWallet!.copyWith(
      amount: fromWallet!.amount - amount,
      history: [...fromWallet!.history, tx],
    );

    // Update destination wallet (add amount, optional tx record)
    final updatedTo = toWallet!.copyWith(
      amount: toWallet!.amount + amount,
      // optionally record tx in destination if you want dual history
      history: [...toWallet!.history],
      // or [...toWallet!.history, tx] if desired
    );

    // Persist updates
    walletProvider.updateWalletByKey(fromWallet!.key, updatedFrom);
    walletProvider.updateWalletByKey(toWallet!.key, updatedTo);

    // Record for undo support
    walletProvider.recordLastTransaction(
      tx: tx,
      fromWallet: updatedFrom,
      toWallet: updatedTo,
    );

    Navigator.pop(context);
    showToast("Money moved successfully", color: const Color(0xFFF79B72));
  }

}
