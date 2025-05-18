// progress_row_list.dart
// Horizontally scrollable row of wallet percentages with glowing icons.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/providers/wallet_provider.dart';
import '../database/providers/card_group_provider.dart';
import 'glowing_icon.dart';

class ProgressRowList extends StatelessWidget {
  const ProgressRowList({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final currentCard = cardGroupProvider.selectedCardGroup;

    if (currentCard == null) return const SizedBox();

    final items = walletProvider.chartItemsForCardGroup(currentCard.id);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children:
        items.map((item) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _ProgressChip(item: item),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgressChip extends StatelessWidget {
  final ProgressItemWithPercentage item;

  const _ProgressChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(item.name + item.percentage.toString()),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B3A5A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlowingIcon(
            color: item.color,
            glowRadius: 15.0,
            size: 20.0,
          ),
          const SizedBox(width: 8),
          Text(
            item.name,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: item.percentage),
            builder: (context, value, _) => Text(
              "${value.toStringAsFixed(1)}%",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
