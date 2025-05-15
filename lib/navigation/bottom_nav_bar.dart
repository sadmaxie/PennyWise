import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// A custom bottom navigation bar using the `google_nav_bar` package.
///
/// Features:
/// - Four navigation tabs (Home, Wallets, Calendar, Details).
/// - Custom SVG icons for each tab.
/// - `onTabChange` callback to handle navigation logic.
class BottomNavBar extends StatelessWidget {
  final void Function(int) onTabChange;

  const BottomNavBar({
    super.key,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D49),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
        child: GNav(
          iconSize: 5,
          gap: 8,
          padding: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFF2D2D49),
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: const Color(0xFF434463),
          onTabChange: onTabChange,
          tabs: [
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/home.svg',
                height: 24,
                width: 24,
              ),
              text: 'Home',
            ),
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/wallets.svg',
                height: 25,
                width: 25,
              ),
              text: 'Wallets',
            ),
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/calender.svg',
                height: 25,
                width: 25,
              ),
              text: 'Calender',
            ),
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/details.svg',
                height: 25,
                width: 25,
              ),
              text: 'Details',
            ),
          ],
        ),
      ),
    );
  }
}
