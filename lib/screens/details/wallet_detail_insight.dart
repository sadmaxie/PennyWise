import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/wallet.dart';
import '../../database/providers/details_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../utils/currency_symbols.dart';

enum LocalDateRange { thisWeek, lastWeek, thisMonth, lastMonth, lastYear }

class WalletDetailInsight extends StatefulWidget {
  const WalletDetailInsight({super.key});

  @override
  State<WalletDetailInsight> createState() => _WalletDetailInsightState();
}

class _WalletDetailInsightState extends State<WalletDetailInsight> {
  Wallet? selectedWallet;
  LocalDateRange selectedRange = LocalDateRange.thisWeek;

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final detailsProvider = Provider.of<DetailsProvider>(context);
    final wallets = walletProvider.wallets;

    final currencyCode = 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final dateRange = _mapRangeToActual(selectedRange);
    final filteredTransactions =
        selectedWallet != null
            ? detailsProvider.getTransactionsForWallet(
              selectedWallet!,
              dateRange.start,
              dateRange.end,
            )
            : [];

    final totalIncome = filteredTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = filteredTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Wallet Insight',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Date Range Chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: LocalDateRange.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final range = LocalDateRange.values[i];
              final isSelected = selectedRange == range;
              return GestureDetector(
                onTap: () => setState(() => selectedRange = range),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF434462)
                            : const Color(0xFF292A3F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.white24 : Colors.white10,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _rangeLabel(range),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Insight Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF292A3F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet selector with icon/image
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: selectedWallet?.color ?? Colors.white10,
                    backgroundImage:
                        selectedWallet?.imagePath != null &&
                                File(selectedWallet!.imagePath!).existsSync()
                            ? FileImage(File(selectedWallet!.imagePath!))
                            : null,
                    child:
                        selectedWallet?.imagePath == null
                            ? const Icon(Icons.wallet, color: Colors.white)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Wallet>(
                        value: selectedWallet,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF292A3F),
                        hint: const Text(
                          'Choose a Wallet',
                          style: TextStyle(color: Colors.white54),
                        ),
                        iconEnabledColor: Colors.white70,
                        onChanged:
                            (wallet) => setState(() => selectedWallet = wallet),
                        items:
                            wallets.map((wallet) {
                              return DropdownMenuItem(
                                value: wallet,
                                child: Text(
                                  wallet.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Type Label
              if (selectedWallet != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selectedWallet!.isGoal
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selectedWallet!.isGoal ? 'Goal Wallet' : 'Spending Wallet',
                    style: TextStyle(
                      color:
                          selectedWallet!.isGoal ? Colors.amber : Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Metrics
              _walletMetricRow(
                icon: Icons.attach_money,
                label: 'Total Added',
                value: '$currencySymbol${totalIncome.toStringAsFixed(2)}',
                color: const Color(0xFF64ECAC),
                bgColor: const Color(0xFF64ECAC).withOpacity(0.15),
                iconColor: const Color(0xFF64ECAC),
              ),
              const SizedBox(height: 12),
              _walletMetricRow(
                icon: Icons.receipt_long,
                label: 'Total Spent',
                value: '$currencySymbol${totalExpense.toStringAsFixed(2)}',
                color: const Color(0xFFFF5252),
                bgColor: const Color(0xFFFF5252).withOpacity(0.15),
                iconColor: const Color(0xFFFF5252),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _walletMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _rangeLabel(LocalDateRange range) {
    switch (range) {
      case LocalDateRange.thisWeek:
        return 'This Week';
      case LocalDateRange.lastWeek:
        return 'Last Week';
      case LocalDateRange.thisMonth:
        return 'This Month';
      case LocalDateRange.lastMonth:
        return 'Last Month';
      case LocalDateRange.lastYear:
        return 'Last Year';
    }
  }

  DateTimeRange _mapRangeToActual(LocalDateRange range) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    switch (range) {
      case LocalDateRange.thisWeek:
        return DateTimeRange(start: startOfWeek, end: now);
      case LocalDateRange.lastWeek:
        final lastWeekStart = startOfWeek.subtract(const Duration(days: 7));
        final lastWeekEnd = lastWeekStart.add(const Duration(days: 6));
        return DateTimeRange(start: lastWeekStart, end: lastWeekEnd);
      case LocalDateRange.thisMonth:
        return DateTimeRange(start: DateTime(now.year, now.month), end: now);
      case LocalDateRange.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1);
        final lastMonthEnd = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: lastMonth, end: lastMonthEnd);
      case LocalDateRange.lastYear:
        final start = DateTime(now.year - 1, 1, 1);
        final end = DateTime(now.year - 1, 12, 31);
        return DateTimeRange(start: start, end: end);
    }
  }
}
