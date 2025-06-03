import 'package:flutter/material.dart';
import 'package:pennywise/screens/details/wallet_detail_insight.dart';
import 'package:provider/provider.dart';

import '../../database/models/wallet.dart';
import '../../database/providers/card_group_provider.dart';
import '../../database/providers/details_provider.dart';
import '../../database/providers/user_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../navigation/top_header.dart';
import '../../utils/currency_symbols.dart';
import '../../widgets/wallet_analytics_tile.dart';
import 'net_flow_chart_widget.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

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
              NetFlowChartWidget(
                dataMap: dataMap,
                maxAbsValue: maxAbsValue,
                currencySymbol: currencySymbol,
                hasNonZero: hasNonZero,
              ),
              const SizedBox(height: 24),
              const Text(
                'Top  Positive Wallets',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _walletTileListOrPlaceholder(
                incomeWallets,
                currencySymbol,
                isIncome: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Most Negative Wallets',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              _walletTileListOrPlaceholder(
                lossWallets,
                currencySymbol,
                isIncome: false,
              ),
              const SizedBox(height: 12),
              const WalletDetailInsight(),
              const Text(
                'More analytics coming soon..',
                style: TextStyle(color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    final provider = Provider.of<DetailsProvider>(context);
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
        children:
            ranges.entries.map((entry) {
              final isSelected = provider.selectedRange == entry.value;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => provider.setRange(entry.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF434462)
                              : const Color(0xFF292A3F),
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
