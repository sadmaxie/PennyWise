import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/models/wallet.dart';
import '../../database/providers/card_group_provider.dart';
import '../../database/providers/details_provider.dart';
import '../../database/providers/user_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../navigation/top_header.dart';
import '../../utils/currency_symbols.dart';
import '../../widgets/wallet_analytics_tile.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Wallet? selectedWallet;
  DateRange selectedRange = DateRange.thisWeek;

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final cardGroupProvider = Provider.of<CardGroupProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final detailsProvider = Provider.of<DetailsProvider>(context);

    final currentGroup = cardGroupProvider.selectedCardGroup;
    final currencyCode = userProvider.user?.currencyCode ?? 'USD';
    final currencySymbol = currencySymbols[currencyCode] ?? currencyCode;

    final dataMap = detailsProvider.aggregateNetFlowData(
      walletProvider.wallets,
      currentGroup?.id ?? '',
    );

    final hasNonZero = dataMap.values.any((v) => v != 0);
    final maxAbsValue =
    hasNonZero
        ? dataMap.values.map((v) => v.abs()).reduce((a, b) => a > b ? a : b)
        : 1.0;

    final incomeWallets = detailsProvider.getTopWalletsByNetPositive(
      walletProvider.wallets,
      currentGroup?.id ?? '',
    );

    final lossWallets = detailsProvider.getTopLossWalletsByNet(
      walletProvider.wallets,
      currentGroup?.id ?? '',
    );

    final walletTxs = selectedWallet?.history ?? [];
    final filteredTxs = detailsProvider.filterTransactionsByDateRange(walletTxs, selectedRange);

    final totalIncome = filteredTxs.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filteredTxs.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D49),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopHeader(showBackButton: false, showIconButton: false),
              const SizedBox(height: 20),
              _buildDateRangeSelector(context),
              const SizedBox(height: 20),
              _buildNetFlowChart(dataMap, maxAbsValue, currencySymbol, hasNonZero),
              const SizedBox(height: 24),
              const Text(
                'Top  Positive Wallets',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _walletTileListOrPlaceholder(incomeWallets, currencySymbol, isIncome: true),
              const SizedBox(height: 24),
              const Text(
                'Most Negative Wallets',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _walletTileListOrPlaceholder(lossWallets, currencySymbol, isIncome: false),
              const SizedBox(height: 24),
              const Text(
                'Wallet Analytics',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButton<Wallet>(
                value: selectedWallet,
                dropdownColor: const Color(0xFF292A3F),
                hint: const Text('Select a wallet', style: TextStyle(color: Colors.white70)),
                isExpanded: true,
                items: walletProvider.wallets.map((wallet) {
                  return DropdownMenuItem(
                    value: wallet,
                    child: Text(wallet.name, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (wallet) {
                  setState(() => selectedWallet = wallet);
                },
              ),
              const SizedBox(height: 12),
              _buildDateRangeSelector(context, isForWallet: true),
              const SizedBox(height: 16),
              if (selectedWallet != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF292A3F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income: $currencySymbol${totalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Spending: $currencySymbol${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context, {bool isForWallet = false}) {
    final ranges = {
      'This Week': DateRange.thisWeek,
      'Last Week': DateRange.lastWeek,
      'This Month': DateRange.thisMonth,
      'Last Month': DateRange.lastMonth,
      'Last Year': DateRange.lastYear,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ranges.entries.map((entry) {
          final isSelected = selectedRange == entry.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedRange = entry.value;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF434462) : const Color(0xFF292A3F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNetFlowChart(
      Map<String, double> dataMap,
      double maxAbsValue,
      String currencySymbol,
      bool hasNonZero,
      ) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF292A3F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: !hasNonZero
          ? const Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: Colors.white54),
        ),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: dataMap.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 162,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Text(
                        '$currencySymbol${entry.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 90,
                      width: 15,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: maxAbsValue == 0.0
                                  ? 0.05
                                  : (entry.value.abs() / maxAbsValue).clamp(0.05, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: entry.value < 0
                                        ? [
                                      Colors.redAccent.shade100,
                                      const Color(0xFFFF5252),
                                    ]
                                        : [
                                      const Color(0xFFB0EBFF),
                                      const Color(0xFF64ECAC),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 28,
                      width: 40,
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _walletTileListOrPlaceholder(
      List<MapEntry<Wallet, double>> entries,
      String currencySymbol, {
        required bool isIncome,
      }) {
    if (entries.isEmpty) {
      return const Text(
        'No wallets to show',
        style: TextStyle(color: Colors.white38),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length.clamp(0, 3),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return WalletAnalyticsTile(
            wallet: entry.key,
            amount: entry.value.abs(),
            currencySymbol: currencySymbol,
            isIncome: isIncome,
          );
        },
      ),
    );
  }
}
