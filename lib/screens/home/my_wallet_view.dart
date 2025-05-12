import 'package:flutter/material.dart';
import '../../models/add_remove_icon_button.dart';
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
          // Centered Ring Chart
          Column(
            children: [
              AddRemoveIconButton(type: 'move'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // add money
                  AddRemoveIconButton(type: 'add'),

                  // Pie
                  AnimatedRingChart(radius: 120, thickness: 5, gapDegrees: 5),

                  // remove money
                  AddRemoveIconButton(type: 'remove'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Section Header
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

          SizedBox(height: 15),

          // Transaction history + golds section
          const WalletOverviewSection(),
        ],
      ),
    );
  }
}
