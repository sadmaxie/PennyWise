import 'package:flutter/material.dart';
import '../widgets/gradient_text.dart';

/// A reusable header widget with optional back button and customizable icon + navigation.
///
/// Features:
/// - Optional back button on the left.
/// - Centered gradient title ("PennyWise").
/// - Optional icon button on the right with custom icon and navigation target.
class TopHeader extends StatelessWidget {
  final bool showBackButton;
  final bool showIconButton;
  final IconData icon;
  final Widget? targetPage;

  const TopHeader({
    super.key,
    this.showBackButton = true,
    this.showIconButton = true,
    this.icon = Icons.person, // default icon
    this.targetPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 48),

          Expanded(child: Center(child: GradientText(text: 'PennyWise'))),

          if (showIconButton && targetPage != null)
            IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => targetPage!),
                );
              },
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
