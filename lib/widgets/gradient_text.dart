// gradient_text.dart
// A widget that applies a multi-color gradient to text using ShaderMask.

import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;

  const GradientText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF8AD4EC),
            Color(0xFFEF96FF),
            Color(0xFFFF56A9),
            Color(0xFFFFAA6C),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
      ),
    );
  }
}
