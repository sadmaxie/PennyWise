import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/models/wallet.dart';
import '../database/models/transaction_item.dart';
import '../database/providers/wallet_provider.dart';
import '../widgets/date_selector.dart';
import '../utils/toast_util.dart';
import 'wallet_fields.dart';

/// Opens a modal bottom sheet to move money from one wallet to another.
/// Requires at least two wallets to proceed.
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
  bool customDate = false;
  DateTime selectedDate = DateTime.now();

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
    final double fromAfter = (fromBefore - enteredAmount).clamp(0, double.infinity).toDouble();
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
            // Drag handle
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

            // From Wallet
            buildDropdown(widget.wallets, fromWallet, (val) {
              setState(() {
                fromWallet = val!;
                if (fromWallet == toWallet && widget.wallets.length > 1) {
                  toWallet = widget.wallets.firstWhere((w) => w != fromWallet);
                }
              });
            }),
            const SizedBox(height: 12),

            // To Wallet
            buildDropdown(
              widget.wallets.where((w) => w != fromWallet).toList(),
              toWallet,
                  (val) => setState(() => toWallet = val!),
            ),
            const SizedBox(height: 12),

            // Amount
            buildAmountField(amountController, (val) {
              setState(() => enteredAmount = double.tryParse(val) ?? 0);
            }),
            const SizedBox(height: 12),

            // Note
            buildNoteField(noteController),
            const SizedBox(height: 12),

            // Custom Date
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
                padding: const EdgeInsets.only(bottom: 12),
                child: DateSelector(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => setState(() => selectedDate = date),
                ),
              ),

            const SizedBox(height: 5),

            // Preview of balance changes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWalletChange(
                  label: "First Wallet Balance",
                  before: fromBefore,
                  after: fromAfter,
                  color: Colors.redAccent,
                ),
                _buildWalletChange(
                  label: "Second Wallet Balance",
                  before: toBefore,
                  after: toAfter,
                  color: Colors.greenAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Confirm button
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

  Widget _buildWalletChange({
    required String label,
    required double before,
    required double after,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Row(
          children: [
            Text("\$${before.toStringAsFixed(2)}", style: TextStyle(color: color)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_right_alt, color: color, size: 18),
            const SizedBox(width: 4),
            Text("\$${after.toStringAsFixed(2)}", style: TextStyle(color: color)),
          ],
        ),
      ],
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
      showToast("Not enough balance in '${fromWallet.name}'", color: Colors.red);
      return;
    }

    final note = noteController.text.trim().isEmpty
        ? "Moved \$${amount.toStringAsFixed(2)} to ${toWallet.name}"
        : noteController.text.trim();

    final txMove = TransactionItem(
      amount: amount,
      date: customDate ? selectedDate : DateTime.now(),
      note: note,
      isIncome: false,
      fromWallet: fromWallet.name,
      toWallet: toWallet.name,
    );

    final fromIndex = walletProvider.wallets.indexOf(fromWallet);
    final toIndex = walletProvider.wallets.indexOf(toWallet);

    final updatedFrom = fromWallet.copyWith(
      amount: fromWallet.amount - amount,
      history: [...fromWallet.history, txMove],
    );

    final updatedTo = toWallet.copyWith(
      amount: toWallet.amount + amount,
    );

    walletProvider.updateWallet(fromIndex, updatedFrom);
    walletProvider.updateWallet(toIndex, updatedTo);

    Navigator.pop(context);
    showToast("Money moved successfully", color: const Color(0xFFF79B72));
  }
}
