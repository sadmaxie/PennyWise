import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/database/wallet.dart';
import '../../components/app_bar.dart';
import '../../components/wallet_provider.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallets = walletProvider.wallets;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const TopHeader(showBackButton: false, showUserIcon: false),
          Expanded(
            child: wallets.isEmpty
                ? const Center(child: Text("No wallets yet.", style: TextStyle(color: Colors.white)))
                : ListView.builder(
              itemCount: wallets.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                final percent = walletProvider.getWalletShare(wallet).toStringAsFixed(1);

                return GestureDetector(
                  onTap: () => showWalletPopup(context, wallet, index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: wallet.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: wallet.color.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: wallet.color,
                          child: const Icon(Icons.wallet, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(wallet.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('\$${wallet.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B3B52),
        onPressed: () => showWalletPopup(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void showWalletPopup(BuildContext context, [Wallet? wallet, int? index]) {
  final nameController = TextEditingController(text: wallet?.name ?? '');
  final amountController = TextEditingController(text: wallet?.amount.toString() ?? '');
  final goalAmountController = TextEditingController(text: wallet?.goalAmount?.toString() ?? '');
  final descriptionController = TextEditingController(text: wallet?.description ?? '');
  final incomePercentController = TextEditingController(text: wallet?.incomePercent?.toString() ?? '');

  bool isGoal = wallet?.isGoal ?? false;
  bool hasIncome = wallet?.incomePercent != null;
  Color selectedColor = wallet?.color ?? Colors.blue;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'WalletPopup',
    pageBuilder: (_, __, ___) => _DialogWrapper(
      title: wallet == null ? 'Add Wallet' : 'Edit Wallet',
      contentBuilder: (context, setState, close) {
        return StatefulBuilder(builder: (context, innerSetState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _styledField(nameController, "Wallet Name"),
              const SizedBox(height: 12),
              _styledField(amountController, "Amount (\$)", isNumber: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Color:", style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF2D2D3F),
                          title: const Text("Pick a color", style: TextStyle(color: Colors.white)),
                          content: Wrap(
                            children: Colors.primaries.map((c) {
                              return GestureDetector(
                                onTap: () => Navigator.pop(context, c),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                      if (picked != null) innerSetState(() => selectedColor = picked);
                    },
                    child: CircleAvatar(backgroundColor: selectedColor, radius: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: isGoal,
                onChanged: (val) => innerSetState(() => isGoal = val),
                title: const Text("Is Goal?", style: TextStyle(color: Colors.white)),
              ),
              if (isGoal) _styledField(goalAmountController, "Goal Amount", isNumber: true),
              SwitchListTile(
                value: hasIncome,
                onChanged: (val) => innerSetState(() => hasIncome = val),
                title: const Text("Take Income %", style: TextStyle(color: Colors.white)),
              ),
              if (hasIncome) _styledField(incomePercentController, "Income %", isNumber: true),
              _styledField(descriptionController, "Description"),
            ],
          );
        });
      },
      onConfirm: () {
        final name = nameController.text.trim();
        final amount = double.tryParse(amountController.text) ?? 0;
        final goal = isGoal ? double.tryParse(goalAmountController.text) : null;
        final income = hasIncome ? double.tryParse(incomePercentController.text) : null;
        final desc = descriptionController.text.trim();

        final newWallet = Wallet(
          name: name,
          amount: amount,
          isGoal: isGoal,
          goalAmount: goal,
          incomePercent: income,
          description: desc,
          colorValue: selectedColor.value,
          icon: wallet?.icon,
          history: wallet?.history ?? [],
        );

        final provider = Provider.of<WalletProvider>(context, listen: false);
        if (wallet == null) {
          provider.addWallet(newWallet);
        } else if (index != null) {
          provider.updateWallet(index, newWallet);
        }
      },
    ),
  );
}

// Same decoration as your add/remove system
Widget _styledField(TextEditingController controller, String hint, {bool isNumber = false}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    inputFormatters: isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))] : [],
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF3B3B52),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

// _DialogWrapper matches your frosted style
class _DialogWrapper extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext, void Function(void Function()), VoidCallback) contentBuilder;
  final VoidCallback onConfirm;

  const _DialogWrapper({
    required this.title,
    required this.contentBuilder,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFF2D2D3F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return contentBuilder(context, setState, () => Navigator.pop(context));
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
