import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/crypto_coin.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/crypto_provider.dart';
import 'trading_screen.dart';

class CoinDetailScreen extends StatefulWidget {
  final CryptoCoin coin;

  const CoinDetailScreen({super.key, required this.coin});

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  final List<int> _daysOptions = [1, 7, 30, 90, 180, 365];

  @override
  void initState() {
    super.initState();
    final provider = context.read<CryptoProvider>();
    provider.loadCoinOhlc(coinId: widget.coin.id, days: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title:
            Text('${widget.coin.name} (${widget.coin.symbol.toUpperCase()})'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TradingScreen(coin: widget.coin),
            ),
          );
        },
        icon: const Icon(Icons.swap_vert),
        label: const Text('Trade'),
      ),
      body: Consumer<CryptoProvider>(
        builder: (context, provider, child) {
          final ohlc = provider.selectedCoinOhlc;
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadCoinOhlc(
                coinId: widget.coin.id,
                days: provider.selectedDays,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildTimeframeChips(provider),
                const SizedBox(height: 16),
                SizedBox(
                  height: 320,
                  child: ohlc.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SfCartesianChart(
                          plotAreaBorderWidth: 0,
                          primaryXAxis: DateTimeAxis(
                            majorGridLines: const MajorGridLines(width: 0),
                            axisLine: const AxisLine(width: 0),
                          ),
                          primaryYAxis: NumericAxis(
                            majorGridLines: const MajorGridLines(width: 0.2),
                            opposedPosition: true,
                          ),
                          series: <CandleSeries<_CandlePoint, DateTime>>[
                            CandleSeries<_CandlePoint, DateTime>(
                              dataSource: _mapToCandlePoints(ohlc),
                              xValueMapper: (_CandlePoint p, _) => p.time,
                              lowValueMapper: (_CandlePoint p, _) => p.low,
                              highValueMapper: (_CandlePoint p, _) => p.high,
                              openValueMapper: (_CandlePoint p, _) => p.open,
                              closeValueMapper: (_CandlePoint p, _) => p.close,
                              bearColor: Colors.red,
                              bullColor: Colors.green,
                              enableSolidCandles: true,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CachedNetworkImage(
            imageUrl: widget.coin.image,
            width: 48,
            height: 48,
            placeholder: (context, url) => Container(
              width: 48,
              height: 48,
              color: Colors.grey.withValues(alpha: 0.08),
            ),
            errorWidget: (context, url, error) => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.currency_bitcoin,
                size: 28,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.coin.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.coin.formattedPrice,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTimeframeChips(CryptoProvider provider) {
    return Wrap(
      spacing: 8,
      children: _daysOptions.map((d) {
        final selected = provider.selectedDays == d;
        return ChoiceChip(
          label: Text(d == 365
              ? '1Y'
              : d == 1
                  ? '1D'
                  : '${d}D'),
          selected: selected,
          onSelected: (_) =>
              provider.loadCoinOhlc(coinId: widget.coin.id, days: d),
        );
      }).toList(),
    );
  }

  List<_CandlePoint> _mapToCandlePoints(List<List<num>> raw) {
    return raw.map((e) {
      final ts = e[0].toInt();
      return _CandlePoint(
        time: DateTime.fromMillisecondsSinceEpoch(ts),
        open: (e[1]).toDouble(),
        high: (e[2]).toDouble(),
        low: (e[3]).toDouble(),
        close: (e[4]).toDouble(),
      );
    }).toList();
  }
}

class _CandlePoint {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  const _CandlePoint({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
