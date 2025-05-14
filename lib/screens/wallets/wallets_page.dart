import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/app_bar.dart';
import '../../database/wallet_provider.dart';
import '../../models/wallet_card.dart';
import '../../models/wallet_popup.dart';


class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final wallets = walletProvider.wallets;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              const TopHeader(
                showBackButton: false,
                showIconButton: false,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: wallets.isEmpty
                    ? const Center(
                  child: Text(
                    "No wallets yet.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  itemCount: wallets.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return WalletCard(
                      wallet: wallet,
                      index: index,
                      onEdit: () => showWalletPopup(context, wallet, index),
                      onDelete: () {
                        final provider = Provider.of<WalletProvider>(context, listen: false);
                        provider.deleteWallet(index);
                      },
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B3B52),
        onPressed: () => showWalletPopup(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
