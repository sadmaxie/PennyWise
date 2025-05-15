import 'package:flutter/material.dart';
import '../widgets/gradient_text.dart';

/// A top header widget for the app screens.
///
/// Features:
/// - Optional back button on the left.
/// - Centered gradient title text ("PennyWise").
/// - Optional icon button on the right that navigates to a target page.
class TopHeader extends StatelessWidget {
  final bool showBackButton;
  final bool showIconButton;
  final IconData? icon;
  final Widget? targetPage;

  const TopHeader({
    super.key,
    this.showBackButton = true,
    this.showIconButton = true,
    this.icon,
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

          if (showIconButton && icon != null && targetPage != null)
            IconButton(
              icon: Icon(icon, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => targetPage!),
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
