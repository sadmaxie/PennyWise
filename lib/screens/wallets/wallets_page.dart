import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../navigation/top_header.dart';
import '../../database/wallet_provider.dart';
import '../../widgets/wallet_card.dart';
import 'wallet_form_sheet.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final allWallets = walletProvider.wallets;

    final filteredWallets = _searchQuery.isEmpty
        ? allWallets
        : allWallets
        .where((w) =>
        w.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

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
              const SizedBox(height: 12),

              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search wallet...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF292A3F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              // Wallet List
              Expanded(
                child: filteredWallets.isEmpty
                    ? const Center(
                  child: Text(
                    "No wallets found.",
                    style: TextStyle(color: Colors.white54),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredWallets.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final wallet = filteredWallets[index];
                    final realIndex = allWallets.indexOf(wallet);

                    return WalletCard(
                      wallet: wallet,
                      index: realIndex,
                      onEdit: () => showWalletModalSheet(context, wallet, realIndex),
                      onDelete: () {
                        final provider = Provider.of<WalletProvider>(context, listen: false);
                        provider.deleteWallet(realIndex);
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
        onPressed: () => showWalletModalSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
