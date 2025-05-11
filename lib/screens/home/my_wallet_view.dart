import 'package:flutter/material.dart';

import '../../models/emerald_icon.dart';
import '../../models/multi_circle_indicator.dart';
import '../../models/progress_row_list.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressRowList(),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AnimatedRingChart(
              radius: 140,
              thickness: 5,
              gapDegrees: 5,
            ),

          ],
        )
      ],
    );
  }
}
