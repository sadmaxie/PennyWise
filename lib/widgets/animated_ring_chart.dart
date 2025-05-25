// animated_ring_chart.dart
// A custom animated circular ring chart showing wallet balance percentages with a center display.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/providers/card_group_provider.dart';
import '../database/providers/wallet_provider.dart';
import '../database/providers/user_provider.dart';
import '../utils/currency_symbols.dart';

class AnimatedRingChart extends StatefulWidget {
  final double radius;
  final double thickness;
  final double gapDegrees;
  final Duration animationDuration;

  const AnimatedRingChart({
    super.key,
    this.radius = 100,
    this.thickness = 16,
    this.gapDegrees = 4,
    this.animationDuration = const Duration(seconds: 1),
  });

  @override
  State<AnimatedRingChart> createState() => _AnimatedRingChartState();
}

class _AnimatedRingChartState extends State<AnimatedRingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<ProgressItemWithPercentage> _lastItems = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _shouldAnimate(List<ProgressItemWithPercentage> newItems) {
    if (newItems.length != _lastItems.length) return true;
    for (int i = 0; i < newItems.length; i++) {
      if (newItems[i].amount != _lastItems[i].amount) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final currentCard = cardGroupProvider.selectedCardGroup;

    final items = currentCard == null
        ? <ProgressItemWithPercentage>[]
        : walletProvider
        .chartItemsForCardGroup(currentCard.id)
        .cast<ProgressItemWithPercentage>();

    final totalBalance = items.fold(0.0, (sum, item) => sum + item.amount);
    final size = widget.radius * 2;

    final userProvider = Provider.of<UserProvider>(context);
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    if (_shouldAnimate(items)) {
      _controller
        ..reset()
        ..forward();
      _lastItems = List.from(items);
    }

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) => CustomPaint(
          painter: _RingPainter(
            items: items,
            strokeWidth: widget.thickness,
            gapDegrees: widget.gapDegrees,
            progress: _animation.value,
          ),
          child: FadeTransition(
            opacity: _animation,
            child: Center(
              child: _BalanceDisplay(
                total: totalBalance,
                currencySymbol: currencySymbol,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<ProgressItemWithPercentage> items;
  final double strokeWidth;
  final double gapDegrees;
  final double progress;

  _RingPainter({
    required this.items,
    required this.strokeWidth,
    required this.gapDegrees,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
    double startAngle = -90 * (3.1416 / 180); // Top

    for (final item in items) {
      final sweepDegrees =
          item.percentage * (360 - gapDegrees * items.length) / 100;
      final sweepAngle = (sweepDegrees * (3.1416 / 180)) * progress;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + (gapDegrees * (3.1416 / 180));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _BalanceDisplay extends StatefulWidget {
  final double total;
  final String currencySymbol;

  const _BalanceDisplay({required this.total, required this.currencySymbol});

  @override
  State<_BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<_BalanceDisplay> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _loadVisibilityPreference();
  }

  Future<void> _loadVisibilityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible = prefs.getBool('balance_visibility') ?? true;
    });
  }

  Future<void> _toggleVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isVisible = !_isVisible;
      prefs.setBool('balance_visibility', _isVisible);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = constraints.maxWidth * 0.10;
        final textSize = constraints.maxWidth * 0.1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF61617D),
                size: iconSize,
              ),
              onPressed: _toggleVisibility,
            ),
            Text(
              'Total Balance',
              style: TextStyle(color: Colors.white, fontSize: textSize * 0.6),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.total),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, _) => Text(
                  _isVisible
                      ? '${widget.currencySymbol}${value.toStringAsFixed(2)}'
                      : '••••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
