// Refactored version of the money dialogs
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../temp_data.dart';
import 'emerald_icon.dart';
import 'dart:ui';

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
      child: Container(
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
      showMoneyEditDialog(
        context: context,
        type: type,
        onConfirm: () {},
      );
    }
  }
}

void showMoneyEditDialog({
  required BuildContext context,
  required String type,
  required VoidCallback onConfirm,
}) {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MoneyEditPopup',
    pageBuilder: (_, __, ___) => _DialogWrapper(
      title: type == 'add' ? 'Add Money' : 'Remove Money',
      contentBuilder: (context, setState, close) {
        final items = getTempProgressItems();
        ProgressItem? selectedItem = items.isNotEmpty ? items.first : null;
        double enteredAmount = 0;

        return StatefulBuilder(
          builder: (context, innerSetState) {
            final current = selectedItem?.amount ?? 0;
            final updated = type == 'add'
                ? current + enteredAmount
                : (current - enteredAmount).clamp(0, double.infinity);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown(items, selectedItem, (item) {
                  innerSetState(() => selectedItem = item);
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
        final items = getTempProgressItems();
        final selectedItem = items.isNotEmpty ? items.first : null;
        final enteredAmount = double.tryParse(amountController.text) ?? 0;

        if (selectedItem != null && enteredAmount > 0) {
          final item = selectedItem;
          if (type == 'add') {
            item.amount += enteredAmount;
          } else {
            item.amount = (item.amount - enteredAmount).clamp(0, double.infinity);
          }

          final note = noteController.text.trim().isEmpty
              ? '${type == 'add' ? 'Added' : 'Removed'} to ${item.name}'
              : noteController.text.trim();

          addTransaction(Transaction(
            type: note,
            amount: enteredAmount,
            date: DateTime.now().toString().split(' ')[0],
            isIncome: type == 'add',
          ));

          onConfirm();
        }
      },
    ),
  );
}

void showMoveMoneyDialog(BuildContext context) {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'MovePopup',
    pageBuilder: (_, __, ___) => _DialogWrapper(
      title: 'Move Money',
      contentBuilder: (context, setState, close) {
        final items = getTempProgressItems();
        ProgressItem? fromItem = items.isNotEmpty ? items.first : null;
        ProgressItem? toItem = items.length > 1 ? items[1] : null;
        double enteredAmount = 0;

        return StatefulBuilder(
          builder: (context, innerSetState) {
            final fromBefore = fromItem?.amount ?? 0;
            final toBefore = toItem?.amount ?? 0;
            final fromAfter = (fromBefore - enteredAmount).clamp(0, double.infinity);
            final toAfter = toBefore + enteredAmount;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdown(items, fromItem, (val) => innerSetState(() => fromItem = val)),
                const SizedBox(height: 10),
                _buildDropdown(
                  items.where((e) => e != fromItem).toList(),
                  toItem,
                      (val) => innerSetState(() => toItem = val),
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
                    Text(
                      "From: \$${fromBefore.toStringAsFixed(2)} → \$${fromAfter.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "To:     \$${toBefore.toStringAsFixed(2)} → \$${toAfter.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      onConfirm: () {
        final from = getTempProgressItems().first;
        final to = getTempProgressItems().length > 1 ? getTempProgressItems()[1] : null;
        final enteredAmount = double.tryParse(amountController.text) ?? 0;

        if (from != null && to != null && enteredAmount > 0) {
          from.amount = (from.amount - enteredAmount).clamp(0, double.infinity);
          to.amount += enteredAmount;

          final note = noteController.text.trim().isNotEmpty
              ? noteController.text.trim()
              : 'Moved \$${enteredAmount.toStringAsFixed(2)} from ${from.name} to ${to.name}';

          addTransaction(Transaction(
            type: note,
            amount: enteredAmount,
            date: DateTime.now().toString().split(' ')[0],
            isIncome: true,
          ));
        }
      },
    ),
  );
}

// Shared reusable dialog wrapper
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
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
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



Widget _buildDropdown(List<ProgressItem> items, ProgressItem? selectedItem, Function(ProgressItem?) onChanged) {
  return DropdownButton<ProgressItem>(
    value: selectedItem,
    dropdownColor: const Color(0xFF3B3B52),
    isExpanded: true,
    iconEnabledColor: Colors.white,
    underline: const SizedBox(),
    items: items.map((item) => DropdownMenuItem(
      value: item,
      child: Row(
        children: [
          GlowingIcon(color: item.color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white))),
          Text('\$${item.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
        ],
      ),
    )).toList(),
    onChanged: onChanged,
  );
}

Widget _buildAmountField(TextEditingController controller, Function(String) onChanged) {
  return Column(
    children: [
      // temp force
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
    maxLines: 4, // expands up to 4 lines
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