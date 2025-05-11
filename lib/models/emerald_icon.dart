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
        // Glow Effect (Multiple Shadows)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Or use a custom shape
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
        // Inner Icon (CustomPaint or SVG)
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

    // Draw your custom shape here (simplified hexagon)
    final Path path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}