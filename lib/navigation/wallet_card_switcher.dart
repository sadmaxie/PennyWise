/// A switcher widget to toggle between "My Wallet" and "My Cards" views.
///
/// - Displays two toggle buttons in a pill-style container.
/// - Switches between `MyWalletView` and `MyCardView` based on selection.

import 'package:flutter/material.dart';
import '../screens/home/my_card_view.dart';
import '../screens/home/my_wallet_view.dart';

class WalletCardSwitcher extends StatefulWidget {
  const WalletCardSwitcher({super.key});

  @override
  State<WalletCardSwitcher> createState() => _WalletCardSwitcherState();
}

class _WalletCardSwitcherState extends State<WalletCardSwitcher> {
  int _selectedIndex = 0;

  // Allow switching tabs from children
  void switchToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildTabSwitcher(),
        const SizedBox(height: 20),
        Expanded(
          child:
              _selectedIndex == 0
                  ? const MyWalletView()
                  : MyCardView(onCardSelected: () => switchToTab(0)),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 70,
      width: double.infinity,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF292A3F),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment:
                _selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 22,
              decoration: BoxDecoration(
                color: const Color(0xFF3B3B52),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              _buildTabButton("My Wallet", 0),
              _buildTabButton("My Cards", 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
