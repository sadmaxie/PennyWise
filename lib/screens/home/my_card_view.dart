/// MyCardView
/// Displays a scrollable list of "card groups" used to categorize wallets.
/// Each card shows:
/// - Total balance of associated wallets
/// - Optional background image and color
/// - Actions: select (double-tap), edit, or delete
///
/// Allows creating and editing card groups using bottom sheets.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/models/card_group.dart';
import '../../database/providers/card_group_provider.dart';
import '../../database/providers/user_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../utils/currency_symbols.dart';
import '../../wallet/card_create_sheet.dart';

class MyCardView extends StatefulWidget {
  final VoidCallback? onCardSelected;

  const MyCardView({super.key, this.onCardSelected});

  @override
  State<MyCardView> createState() => _MyCardViewState();
}

class _MyCardViewState extends State<MyCardView> {
  bool _isTotalVisible = true;

  bool _isVisibilityLoaded = false;

  Map<String, bool> _cardVisibility = {};

  @override
  void initState() {
    super.initState();
    _loadTotalVisibility();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cardGroups = Provider.of<CardGroupProvider>(context).cardGroups;
    if (_cardVisibility.isEmpty && cardGroups.isNotEmpty) {
      _loadCardVisibilityPrefs(cardGroups);
    }
  }

  Future<void> _loadTotalVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTotalVisible = prefs.getBool('total_visibility') ?? true;
    });
  }

  Future<void> _toggleTotalVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !_isTotalVisible;
    await prefs.setBool('total_visibility', newValue);
    setState(() {
      _isTotalVisible = newValue;
    });
  }

  Future<void> _loadCardVisibilityPrefs(List<CardGroup> cards) async {
    final prefs = await SharedPreferences.getInstance();
    final visMap = <String, bool>{};

    for (final card in cards) {
      final key = 'card_visibility_${card.id}';
      visMap[card.id] = prefs.getBool(key) ?? true;
    }

    setState(() {
      _cardVisibility = visMap;
      _isVisibilityLoaded = true; // ✅ Only render once done
    });
  }

  void _toggleCardVisibility(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !(_cardVisibility[cardId] ?? true);
    await prefs.setBool('card_visibility_$cardId', newValue);

    setState(() {
      _cardVisibility[cardId] = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardGroupProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final cardGroups = cardProvider.cardGroups;
    final selectedId = cardProvider.selectedCardGroup?.id;

    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final totalAllAmount = cardGroups.fold(0.0, (sum, card) {
      final wallets = walletProvider.chartItemsForCardGroup(card.id);
      return sum + wallets.fold(0.0, (s, item) => s + item.amount);
    });

    if (!_isVisibilityLoaded && cardGroups.isNotEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white54,
        ),
      );
    }


    return Scaffold(
      backgroundColor: const Color(0xFF2D2D49),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Double tap row + total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_outlined, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                const Text(
                  "Double tap a card to select it",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleTotalVisibility,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Icon(
                      _isTotalVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      key: ValueKey<bool>(_isTotalVisible),
                      color: Colors.white60,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Total Money:",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: SizedBox(
                    width: 100,
                    key: ValueKey<bool>(_isTotalVisible),
                    child: Text(
                      _isTotalVisible
                          ? "$currencySymbol${totalAllAmount.toStringAsFixed(2)}"
                          : "••••••",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cardGroups.isEmpty
                  ? const Center(
                child: Text(
                  'Create your first card',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: cardGroups.length,
                itemBuilder: (context, index) {
                  final card = cardGroups[index];
                  final isSelected = card.id == selectedId;
                  final isCardVisible = _cardVisibility[card.id] ?? true;
                  return _buildCardItem(
                    context,
                    card,
                    isSelected,
                    isCardVisible,
                    walletProvider,
                    currencySymbol,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF434462),
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCardItem(
      BuildContext context,
      CardGroup card,
      bool isSelected,
      bool isVisible,
      WalletProvider walletProvider,
      String symbol,
      ) {
    final imageFile = card.imagePath != null ? File(card.imagePath!) : null;
    final hasImage = imageFile != null && imageFile.existsSync();

    final chartItems = walletProvider.chartItemsForCardGroup(card.id);
    final totalAmount = chartItems.fold(0.0, (sum, item) => sum + item.amount);

    return GestureDetector(
      onDoubleTap: () {
        Provider.of<CardGroupProvider>(context, listen: false).selectCardGroup(card);
        widget.onCardSelected?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 160,
        decoration: BoxDecoration(
          color: Color(int.parse(card.colorHex.replaceFirst('#', '0x'))),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
          image: hasImage
              ? DecorationImage(
            image: FileImage(imageFile!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          )
              : null,
        ),
        child: Stack(
          children: [
            // Shine effect
            Positioned(
              left: 60,
              top: 20,
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  width: 80,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: SizedBox(
                      width: 120, // Adjust if your values are longer
                      key: ValueKey<bool>(isVisible),
                      child: Text(
                        isVisible
                            ? "$symbol${totalAmount.toStringAsFixed(2)}"
                            : "••••••",
                        textAlign: TextAlign.left, // or center if you prefer
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    card.id.replaceAll("-", " ").substring(0, 19),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Action icons
            Positioned(
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleCardVisibility(card.id),
                    child: Icon(
                      isVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showEditSheet(context, card),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showConfirmDeleteDialog(
                      context,
                      card,
                      Provider.of<CardGroupProvider>(context, listen: false),
                      Provider.of<WalletProvider>(context, listen: false),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.wallet_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CardCreateSheet(),
    );
  }

  void _showEditSheet(BuildContext context, CardGroup card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardCreateSheet(existingCard: card),
    );
  }

  void _showConfirmDeleteDialog(
      BuildContext context,
      CardGroup card,
      CardGroupProvider cardProvider,
      WalletProvider walletProvider,
      ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D3F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Delete Card?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This will delete the card and all wallets inside it. Are you sure?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final walletsToDelete = walletProvider.wallets
                  .where((w) => w.cardGroupId == card.id)
                  .toList();
              for (var wallet in walletsToDelete) {
                walletProvider.deleteWallet(wallet.key);
              }

              cardProvider.deleteCardGroup(card.id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
