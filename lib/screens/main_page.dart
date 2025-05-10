import 'package:flutter/material.dart';
// screens
import 'package:pennywise/screens/calendar/calendar_page.dart';
import 'package:pennywise/screens/details/details_page.dart';
import 'package:pennywise/screens/home/home_page.dart';
import 'package:pennywise/screens/wallets/wallets_page.dart';
// components
import 'package:pennywise/components/bottom_nav_bar.dart';





class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // this selected index is to control the bottom nav bar
  int _selectedIndex = 0;

  //this method will update our selected index
  // when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // pages to display
  final List<Widget> _pages = [
    // shop page
    const HomePage(),

    // wallets page
    const WalletsPage(),

    // calender page
    const CalendarPage(),

    // details page
    const DetailsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F13),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }
}