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
  late Map<DateTime, List<TransactionItem>> _grouped;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _grouped = _groupTransactionsByDay(context);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _grouped = _groupTransactionsByDay(context);
    });
  }

  Map<DateTime, List<TransactionItem>> _groupTransactionsByDay(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final cardGroupProvider = Provider.of<CardGroupProvider>(context, listen: false);
    final selectedGroupId = cardGroupProvider.selectedCardGroup?.id;
    final Map<DateTime, List<TransactionItem>> map = {};

    for (final wallet in walletProvider.wallets) {
      if (wallet.cardGroupId != selectedGroupId) continue;
      for (final tx in wallet.history) {
        final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
        map.putIfAbsent(day, () => []).add(tx);
      }
    }

    return map;
  }

  Color _getDominantColor(List<TransactionItem> txs) {
    int income = 0, expense = 0, move = 0, distribute = 0;

    for (final tx in txs) {
      if (tx.fromWallet != null && tx.toWallet != null) {
        move++;
      } else if (tx.isDistribution) {
        distribute++;
      } else if (tx.isIncome) {
        income++;
      } else {
        expense++;
      }
    }

    final dominant = {
      'income': income,
      'expense': expense,
      'move': move,
      'distribute': distribute,
    }.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    switch (dominant.first.key) {
      case 'move':
        return Colors.orangeAccent.shade200;
      case 'distribute':
        return Colors.lightBlueAccent.shade100;
      case 'income':
        return Colors.greenAccent;
      case 'expense':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  List<TransactionItem> _getTransactionsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _grouped[d] ?? [];
  }

  void _openMonthYearPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _focusedDay = DateTime(picked.year, picked.month, picked.day);
        _selectedDay = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
              Expanded(child: _buildDayHistory()),
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
      onFormatChanged: (format) {
        setState(() => _calendarFormat = format);
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      headerStyle: HeaderStyle(
        titleCentered: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
        formatButtonVisible: false,
        titleTextFormatter: (date, locale) => DateFormat.yMMMM().format(date),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
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
        headerTitleBuilder: (context, date) {
          return GestureDetector(
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
          );
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime date, {bool isToday = false, bool isSelected = false}) {
    if (_grouped.isEmpty) return const SizedBox.shrink();
    final txs = _grouped[DateTime(date.year, date.month, date.day)];
    final hasTransactions = txs != null && txs.isNotEmpty;
    final color = hasTransactions ? _getDominantColor(txs!) : Colors.transparent;
    final borderColor = isSelected
        ? const Color(0xFF292A3F)
        : isToday
        ? Colors.blueAccent
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: hasTransactions ? color.withOpacity(0.9) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        '${date.day}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDayHistory() {
    final transactions = _selectedDay != null ? _getTransactionsForDay(_selectedDay!) : [];

    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          "No transactions for this day.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final provider = Provider.of<WalletProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    return ListView(
      children: transactions.reversed.map((tx) {
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
        final showNote = tx.note.trim().isNotEmpty;

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
                    Text(
                      walletLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showNote)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          tx.note.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(tx.date),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
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
