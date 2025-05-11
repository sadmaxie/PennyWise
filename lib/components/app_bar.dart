import 'package:flutter/material.dart';
import '../models/gradient_text.dart';
import '../screens/user/user_page.dart'; // adjust import

class TopHeader extends StatelessWidget {
  final bool showBackButton;
  final bool showUserIcon;

  const TopHeader({
    super.key,
    this.showBackButton = true,
    this.showUserIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 50, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 48), // placeholder for alignment
          // Title
          Expanded(child: Center(child: GradientText(text: 'PennyWise'))),

          // Sized box
          SizedBox(height: 50),

          // User icon
          if (showUserIcon)
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const UserPage()),
                );
              },
            )
          else
            const SizedBox(width: 48), // placeholder for alignment
        ],
      ),
    );
  }
}
