import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/wallet.dart';
import '../database/transaction_item.dart';
import '../database/wallet_provider.dart';
import '../utils/toast_util.dart';
import 'wallet_fields.dart';

void showMoveMoneyBottomSheet(BuildContext context) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  final wallets = walletProvider.wallets;

  if (wallets.length < 2) {
    showToast("You need at least 2 wallets to move money.", color: Colors.red);
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
  late Wallet fromWallet;
  late Wallet toWallet;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  double enteredAmount = 0;

  @override
  void initState() {
    super.initState();
    fromWallet = widget.wallets.first;
    toWallet = widget.wallets[1];
  }

  @override
  Widget build(BuildContext context) {
    final fromBefore = fromWallet.amount;
    final toBefore = toWallet.amount;
    final fromAfter = (fromBefore - enteredAmount).clamp(0, double.infinity);
    final toAfter = toBefore + enteredAmount;

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
            const Text(
              "Move Money",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            buildDropdown(widget.wallets, fromWallet, (val) {
              setState(() {
                fromWallet = val!;
                if (fromWallet == toWallet && widget.wallets.length > 1) {
                  toWallet = widget.wallets.firstWhere((w) => w != fromWallet);
                }
              });
            }),
            const SizedBox(height: 12),

            buildDropdown(
              widget.wallets.where((w) => w != fromWallet).toList(),
              toWallet,
              (val) => setState(() => toWallet = val!),
            ),
            const SizedBox(height: 12),

            buildAmountField(amountController, (val) {
              setState(() => enteredAmount = double.tryParse(val) ?? 0);
            }),
            const SizedBox(height: 12),

            buildNoteField(noteController),
            const SizedBox(height: 12),

            // Horizontal layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "First Wallet Balance",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "\$${fromBefore.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "\$${fromAfter.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Second Wallet Balance",
                      style: TextStyle(color: Colors.white70),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "\$${toBefore.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.greenAccent),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "\$${toAfter.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.greenAccent),
                        ),
                      ],
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
                onPressed: _handleConfirm,
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

  void _handleConfirm() {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    if (fromWallet == toWallet) {
      showToast("Please choose two different wallets", color: Colors.red);
      return;
    }

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      showToast("Enter a valid amount", color: Colors.red);
      return;
    }

    if (fromWallet.amount < amount) {
      showToast(
        "Not enough balance in '${fromWallet.name}'",
        color: Colors.red,
      );
      return;
    }

    final note =
        noteController.text.trim().isEmpty
            ? "Moved \$${amount.toStringAsFixed(2)} to ${toWallet.name}"
            : noteController.text.trim();

    final txMove = TransactionItem(
      amount: amount,
      date: DateTime.now(),
      note: noteController.text.trim().isEmpty
          ? '${fromWallet.name} → ${toWallet.name}'
          : '${noteController.text.trim()} • ${fromWallet.name} → ${toWallet.name}',

      isIncome: false, // consistent type
    );

    final fromIndex = walletProvider.wallets.indexOf(fromWallet);
    final toIndex = walletProvider.wallets.indexOf(toWallet);

    final updatedFrom = fromWallet.copyWith(
      amount: fromWallet.amount - amount,
      history: [...fromWallet.history, txMove],
    );

    final updatedTo = toWallet.copyWith(
      amount: toWallet.amount + amount,
      history: [...toWallet.history],
    );

    walletProvider.updateWallet(fromIndex, updatedFrom);
    walletProvider.updateWallet(toIndex, updatedTo);

    Navigator.pop(context);
    showToast("Money moved successfully", color: const Color(0xFFF79B72));
  }
}
