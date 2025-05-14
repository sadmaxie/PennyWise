import 'package:flutter/material.dart';
import '../../models/money_math_buttons.dart';
import '../../models/multi_circle_indicator.dart';
import '../../models/progress_row_list.dart';
import '../../models/wallet_overview_section.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProgressRowList(),
          // Money Actions and Pie Chart
          Column(
            children: [
              const MoneyMathButtons(type: 'move'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  MoneyMathButtons(type: 'add'),
                  Expanded(
                    child: Center(
                      child: AnimatedRingChart(
                        radius: 100,
                        thickness: 5,
                        gapDegrees: 5,
                      ),
                    ),
                  ),
                  MoneyMathButtons(type: 'remove'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Section Header: History & Goals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Goals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const WalletOverviewSection(),
        ],
      ),
    );
  }
}
