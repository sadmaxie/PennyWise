/// MyWalletView
/// A dashboard-like widget that shows:
/// - Wallet distribution in a ring chart
/// - Quick money actions (add/remove/move/income)
/// - Recent transaction list
/// - Goal wallet progress
///
/// Used in the HomePage below the top header.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../widgets/money_math_buttons.dart';
import '../../widgets/animated_ring_chart.dart';
import '../../widgets/progress_row_list.dart';
import '../../widgets/global_wallet_summary.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgressRowList(),
          const SizedBox(height: 20),

          // Chart + Actions
          Column(
            children: [
              const Center(
                child: AnimatedRingChart(
                  radius: 120,
                  thickness: 5,
                  gapDegrees: 5,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  MoneyMathButtons(type: 'add'),
                  MoneyMathButtons(type: 'remove'),
                  MoneyMathButtons(type: 'move'),
                  MoneyMathButtons(type: 'income'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  final provider = Provider.of<WalletProvider>(context, listen: false);
                  provider.undoLastAction();
                },
                icon: const Icon(Icons.undo, color: Colors.white),
                label: const Text('Undo', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const TransactionHistoryList(),
          const SizedBox(height: 30),
          const Text(
            'Goal Wallets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const GoalWalletList(),
        ],
      ),
    );
  }
}
