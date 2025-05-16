/// MainPage
/// The root screen that controls bottom navigation between:
/// - HomePage
/// - WalletsPage
/// - CalendarPage
/// - DetailsPage
///
/// Uses `BottomNavBar` to switch between pages.
/// Controlled by `_selectedIndex`.

import 'package:flutter/material.dart';

// Screens
import 'package:pennywise/screens/home/home_page.dart';
import 'package:pennywise/screens/wallets/wallets_page.dart';
import 'package:pennywise/screens/calendar/calendar_page.dart';
import 'package:pennywise/screens/details/details_page.dart';

// Components
import 'package:pennywise/navigation/bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Updates the selected index for navigation
  void navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);
  }

  // Pages corresponding to bottom navigation
  final List<Widget> _pages = [
    const HomePage(),
    const WalletsPage(),
    const CalendarPage(),
    const DetailsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F13),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(onTabChange: navigateBottomBar),
    );
  }
}
