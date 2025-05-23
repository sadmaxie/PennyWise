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

    final label = switch (type) {
      'add' => 'Add',
      'remove' => 'Remove',
      'move' => 'Move',
      'income' => 'Distribute',
      _ => 'Action',
    };

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF3B3B52),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: SvgPicture.asset(
                assetPath,
                color: Colors.white,
                width: 32,
                height: 32,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
