import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/providers/details_provider.dart';
import '../../database/providers/wallet_provider.dart';
import '../../database/providers/card_group_provider.dart';
import '../../database/providers/user_provider.dart';
import '../../navigation/top_header.dart';
import '../../utils/currency_symbols.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFF2D2D49),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopHeader(showBackButton: false, showIconButton: false),
              const SizedBox(height: 20),
              _buildDateRangeSelector(context),
              const SizedBox(height: 20),
              _buildNetFlowChart(
                dataMap,
                maxAbsValue,
                currencySymbol,
                hasNonZero,
              ),
              const SizedBox(height: 24),
              const Text(
                'More analytics coming soon...',
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRangeButton(context, "This Week", DateRange.thisWeek),
          _buildRangeButton(context, "Last Week", DateRange.lastWeek),
          _buildRangeButton(context, "This Month", DateRange.thisMonth),
          _buildRangeButton(context, "Last Month", DateRange.lastMonth),
          _buildRangeButton(context, "Last Year", DateRange.lastYear),
        ],
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
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A27),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child:
          !hasNonZero
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
                  children:
                      dataMap.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              const barMaxHeight = 92.0;
                              const spacing = 2.0;
                              const labelHeight = 12.0;

                              final isNegative = entry.value < 0;
                              final heightFactor = (entry.value.abs() /
                                      maxAbsValue)
                                  .clamp(0.05, 1.0);
                              final clampedBarHeight =
                                  barMaxHeight * heightFactor;

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: labelHeight,
                                    child: Text(
                                      '$currencySymbol${entry.value.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: spacing),
                                  SizedBox(
                                    height: barMaxHeight,
                                    width: 20,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: clampedBarHeight,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors:
                                                    isNegative
                                                        ? [
                                                          Colors
                                                              .redAccent
                                                              .shade100,
                                                          Colors.red.shade400,
                                                        ]
                                                        : [
                                                          const Color(
                                                            0xFFB0EBFF,
                                                          ),
                                                          const Color(
                                                            0xFF3FE7CA,
                                                          ),
                                                        ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: spacing),
                                  SizedBox(
                                    height: labelHeight,
                                    width: 40,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }

  Widget _buildRangeButton(
    BuildContext context,
    String label,
    DateRange range,
  ) {
    final provider = Provider.of<DetailsProvider>(context);
    final isSelected = provider.selectedRange == range;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => provider.setRange(range),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF3FE7CA) : const Color(0xFF292A3F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF101014) : Colors.white70,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
