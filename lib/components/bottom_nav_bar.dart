import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  void Function(int)? onTabChange;

  BottomNavBar({
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
          tabBackgroundColor: Color(0xFF434463),
          onTabChange: (value) => onTabChange!(value),
          tabs: [
            // home button
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/home.svg',
                height: 24,
                width: 24,
              ),
              text: 'Home',
            ),

            // wallets button
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/wallets.svg',
                height: 25,
                width: 25,
              ),
              text: 'Wallets',
            ),

            // calender button
            GButton(
              icon: Icons.circle,
              leading: SvgPicture.asset(
                'assets/icons/calender.svg',
                height: 25,
                width: 25,
              ),
              text: 'Calender',
            ),

            // details button
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
