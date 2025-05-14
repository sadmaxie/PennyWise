import 'package:flutter/material.dart';
import '../../models/money_math_buttons.dart';
import '../../models/multi_circle_indicator.dart';
import '../../models/progress_row_list.dart';
import '../../models/global_wallet_summary.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgressRowList(),
          SizedBox(height: 20),
          // Money Actions and Pie Chart
          Column(
            children: [
              // Centered ring chart
              const Center(
                child: AnimatedRingChart(
                  radius: 120,
                  thickness: 5,
                  gapDegrees: 5,
                ),
              ),

              const SizedBox(height: 30), // Spacing between chart and buttons

              // Row of buttons below the chart
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

          const Text(
            'Recent Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),
          const TransactionHistoryList(), // Custom widget we extract from global summary

          SizedBox(height: 30),

          const Text(
            'Goal Wallets',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),
          const GoalWalletList(), // Another custom widget

        ],
      ),
    );
  }
}
