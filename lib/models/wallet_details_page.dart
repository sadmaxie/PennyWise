import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../database/wallet_provider.dart';
import '../database/wallet.dart';
import '../database/transaction_item.dart';

class WalletDetailsPage extends StatelessWidget {
  final Wallet wallet;

  const WalletDetailsPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    final double totalMoneyForTopChart = walletProvider.overallTotalAmountForTopChart;
    final history = wallet.history.reversed.take(4).toList();

    final double topChartReference =
    totalMoneyForTopChart > 0 ? totalMoneyForTopChart : (wallet.amount > 0 ? wallet.amount : 1.0);
    final double topChartProgress =
    (wallet.amount > 0 && topChartReference > 0) ? (wallet.amount / topChartReference).clamp(0.0, 1.0) : 0.0;
    final double displayPercent = (topChartProgress * 100).clamp(0, 100);

    double? goalProgress;
    double? amountLeft;
    if (wallet.isGoal && wallet.goalAmount != null && wallet.goalAmount! > 0) {
      goalProgress = (wallet.amount / wallet.goalAmount!).clamp(0.0, 1.0);
      amountLeft = (wallet.goalAmount! - wallet.amount).clamp(0.0, wallet.goalAmount!);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBar(context),
              const SizedBox(height: 20),
              _buildHeaderCard(context, topChartProgress, displayPercent),
              const SizedBox(height: 24),
              if (wallet.incomePercent != null)
                _buildInfoTile(
                  context,
                  leading: Icons.trending_up_outlined,
                  title: "Income %",
                  value: "${wallet.incomePercent!.toStringAsFixed(0)}%",
                ),
              if (wallet.description?.isNotEmpty == true)
                _buildDescriptionTile(context, wallet.description!),
              if (wallet.isGoal && goalProgress != null && amountLeft != null)
                _buildGoalSection(context, goalProgress, amountLeft),
              const SizedBox(height: 24),
              _buildTransactionSection(context, history),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BackButton(color: Colors.white),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => _handleEdit(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _handleDelete(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, double progressValue, double displayPercent) {
    final createdAtText =
    wallet.createdAt != null ? DateFormat('MM/yy').format(wallet.createdAt!) : 'N/A';
    final type = wallet.isGoal ? "Goal Wallet" : "Normal Wallet";

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            wallet.color.withOpacity(0.3),
            wallet.color.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 60,
                  child: CustomPaint(
                    painter: SemiCircleChartPainter(progressValue, Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Text(
                    "${displayPercent.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            wallet.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldColumn("Balance", "\$${wallet.amount.toStringAsFixed(2)}"),
              _buildFieldColumn("Created", createdAtText),
              _buildFieldColumn("Type", type),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSection(BuildContext context, double progress, double amountLeft) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF292A3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("GOAL PROGRESS", style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("\$${wallet.amount.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("of \$${wallet.goalAmount!.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(wallet.color),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${(progress * 100).toStringAsFixed(0)}% Reached",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text("\$${amountLeft.toStringAsFixed(2)} left",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData leading, required String title, required String value}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(leading, color: Colors.white70, size: 24),
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
    );
  }

  Widget _buildDescriptionTile(BuildContext context, String description) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF292A3F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Description", style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTransactionSection(BuildContext context, List<TransactionItem> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("RECENT TRANSACTIONS", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text("No transactions yet", style: TextStyle(color: Colors.white54))),
          )
        else
          ...history.map((t) => _buildTransactionTile(context, t)).toList(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: wallet.color,
              side: BorderSide(color: wallet.color),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Navigate to full history for ${wallet.name}")),
              );
            },
            child: const Text("VIEW FULL HISTORY", style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionItem t) {
    final isIncome = t.isIncome;
    final icon = isIncome ? Icons.arrow_circle_down_outlined : Icons.arrow_circle_up_outlined;
    final color = isIncome ? Colors.greenAccent : Colors.redAccent;
    final amountText = "${isIncome ? "+" : "-"}\$${t.amount.toStringAsFixed(2)}";

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF292A3F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(t.note, style: const TextStyle(color: Colors.white)),
        subtitle: Text(DateFormat.yMMMd().format(t.date), style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: Text(amountText, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit wallet: ${wallet.name} (Not implemented)")),
    );
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF292A3F),
          title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete the wallet "${wallet.name}"?', style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Deleting wallet: ${wallet.name} (Not implemented)")),
                );
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SemiCircleChartPainter extends CustomPainter {
  final double progress;
  final Color color;

  SemiCircleChartPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    final Rect rect = Rect.fromLTRB(0, 0, size.width, size.height * 2);
    const double startAngle = math.pi;
    final double sweepAngle = math.pi * progress;

    canvas.drawArc(rect, startAngle, math.pi, false, bgPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant SemiCircleChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}