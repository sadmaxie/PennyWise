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
            now.month == 1
                ? DateTime(now.year - 1, 12, 1)
                : DateTime(now.year, now.month - 1, 1);
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

  bool _isDateMatch(DateTime txDate, DateTime labelDate, DateRange range) {
    if (range == DateRange.lastYear) {
      return txDate.year == labelDate.year - 1 &&
          txDate.month == labelDate.month;
    }
    return txDate.year == labelDate.year &&
        txDate.month == labelDate.month &&
        txDate.day == labelDate.day;
  }

  Map<String, double> aggregateNetFlowData(
    List<Wallet> wallets,
    String cardGroupId,
  ) {
    if (cardGroupId.isEmpty) return {};

    final labels = generateDateLabels();
    final map = <String, double>{
      for (var d in labels)
        _selectedRange == DateRange.lastYear
                ? DateFormat('MMM').format(d)
                : DateFormat('MMM d').format(d):
            0.0,
    };

    final transactions =
        wallets
            .where((w) => w.cardGroupId == cardGroupId)
            .expand((w) => w.history)
            .toList();

    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      for (final labelDate in labels) {
        if (_isDateMatch(txDate, labelDate, _selectedRange)) {
          final key =
              _selectedRange == DateRange.lastYear
                  ? DateFormat('MMM').format(labelDate)
                  : DateFormat('MMM d').format(labelDate);
          map[key] = (map[key] ?? 0.0) + (tx.isIncome ? tx.amount : -tx.amount);
          break;
        }
      }
    }
    return map;
  }

  List<MapEntry<Wallet, double>> getTopWalletsByIncome(
    List<Wallet> wallets,
    String cardGroupId,
  ) {
    return _getWalletsSorted(
      wallets,
      cardGroupId,
      (tx) => tx.isIncome ? tx.amount : 0.0,
      top: true,
    );
  }

  List<MapEntry<Wallet, double>> getTopLossWalletsByNet(
    List<Wallet> wallets,
    String cardGroupId,
  ) {
    final labels = generateDateLabels();
    final resultMap = <Wallet, double>{};

    for (final wallet in wallets.where((w) => w.cardGroupId == cardGroupId)) {
      double net = 0.0;
      for (final tx in wallet.history) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (labels.any(
          (labelDate) => _isDateMatch(txDate, labelDate, _selectedRange),
        )) {
          net += tx.isIncome ? tx.amount : -tx.amount;
        }
      }
      if (net < 0) resultMap[wallet] = net;
    }

    final sorted =
        resultMap.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    return sorted.length > 3 ? sorted.sublist(0, 3) : sorted;
  }

  List<MapEntry<Wallet, double>> _getWalletsSorted(
    List<Wallet> wallets,
    String cardGroupId,
    double Function(dynamic tx) amountSelector, {
    bool top = true,
  }) {
    final labels = generateDateLabels();
    final resultMap = <Wallet, double>{};

    for (final wallet in wallets.where((w) => w.cardGroupId == cardGroupId)) {
      double total = 0.0;
      for (final tx in wallet.history) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (labels.any(
          (labelDate) => _isDateMatch(txDate, labelDate, _selectedRange),
        )) {
          total += amountSelector(tx);
        }
      }
      if (total > 0) resultMap[wallet] = total;
    }

    final sorted =
        resultMap.entries.toList()..sort(
          (a, b) =>
              top ? b.value.compareTo(a.value) : a.value.compareTo(b.value),
        );

    return sorted.length > 3 ? sorted.sublist(0, 3) : sorted;
  }

  List<MapEntry<Wallet, double>> getTopWalletsByNetPositive(
    List<Wallet> wallets,
    String cardGroupId,
  ) {
    final labels = generateDateLabels();
    final resultMap = <Wallet, double>{};

    for (final wallet in wallets.where((w) => w.cardGroupId == cardGroupId)) {
      double net = 0.0;
      for (final tx in wallet.history) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (labels.any(
          (labelDate) => _isDateMatch(txDate, labelDate, _selectedRange),
        )) {
          net += tx.isIncome ? tx.amount : -tx.amount;
        }
      }
      if (net > 0) resultMap[wallet] = net;
    }

    final sorted =
        resultMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sorted.length > 3 ? sorted.sublist(0, 3) : sorted;
  }
}
