import 'package:flutter/material.dart';
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
          const SizedBox(height: 30),

          // Centered Ring Chart
          const Center(
            child: AnimatedRingChart(radius: 140, thickness: 5, gapDegrees: 5),
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
