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
        // Glow Effect
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.7),
                blurRadius: glowRadius * 0.2,
                spreadRadius: 0.0,
              ),
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: glowRadius * 0.5,
                spreadRadius: 0.0,
              ),
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: glowRadius,
                spreadRadius: 0.0,
              ),
            ],
          ),
        ),
        // Custom Hexagon Shape
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
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;

    final Path path = Path();
    path.moveTo(w * 0.5, 0);          // Top center
    path.lineTo(w * 0.85, h * 0.25);  // Upper right
    path.lineTo(w * 0.85, h * 0.75);  // Lower right
    path.lineTo(w * 0.5, h);          // Bottom center
    path.lineTo(w * 0.15, h * 0.75);  // Lower left
    path.lineTo(w * 0.15, h * 0.25);  // Upper left
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
