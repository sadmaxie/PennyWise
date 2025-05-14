import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/wallet.dart';
import '../database/wallet_provider.dart';
import '../database/transaction_item.dart';
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
  double enteredAmount = 0;

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final wallets = walletProvider.wallets;

    final incomeWallets = wallets
        .where((w) => (w.incomePercent ?? 0) > 0)
        .toList();

    final totalPercent = incomeWallets.fold<double>(
      0,
          (sum, w) => sum + (w.incomePercent ?? 0),
    );

    final remainingPercent = (100 - totalPercent).clamp(0, 100);
    final incomeRemainExists = wallets.any((w) => w.name == "Income Remain");

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
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter income amount",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF3B3B52),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() {
                enteredAmount = double.tryParse(val) ?? 0;
              }),
            ),
            const SizedBox(height: 20),

            // Wallet Breakdown
            ...incomeWallets.map((w) {
              final percent = w.incomePercent!;
              final amount = (percent / 100) * enteredAmount;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(w.name, style: const TextStyle(color: Colors.white)),
                trailing: Text(
                  "\$${amount.toStringAsFixed(2)} (${percent.toStringAsFixed(0)}%)",
                  style: const TextStyle(color: Colors.greenAccent),
                ),
              );
            }),

            // Income Remain row
            if (remainingPercent > 0)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Income Remain", style: TextStyle(color: Colors.white70)),
                trailing: Text(
                  "\$${((remainingPercent / 100) * enteredAmount).toStringAsFixed(2)} (${remainingPercent.toStringAsFixed(0)}%)",
                  style: const TextStyle(color: Colors.white54),
                ),
              ),

            const SizedBox(height: 20),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (enteredAmount <= 0) {
                    showToast("Enter a valid amount", color: Colors.red);
                    return;
                  }

                  // Update existing wallets
                  for (final wallet in incomeWallets) {
                    final amount = (wallet.incomePercent! / 100) * enteredAmount;
                    final tx = TransactionItem(
                      amount: amount,
                      date: DateTime.now(),
                      note: "Income distribution",
                      isIncome: true,
                    );
                    final index = walletProvider.wallets.indexOf(wallet);
                    final updated = wallet.copyWith(
                      amount: wallet.amount + amount,
                      history: [...wallet.history, tx],
                    );
                    walletProvider.updateWallet(index, updated);
                  }

                  // Handle Income Remain wallet
                  if (remainingPercent > 0) {
                    final amount = (remainingPercent / 100) * enteredAmount;
                    final tx = TransactionItem(
                      amount: amount,
                      date: DateTime.now(),
                      note: "Remaining income",
                      isIncome: true,
                    );

                    final existing = walletProvider.wallets.firstWhere(
                          (w) => w.name == "Income Remain",
                      orElse: () => Wallet(
                        name: "Income Remain",
                        amount: 0,
                        isGoal: false,
                        colorValue: Colors.white.value,
                        history: [],
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
                  showToast("Income distributed successfully", color: const Color(0xFFF79B72));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF79B72),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Distribute", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
