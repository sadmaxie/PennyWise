// date_selector.dart
// A simple calendar picker widget that displays the selected date and allows selection via a date picker dialog.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) {
                return Theme(data: ThemeData.dark(), child: child!);
              },
            );
            if (picked != null) onDateSelected(picked);
          },
          child: Text(
            DateFormat.yMMMd().format(selectedDate),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
