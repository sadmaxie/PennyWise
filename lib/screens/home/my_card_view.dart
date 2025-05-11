import 'package:flutter/material.dart';

class MyCardView extends StatelessWidget {
  const MyCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "This is My Card page",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 12),
        // Add your real card content here
      ],
    );
  }
}
