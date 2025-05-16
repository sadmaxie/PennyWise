// wallet_fields.dart
// Contains reusable UI widgets for wallet-related forms: dropdown, amount field, and note field.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pennywise/database/models/wallet.dart';

import '../widgets/glowing_icon.dart';

/// Builds a dropdown menu for selecting a wallet.
Widget buildDropdown(
    List<Wallet> items,
    Wallet? selectedItem,
    Function(Wallet?) onChanged,
    ) {
  return DropdownButton<Wallet>(
    value: selectedItem ?? items.first,
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
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            Text(
              '\$${item.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }).toList(),
    onChanged: onChanged,
  );
}

/// Builds a styled input field for entering a monetary amount.
Widget buildAmountField(
    TextEditingController controller,
    Function(String) onChanged,
    ) {
  return TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    onChanged: onChanged,
    style: const TextStyle(color: Colors.white),
    decoration: _fieldDecoration("Enter amount"),
  );
}

/// Builds a styled input field for an optional note.
Widget buildNoteField(TextEditingController controller) {
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
