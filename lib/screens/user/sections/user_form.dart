/// user_form.dart
/// Form section for updating the user's name and currency.
/// Includes a text field and a dropdown menu.

import 'package:flutter/material.dart';

class UserFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final String selectedCurrency;
  final List<String> currencyList;
  final void Function(String) onCurrencyChanged;

  const UserFormSection({
    super.key,
    required this.nameController,
    required this.selectedCurrency,
    required this.currencyList,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter your name",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF3B3B52),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF3B3B52),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency,
              dropdownColor: const Color(0xFF3B3B52),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              items:
                  currencyList.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(
                        code,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (val) => onCurrencyChanged(val!),
            ),
          ),
        ),
      ],
    );
  }
}
