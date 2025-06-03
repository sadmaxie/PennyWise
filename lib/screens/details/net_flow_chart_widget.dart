import 'package:flutter/material.dart';

class NetFlowChartWidget extends StatelessWidget {
  final Map<String, double> dataMap;
  final double maxAbsValue;
  final String currencySymbol;
  final bool hasNonZero;

  const NetFlowChartWidget({
    super.key,
    required this.dataMap,
    required this.maxAbsValue,
    required this.currencySymbol,
    required this.hasNonZero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF292A3F),
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
                          child: SizedBox(
                            height: 162,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 20,
                                  child: Text(
                                    '$currencySymbol${entry.value.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: FractionallySizedBox(
                                          heightFactor:
                                              maxAbsValue == 0.0
                                                  ? 0.05
                                                  : (entry.value.abs() /
                                                          maxAbsValue)
                                                      .clamp(0.05, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors:
                                                    entry.value < 0
                                                        ? [
                                                          Colors
                                                              .redAccent
                                                              .shade100,
                                                          const Color(
                                                            0xFFFF5252,
                                                          ),
                                                        ]
                                                        : [
                                                          const Color(
                                                            0xFFB0EBFF,
                                                          ),
                                                          const Color(
                                                            0xFF64ECAC,
                                                          ),
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
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
    );
  }
}
