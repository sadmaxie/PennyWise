import 'package:flutter/material.dart';

class MyWalletView extends StatelessWidget {
  const MyWalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "This is My Wallet page",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        SizedBox(height: 12),
        // Add your real wallet content here
      ],
    );
  }
}
