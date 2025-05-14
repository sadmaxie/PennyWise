import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:pennywise/database/wallet.dart';
import 'package:pennywise/database/transaction_item.dart';
import '../database/wallet_provider.dart';
import '../utils/toast_util.dart';
import 'emerald_icon.dart';

class AddRemoveIconButton extends StatelessWidget {
  final String type; // 'add', 'remove', or 'move'

  const AddRemoveIconButton({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (type) {
      'add' => 'assets/icons/add_money.svg',
      'remove' => 'assets/icons/remove_money.svg',
      'move' => 'assets/icons/move_money.svg',
      _ => '',
    };

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: SvgPicture.asset(assetPath, height: 35, width: 30),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (type == 'move') {
      showMoveMoneyDialog(context);
    } else {
      showMoneyEditDialog(context: context, type: type);
    }
  }
}

void showMoneyEditDialog({
  required BuildContext context,
  required String type,
}) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  final wallets = walletProvider.wallets;
  Wallet? selected = wallets.isNotEmpty ? wallets.first : null;
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  double enteredAmount = 0;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MoneyEditPopup',
    pageBuilder: (_, __, ___) => _DialogWrapper(
      title: type == 'add' ? 'Add Money' : 'Remove Money',
      contentBuilder: (context, setState, close) {
        return StatefulBuilder(
          builder: (context, innerSetState) {
            final current = selected?.amount ?? 0;
            final updated = type == 'add'
                ? current + enteredAmount
                : (current - enteredAmount).clamp(0, double.infinity);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown(wallets, selected, (val) {
                  innerSetState(() => selected = val);
                }),
                const SizedBox(height: 12),
                _buildAmountField(amountController, (val) {
                  innerSetState(() => enteredAmount = double.tryParse(val) ?? 0);
                }),
                const SizedBox(height: 12),
                _buildNoteField(noteController),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Before: \$${current.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("After: \$${updated.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.greenAccent)),
                  ],
                ),
              ],
            );
          },
        );
      },
        onConfirm: () {
          if (selected == null || amountController.text.isEmpty) {
            showToast("Please select a wallet and enter an amount", color: Colors.red);
            return;
          }

          final enteredAmount = double.tryParse(amountController.text) ?? 0;
          final currentBalance = selected!.amount; // Safe after null check

          if (enteredAmount <= 0) {
            showToast("Enter a valid amount", color: Colors.red);
            return;
          }

          if (type == 'remove' && currentBalance < enteredAmount) {
            showToast("Not enough balance", color: Colors.red);
            return;
          }

          final double updatedAmount = type == 'add'
              ? currentBalance + enteredAmount
              : (currentBalance - enteredAmount).clamp(0, double.infinity);

          final note = noteController.text.trim().isEmpty
              ? '${type == 'add' ? 'Added' : 'Removed'} money'
              : noteController.text.trim();

          final tx = TransactionItem(
            amount: enteredAmount,
            date: DateTime.now(),
            note: note,
            isIncome: type == 'add',
          );

          final index = walletProvider.wallets.indexOf(selected!); // Add ! here

          final updated = Wallet(
            name: selected!.name,
            amount: updatedAmount,
            isGoal: selected!.isGoal,
            goalAmount: (selected!.goalAmount ?? 0).toDouble(),
            incomePercent: (selected!.incomePercent ?? 0).toDouble(),
            description: selected!.description,
            icon: selected!.icon,
            colorValue: selected!.colorValue,
            history: [...selected!.history, tx],
            createdAt: selected!.createdAt,
          );


          walletProvider.updateWallet(index, updated);

          showToast("Money ${type == 'add' ? 'added' : 'removed'} successfully",
              color: const Color(0xFFF79B72));
        }

    ),
  );
}

