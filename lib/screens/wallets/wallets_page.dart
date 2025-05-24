/// WalletsPage
/// Displays the list of wallets with optional search/filter and the ability to add/edit/delete wallets.
/// Uses `WalletProvider` for state management and `WalletCard` for UI.
/// Includes a floating action button to add new wallets.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/providers/card_group_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../navigation/top_header.dart';
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
  bool showNormal = true;
  bool showGoals = true;
  bool showIncome = true;

  @override
  Widget build(BuildContext context) {
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final currentCard = cardGroupProvider.selectedCardGroup;

    if (currentCard == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2D2D49),
        body: Center(
          child: Text(
            "Please create a card group first.",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final walletProvider = Provider.of<WalletProvider>(context);
    final allWallets =
        walletProvider.wallets
            .where((w) => w.cardGroupId == currentCard.id)
            .toList();

    final filteredWallets =
        allWallets.where((w) {
          final matchesSearch = w.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

          final isIncome = w.incomePercent != null && w.incomePercent! > 0;
          final isGoal = w.isGoal;
          final isNormal = !isGoal && !isIncome;

          final matchesType =
              (showNormal && isNormal) ||
              (showGoals && isGoal) ||
              (showIncome && isIncome);

          return matchesSearch && matchesType;
        }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              const TopHeader(showBackButton: false, showIconButton: false),
              const SizedBox(height: 12),
              _buildSearchBar(),
              const SizedBox(height: 20),
              Expanded(child: _buildWalletList(filteredWallets, allWallets)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF434462),
        onPressed: () => showWalletModalSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
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
              suffixIcon:
                  _searchQuery.isNotEmpty
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
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _showFilterDialog,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF292A3F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D3F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    value: showNormal,
                    onChanged:
                        (val) => setModalState(() {
                          showNormal = val;
                          setState(() {});
                        }),
                    title: const Text(
                      "Show Normal Wallets",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: showGoals,
                    onChanged:
                        (val) => setModalState(() {
                          showGoals = val;
                          setState(() {});
                        }),
                    title: const Text(
                      "Show Goal Wallets",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SwitchListTile.adaptive(
                    value: showIncome,
                    onChanged:
                        (val) => setModalState(() {
                          showIncome = val;
                          setState(() {});
                        }),
                    title: const Text(
                      "Show Income Wallets",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWalletList(List filteredWallets, List allWallets) {
    if (filteredWallets.isEmpty) {
      return const Center(
        child: Text(
          "No wallets found.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredWallets.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final wallet = filteredWallets[index];
        final realIndex = allWallets.indexOf(wallet);

        return WalletCard(
          wallet: wallet,
          onEdit: () => showWalletModalSheet(context, wallet),
          onDelete: () {
            final provider = Provider.of<WalletProvider>(
              context,
              listen: false,
            );
            if (wallet.isInBox) {
              provider.deleteWalletByKey(wallet.key);
            }
          },
        );
      },
    );
  }
}
