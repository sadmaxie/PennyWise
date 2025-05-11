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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
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
                alignment: _selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Container(
                  width: MediaQuery.of(context).size.width / 2 - 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF434463),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton("My Wallet", 0),
                  _buildTabButton("My Cards", 1),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 🔁 Dynamic tab content
        _selectedIndex == 0
            ? const MyWalletView()
            : const MyCardView(),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedIndex = index;
        }),
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
