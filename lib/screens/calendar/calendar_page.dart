import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../database/providers/wallet_provider.dart';
import '../../database/models/transaction_item.dart';
import '../../database/models/wallet.dart';
import '../../database/providers/user_provider.dart';
import '../../database/providers/card_group_provider.dart';
import '../../navigation/top_header.dart';
import '../../utils/currency_symbols.dart';
import '../user/user_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<TransactionItem>> _grouped = {};
  final Map<DateTime, Color> _dayColors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _grouped = _groupTransactionsByDay(context);
      });
    });
  }

  Map<DateTime, List<TransactionItem>> _groupTransactionsByDay(BuildContext context) {
    final wallets = Provider.of<WalletProvider>(context, listen: false).wallets;
    final selectedGroupId = Provider.of<CardGroupProvider>(context, listen: false).selectedCardGroup?.id;
    final map = <DateTime, List<TransactionItem>>{};

    for (final wallet in wallets) {
      if (wallet.cardGroupId != selectedGroupId) continue;
      for (final tx in wallet.history) {
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        map.putIfAbsent(day, () => []).add(tx);
      }
    }

    return map;
  }

  Color _getCachedDominantColor(DateTime day, List<TransactionItem> txs) {
    return _dayColors.putIfAbsent(day, () => _calculateDominantColor(txs));
  }

  Color _calculateDominantColor(List<TransactionItem> txs) {
    final counts = {'income': 0, 'expense': 0, 'move': 0, 'distribute': 0};
    for (final tx in txs) {
      if (tx.fromWallet != null && tx.toWallet != null) counts['move'] = counts['move']! + 1;
      else if (tx.isDistribution) counts['distribute'] = counts['distribute']! + 1;
      else if (tx.isIncome) counts['income'] = counts['income']! + 1;
      else counts['expense'] = counts['expense']! + 1;
    }

    final dominant = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    switch (dominant.first.key) {
      case 'move': return Colors.orangeAccent.shade200;
      case 'distribute': return Colors.lightBlueAccent.shade100;
      case 'income': return const Color(0xFF64ECAC);
      case 'expense': return const Color(0xFFFF5252);
      default: return Colors.grey;
    }
  }

  List<TransactionItem> _getTransactionsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _grouped[normalized] ?? [];
  }

  void _openMonthYearPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
        _selectedDay = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopHeader(
                showBackButton: false,
                showIconButton: false,
                icon: Icons.person,
                targetPage: UserPage(),
              ),
              const SizedBox(height: 16),
              _buildCalendar(),
              const SizedBox(height: 20),
              const Text(
                "Day History",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildDayHistory(key: ValueKey(_selectedDay)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
        formatButtonVisible: false,
        titleTextFormatter: (date, locale) => DateFormat.yMMMM().format(date),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(color: Colors.transparent),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(color: Colors.redAccent),
        weekdayStyle: TextStyle(color: Colors.white70),
      ),
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        defaultTextStyle: TextStyle(color: Colors.white),
        weekendTextStyle: TextStyle(color: Colors.white),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) => _buildDayCell(date),
        todayBuilder: (context, date, _) => _buildDayCell(date, isToday: true),
        selectedBuilder: (context, date, _) => _buildDayCell(date, isSelected: true),
        headerTitleBuilder: (context, date) => GestureDetector(
          onTap: _openMonthYearPicker,
          child: Center(
            child: Text(
              DateFormat.yMMMM().format(date),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, {bool isToday = false, bool isSelected = false}) {
    if (_grouped.isEmpty) return const SizedBox.shrink();
    final key = DateTime(date.year, date.month, date.day);
    final txs = _grouped[key];
    final hasTxs = txs != null && txs.isNotEmpty;
    final color = hasTxs ? _getCachedDominantColor(key, txs!) : Colors.transparent;
    final borderColor = isSelected
        ? const Color(0xFF434462)
        : isToday
        ? const Color(0xFF292A3F)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: hasTxs ? color.withOpacity(0.9) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _buildDayHistory({Key? key}) {
    final txs = _selectedDay != null ? _getTransactionsForDay(_selectedDay!) : [];
    if (txs.isEmpty) {
      return const Center(
        child: Text("No transactions for this day.", style: TextStyle(color: Colors.white54)),
      );
    }

    final provider = Provider.of<WalletProvider>(context);
    final currencySymbol = currencySymbols[Provider.of<UserProvider>(context).user?.currencyCode ?? 'USD'] ?? 'USD';

    return ListView(
      children: txs.reversed.map((tx) {
        final isMove = tx.fromWallet != null && tx.toWallet != null;
        final icon = isMove
            ? Icons.currency_exchange_outlined
            : tx.isDistribution
            ? Icons.paid_outlined
            : tx.isIncome
            ? Icons.arrow_downward
            : Icons.arrow_upward;
        final color = isMove
            ? Colors.orangeAccent.shade200
            : tx.isDistribution
            ? Colors.lightBlueAccent.shade100
            : tx.isIncome
            ? Colors.greenAccent
            : Colors.redAccent;

        final walletLabel = isMove
            ? "${tx.fromWallet} ➤ ${tx.toWallet}"
            : provider.wallets.firstWhere(
              (w) => w.history.contains(tx),
          orElse: () => Wallet(
            name: "Unknown Wallet",
            amount: 0,
            isGoal: false,
            colorValue: Colors.grey.value,
            history: [],
            cardGroupId: "unknown",
          ),
        ).name;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(walletLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    if (tx.note.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          tx.note.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(DateFormat.yMMMd().format(tx.date), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                "${tx.isIncome ? '+ ' : '- '}$currencySymbol${tx.amount.toStringAsFixed(2)}",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
