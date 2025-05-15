// progress_row_list.dart
// Horizontally scrollable row of wallet percentages with glowing icons.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/wallet_provider.dart';
import 'glowing_icon.dart';

class ProgressRowList extends StatelessWidget {
  const ProgressRowList({super.key});

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<WalletProvider>(context).chartItems;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: items.map((item) {
          return Container(
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
                Text(
                  "${item.percentage.toStringAsFixed(1)}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
