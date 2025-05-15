import 'package:flutter/material.dart';
import 'package:pennywise/navigation/top_header.dart';
import '../../navigation/wallet_card_switcher.dart';
import '../user/user_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: const [
              TopHeader(
                showBackButton: false,
                showIconButton: true,
                icon: Icons.person,
                targetPage: UserPage(),
              ),

              Expanded(
                child: WalletCardSwitcher(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
