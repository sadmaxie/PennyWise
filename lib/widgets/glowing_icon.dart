// glowing_icon.dart
// Custom widget that renders a glowing hexagon-shaped icon using CustomPaint.

import 'package:flutter/material.dart';

class GlowingIcon extends StatelessWidget {
  final Color color;
  final double glowRadius;
  final double size;

  const GlowingIcon({
    Key? key,
    this.color = Colors.white,
    this.glowRadius = 10.0,
    this.size = 42.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect using layered box shadows
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: glowRadius * 0.2,
              ),
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: glowRadius * 0.5,
              ),
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: glowRadius,
              ),
            ],
          ),
        ),
        // Hexagon shape using CustomPainter
        CustomPaint(
          size: Size(size, size),
          painter: _HexagonIconPainter(color: color),
        ),
      ],
    );
  }
}

class _HexagonIconPainter extends CustomPainter {
  final Color color;

  _HexagonIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w * 0.85, h * 0.25)
      ..lineTo(w * 0.85, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(w * 0.15, h * 0.75)
      ..lineTo(w * 0.15, h * 0.25)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
