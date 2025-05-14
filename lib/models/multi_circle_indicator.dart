import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/wallet_provider.dart';

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
  void didUpdateWidget(covariant AnimatedRingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<WalletProvider>(context).chartItems;
    final totalBalance = items.fold(0.0, (sum, item) => sum + item.amount);
    final double size = widget.radius * 2;

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
          child: Center(
            child: _BalanceDisplay(total: totalBalance),
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
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    double startAngle = -90 * (3.1416 / 180);

    for (final item in items) {
      final sweepDegrees = item.percentage * (360 - gapDegrees * items.length) / 100;
      final sweepAngle = (sweepDegrees * (3.1416 / 180)) * progress;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += (sweepDegrees * (3.1416 / 180)) + (gapDegrees * (3.1416 / 180));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _BalanceDisplay extends StatefulWidget {
  final double total;
  const _BalanceDisplay({required this.total});

  @override
  State<_BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<_BalanceDisplay> {
  bool _isVisible = true;

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
              onPressed: () {
                setState(() => _isVisible = !_isVisible);
              },
            ),
            Text(
              'Total Balance',
              style: TextStyle(color: Colors.white, fontSize: textSize * 0.6),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _isVisible ? '\$${widget.total.toStringAsFixed(2)}' : '••••••',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: textSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
