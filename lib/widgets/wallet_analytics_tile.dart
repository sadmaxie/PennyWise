import 'dart:io';
import 'package:flutter/material.dart';
import '../database/models/wallet.dart';

class WalletAnalyticsTile extends StatelessWidget {
  final Wallet wallet;
  final double amount;
  final String currencySymbol;
  final bool isIncome;

  const WalletAnalyticsTile({
    Key? key,
    required this.wallet,
    required this.amount,
    required this.currencySymbol,
    required this.isIncome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGoal = wallet.isGoal;
    final tagLabel =
        isGoal
            ? wallet.goalAmount != null
                ? "Goal • \$${wallet.goalAmount!.toStringAsFixed(0)}"
                : "Goal Wallet"
            : "Normal Wallet";

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: wallet.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: wallet.color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon + info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: wallet.color,
                backgroundImage:
                    (wallet.imagePath != null &&
                            File(wallet.imagePath!).existsSync())
                        ? FileImage(File(wallet.imagePath!))
                        : null,
                child:
                    wallet.imagePath == null
                        ? const Icon(
                          Icons.wallet,
                          color: Colors.white,
                          size: 16,
                        )
                        : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isGoal
                                ? Colors.amber.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tagLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: isGoal ? Colors.amber : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Bottom: Amount
          Text(
            (isIncome ? '+ ' : '- ') +
                '$currencySymbol${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isIncome ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