void showMoveMoneyDialog(BuildContext context) {
  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
  final wallets = walletProvider.wallets;

  if (wallets.length < 2) {
    showToast("You need at least 2 wallets to move money.", color: Colors.red);
    return;
  }

  Wallet? fromWallet = wallets.first;
  Wallet? toWallet = wallets[1];
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  double enteredAmount = 0;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MoveMoneyDialog',
    pageBuilder: (_, __, ___) => _DialogWrapper(
      title: 'Move Money',
      contentBuilder: (context, setState, close) {
        return StatefulBuilder(
          builder: (context, innerSetState) {
            final fromBefore = fromWallet?.amount ?? 0;
            final toBefore = toWallet?.amount ?? 0;
            final fromAfter = (fromBefore - enteredAmount).clamp(0, double.infinity);
            final toAfter = toBefore + enteredAmount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown(wallets, fromWallet, (val) {
                  innerSetState(() {
                    fromWallet = val;
                    if (fromWallet == toWallet && wallets.length > 1) {
                      toWallet = wallets.firstWhere((w) => w != fromWallet);
                    }
                  });
                }),
                const SizedBox(height: 12),
                _buildDropdown(
                  wallets.where((w) => w != fromWallet).toList(),
                  toWallet,
                      (val) => innerSetState(() => toWallet = val),
                ),
                const SizedBox(height: 12),
                _buildAmountField(amountController, (val) {
                  innerSetState(() => enteredAmount = double.tryParse(val) ?? 0);
                }),
                const SizedBox(height: 12),
                _buildNoteField(noteController),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("From: \$${fromBefore.toStringAsFixed(2)} → \$${fromAfter.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 6),
                    Text("To:     \$${toBefore.toStringAsFixed(2)} → \$${toAfter.toStringAsFixed(2)}",
                        style: const TextStyle(color: Colors.greenAccent)),
                  ],
                ),
              ],
            );
          },
        );
      },
      onConfirm: () {
        if (fromWallet == null || toWallet == null || fromWallet == toWallet) {
          showToast("Please choose two different wallets", color: Colors.red);
          return;
        }

        final enteredAmount = double.tryParse(amountController.text) ?? 0;
        if (enteredAmount <= 0) {
          showToast("Enter a valid amount", color: Colors.red);
          return;
        }

        if (fromWallet!.amount < enteredAmount) {
          showToast("Not enough balance in '${fromWallet!.name}'", color: Colors.red);
          return;
        }

        final note = noteController.text.trim().isEmpty
            ? "Moved \$${enteredAmount.toStringAsFixed(2)} to ${toWallet!.name}"
            : noteController.text.trim();

        // Create transaction items
        final txFrom = TransactionItem(
          amount: enteredAmount,
          date: DateTime.now(),
          note: note,
          isIncome: false,
        );

        final txTo = TransactionItem(
          amount: enteredAmount,
          date: DateTime.now(),
          note: note,
          isIncome: true,
        );

        // Update fromWallet
        final fromIndex = walletProvider.wallets.indexOf(fromWallet!);
        final updatedFrom = Wallet(
          name: fromWallet!.name,
          amount: fromWallet!.amount - enteredAmount,
          isGoal: fromWallet!.isGoal,
          goalAmount: (fromWallet!.goalAmount ?? 0).toDouble(),
          incomePercent: (fromWallet!.incomePercent ?? 0).toDouble(),
          description: fromWallet!.description,
          icon: fromWallet!.icon,
          colorValue: fromWallet!.colorValue,
          history: [...fromWallet!.history, txFrom],
        );

        // Update toWallet
        final toIndex = walletProvider.wallets.indexOf(toWallet!);
        final updatedTo = Wallet(
          name: toWallet!.name,
          amount: toWallet!.amount + enteredAmount,
          isGoal: toWallet!.isGoal,
          goalAmount: (toWallet!.goalAmount ?? 0).toDouble(),
          incomePercent: (toWallet!.incomePercent ?? 0).toDouble(),
          description: toWallet!.description,
          icon: toWallet!.icon,
          colorValue: toWallet!.colorValue,
          history: [...toWallet!.history, txTo],
          createdAt: fromWallet!.createdAt,
        );

        // Save changes
        walletProvider.updateWallet(fromIndex, updatedFrom);
        walletProvider.updateWallet(toIndex, updatedTo);

        showToast("Money moved successfully", color: const Color(0xFFF79B72));
      },
    ),
  );
}


// Shared dialog wrapper
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                maxWidth: constraints.maxWidth,
              ),
              child: AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                backgroundColor: const Color(0xFF2D2D3F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                title: Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
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
            );
          },
        ),
      ),
    );
  }
}

// Custom dropdown using Wallets
Widget _buildDropdown(List<Wallet> items, Wallet? selectedItem, Function(Wallet?) onChanged) {
  return DropdownButton<Wallet>(
    value: selectedItem ?? items.first, // Remove the ! operator here
    dropdownColor: const Color(0xFF3B3B52),
    isExpanded: true,
    iconEnabledColor: Colors.white,
    underline: const SizedBox(),
    items: items.map((item) {
      return DropdownMenuItem(
        value: item,
        child: Row(
          children: [
            GlowingIcon(color: item.color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white))),
            Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
          ],
        ),
      );
    }).toList(),
    onChanged: onChanged,
  );
}

Widget _buildAmountField(TextEditingController controller, Function(String) onChanged) {
  return Column(
    children: [
      SizedBox(width: 600),
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: _fieldDecoration("Enter amount"),
      ),
    ],
  );
}

Widget _buildNoteField(TextEditingController controller) {
  return TextField(
    controller: controller,
    minLines: 1,
    maxLines: 4,
    style: const TextStyle(color: Colors.white),
    decoration: _fieldDecoration("Note (optional)"),
  );
}

InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF3B3B52),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );
}
