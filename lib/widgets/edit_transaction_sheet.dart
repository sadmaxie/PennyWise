import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../database/models/transaction_item.dart';
import '../database/models/wallet.dart';
import '../database/providers/wallet_provider.dart';
import '../utils/toast_util.dart';

class EditTransactionSheet extends StatefulWidget {
  final TransactionItem transaction;
  final Wallet wallet;

  const EditTransactionSheet({
    super.key,
    required this.transaction,
    required this.wallet,
  });

  @override
  State<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionSheet> {
  late TextEditingController amountController;
  late TextEditingController noteController;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    noteController = TextEditingController(text: widget.transaction.note);
    selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
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
            _styledField(amountController, "Amount", isNumber: true),
            const SizedBox(height: 12),
            _styledField(noteController, "Note"),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: const Color(0xFF3B3B52),
              onTap: _pickDate,
              title: Text(
                "Date: ${DateFormat.yMMMd().format(selectedDate)}",
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.white54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _handleSave,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Widget _styledField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType:
          isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF3B3B52),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _handleSave() async {
    final amountText = amountController.text.trim();
    final note = noteController.text.trim();
    final newAmount = double.tryParse(amountText);

    if (newAmount == null || newAmount <= 0) {
      showToast("Enter a valid amount", color: Colors.red);
      return;
    }

    if (note.isEmpty) {
      showToast("Note cannot be empty", color: Colors.red);
      return;
    }

    final tx = widget.transaction;
    final wallet = widget.wallet;

    final oldAmount = tx.amount;
    final isIncome = tx.isIncome;

    // Replace transaction
    final updatedTransaction = TransactionItem(
      amount: newAmount,
      date: selectedDate,
      note: note,
      isIncome: tx.isIncome,
      fromWallet: tx.fromWallet,
      toWallet: tx.toWallet,
      isDistribution: tx.isDistribution,
    );

    // Update wallet history and balance
    final updatedHistory = [...wallet.history];
    final index = updatedHistory.indexOf(tx);
    if (index == -1) {
      showToast("Transaction not found", color: Colors.red);
      return;
    }

    updatedHistory[index] = updatedTransaction;

    final balanceAdjustment =
        isIncome
            ? newAmount - oldAmount
            : oldAmount - newAmount; // reverse for expense

    final updatedWallet = wallet.copyWith(
      amount: wallet.amount + balanceAdjustment,
      history: updatedHistory,
    );

    // Save with provider
    final provider = Provider.of<WalletProvider>(context, listen: false);
    await provider.updateWalletByKey(wallet.key, updatedWallet);

    showToast("Transaction updated", color: Colors.green);
    Navigator.pop(context);
  }
}

void showEditTransactionSheet(
  BuildContext context,
  TransactionItem transaction,
  Wallet wallet,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (_) => EditTransactionSheet(transaction: transaction, wallet: wallet),
  );
}
