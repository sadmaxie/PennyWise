// money_math_buttons.dart
// Reusable round icon button for add, remove, move, or distribute-income actions.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../wallet/money_edit_sheet.dart';
import '../wallet/move_money_sheet.dart';
import '../wallet/distribution_income_sheet.dart';

class MoneyMathButtons extends StatelessWidget {
  final String type; // 'add', 'remove', 'move', 'income'

  const MoneyMathButtons({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (type) {
      'add' => 'assets/icons/add_money.svg',
      'remove' => 'assets/icons/remove_money.svg',
      'move' => 'assets/icons/move_money.svg',
      'income' => 'assets/icons/percentage_money.svg',
      _ => '',
    };

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        width: 65,
        height: 65,
        decoration: const BoxDecoration(
          color: Color(0xFF434463),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            color: Colors.white,
            width: 35,
            height: 35,
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    switch (type) {
      case 'move':
        showMoveMoneyBottomSheet(context);
        break;
      case 'income':
        showDistributeIncomeSheet(context);
        break;
      default:
        showMoneyEditBottomSheet(context: context, type: type);
    }
  }
}
