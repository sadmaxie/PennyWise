import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/add_remove_money.dart';
import '../data/move_money.dart';

class MoneyMathButtons extends StatelessWidget {
  final String type; // 'add', 'remove', or 'move'

  const MoneyMathButtons({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (type) {
      'add' => 'assets/icons/add_money.svg',
      'remove' => 'assets/icons/remove_money.svg',
      'move' => 'assets/icons/move_money.svg',
      _ => '',
    };

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: SvgPicture.asset(assetPath, height: 35, width: 30),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (type == 'move') {
      showMoveMoneyBottomSheet(context);
    } else {
      showMoneyEditBottomSheet(context: context, type: type);
    }
  }
}
