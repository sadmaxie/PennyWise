import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../database/wallet.dart';
import '../database/wallet_provider.dart';
import '../database/transaction_item.dart';
import '../utils/toast_util.dart';
import 'wallet_fields.dart';

void showMoneyEditBottomSheet({
  required BuildContext context,
  required String type,
}) {
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

  @override
  void initState() {
    super.initState();
    final wallets = Provider.of<WalletProvider>(context, listen: false).wallets;
    if (wallets.isNotEmpty) selected = wallets.first;
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final wallets = walletProvider.wallets;

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
                      "\$${current.toStringAsFixed(2)}",
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
                      "\$${updated.toStringAsFixed(2)}",
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
                onPressed: () => _handleConfirm(walletProvider),
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
      date: DateTime.now(),
      note: noteController.text.trim().isEmpty
          ? wallet.name
          : '${noteController.text.trim()} • ${wallet.name}',


      isIncome: widget.type == 'add',
    );

    final index = provider.wallets.indexOf(wallet);
    final updated = wallet.copyWith(
      amount: newAmount.toDouble(),
      history: [...wallet.history, tx],
    );

    provider.updateWallet(index, updated);
    Navigator.pop(context);
    showToast(
      "Money ${widget.type == 'add' ? 'added' : 'removed'} successfully",
      color: const Color(0xFFF79B72),
    );
  }
}
