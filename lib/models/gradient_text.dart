import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;

  const GradientText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        final colors = [
          const Color(0xFF8AD4EC),
          const Color(0xFFEF96FF),
          const Color(0xFFFF56A9),
          const Color(0xFFFFAA6C),
        ];
        final stops = [0.0, 0.3, 0.6, 1.0];
        return LinearGradient(
          colors: colors,
          stops: stops,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
      ),
    );
  }
}
