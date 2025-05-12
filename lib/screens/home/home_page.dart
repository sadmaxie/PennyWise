import 'package:flutter/material.dart';
import 'package:pennywise/components/app_bar.dart';
import '../../components/wallet_card_switcher.dart';

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
              TopHeader(showBackButton: false, showUserIcon: false),
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
