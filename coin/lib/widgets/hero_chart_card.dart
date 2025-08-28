import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/crypto_provider.dart';

class HeroChartCard extends StatelessWidget {
  const HeroChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoProvider>(
      builder: (context, provider, child) {
        final prices = provider.heroChartPrices;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _titleForCoin(provider.heroChartCoinId),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    _TimeframeChip(
                      label: '1D',
                      selected: provider.heroChartDays == 1,
                      onTap: () => provider.loadHeroChart(days: 1),
                    ),
                    const SizedBox(width: 6),
                    _TimeframeChip(
                      label: '7D',
                      selected: provider.heroChartDays == 7,
                      onTap: () => provider.loadHeroChart(days: 7),
                    ),
                    const SizedBox(width: 6),
                    _TimeframeChip(
                      label: '30D',
                      selected: provider.heroChartDays == 30,
                      onTap: () => provider.loadHeroChart(days: 30),
                    ),
                    const SizedBox(width: 6),
                    _TimeframeChip(
                      label: '1Y',
                      selected: provider.heroChartDays == 365,
                      onTap: () => provider.loadHeroChart(days: 365),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                 SizedBox(
                  height: 220,
                  child: prices.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _spots(prices),
                                isCurved: true,
                                color: _trendColor(context, prices),
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: _trendColor(context, prices)
                                      .withValues(alpha: 0.12),
                                ),
                              ),
                              ],
                              lineTouchData: LineTouchData(
                                handleBuiltInTouches: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((s) {
                                      return LineTooltipItem(
                                        s.y.toStringAsFixed(2),
                                        const TextStyle(fontWeight: FontWeight.w600),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<FlSpot> _spots(List<double> prices) {
    final result = <FlSpot>[];
    for (int i = 0; i < prices.length; i++) {
      final price = prices[i];
      if (price > 0) {
        result.add(FlSpot(i.toDouble(), price));
      }
    }
    return result;
  }

  static Color _trendColor(BuildContext context, List<double> prices) {
    if (prices.length < 2) return Theme.of(context).colorScheme.primary;
    final isUp = prices.last >= prices.first;
    return isUp ? Colors.green : Colors.red;
  }

  static String _titleForCoin(String coinId) {
    switch (coinId) {
      case 'ethereum':
        return 'Ethereum (ETH)';
      case 'bitcoin':
        return 'Bitcoin (BTC)';
      default:
        return coinId;
    }
  }
}

class _TimeframeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeframeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}


