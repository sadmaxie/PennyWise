import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wallet.dart';

enum DateRange { thisWeek, lastWeek, thisMonth, lastMonth, lastYear }

class DetailsProvider with ChangeNotifier {
  DateRange _selectedRange = DateRange.thisWeek;
  DateRange get selectedRange => _selectedRange;

  void setRange(DateRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  List<DateTime> generateDateLabels() {
    final now = DateTime.now();
    switch (_selectedRange) {
      case DateRange.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return List.generate(7, (i) => start.add(Duration(days: i)));
      case DateRange.lastWeek:
        final start = now.subtract(Duration(days: now.weekday + 6));
        return List.generate(7, (i) => start.add(Duration(days: i)));
      case DateRange.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return _generateDateRange(start, end);
      case DateRange.lastMonth:
        final lastMonth =
        now.month == 1 ? DateTime(now.year - 1, 12, 1) : DateTime(now.year, now.month - 1, 1);
        final end = DateTime(lastMonth.year, lastMonth.month + 1, 0);
        return _generateDateRange(lastMonth, end);
      case DateRange.lastYear:
        return List.generate(12, (i) => DateTime(now.year - 1, i + 1, 1));
    }
  }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) => start.add(Duration(days: i)));
  }

  Map<String, double> aggregateNetFlowData(List<Wallet> wallets, String cardGroupId) {
    if (cardGroupId.isEmpty) return {};

    final labels = generateDateLabels();
    final map = <String, double>{};

    debugPrint("Selected Range: $_selectedRange");
    debugPrint("Date Labels:");
    for (final d in labels) {
      final label = _selectedRange == DateRange.lastYear ? DateFormat('MMM').format(d) : DateFormat('MMM d').format(d);
      debugPrint("  - $label");
      map[label] = 0.0;
    }

    final transactions = wallets
        .where((w) => w.cardGroupId == cardGroupId)
        .expand((w) => w.history)
        .toList();

    debugPrint("Transactions Count: ${transactions.length}");
    for (final tx in transactions.take(10)) {
      debugPrint("TX: date=${tx.date}, amount=${tx.amount}, income=${tx.isIncome}");
    }

    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

      for (final labelDate in labels) {
        if (_isDateMatch(txDate, labelDate, _selectedRange)) {
          final key = _selectedRange == DateRange.lastYear ? DateFormat('MMM').format(labelDate) : DateFormat('MMM d').format(labelDate);
          map[key] = (map[key] ?? 0.0) + (tx.isIncome ? tx.amount : -tx.amount);
          break;
        }
      }
    }

    debugPrint("Net Flow Data:");
    map.forEach((k, v) => debugPrint("  $k → \$${v.toStringAsFixed(2)}"));

    return map;
  }

  bool _isDateMatch(DateTime txDate, DateTime labelDate, DateRange range) {
    switch (range) {
      case DateRange.lastYear:
        return txDate.year == labelDate.year - 1 && txDate.month == labelDate.month;
      default:
        return txDate.year == labelDate.year && txDate.month == labelDate.month && txDate.day == labelDate.day;
    }
  }
}