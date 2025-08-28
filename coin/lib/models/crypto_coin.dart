class CryptoCoin {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double marketCapChange24h;
  final double marketCapChangePercentage24h;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double ath;
  final double athChangePercentage;
  final String athDate;
  final double atl;
  final double atlChangePercentage;
  final String atlDate;
  final String lastUpdated;
  final List<double> sparklineIn7d;
  final double priceChangePercentage1hInCurrency;
  final double priceChangePercentage24hInCurrency;
  final double priceChangePercentage7dInCurrency;

  CryptoCoin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCapChange24h,
    required this.marketCapChangePercentage24h,
    required this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    required this.atlDate,
    required this.lastUpdated,
    required this.sparklineIn7d,
    required this.priceChangePercentage1hInCurrency,
    required this.priceChangePercentage24hInCurrency,
    required this.priceChangePercentage7dInCurrency,
  });

  factory CryptoCoin.fromJson(Map<String, dynamic> json) {
    return CryptoCoin(
      id: json['id'] ?? '',
      symbol: json['symbol']?.toUpperCase() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      totalVolume: (json['total_volume'] ?? 0.0).toDouble(),
      high24h: (json['high_24h'] ?? 0.0).toDouble(),
      low24h: (json['low_24h'] ?? 0.0).toDouble(),
      priceChange24h: (json['price_change_24h'] ?? 0.0).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] ?? 0.0).toDouble(),
      marketCapChange24h: (json['market_cap_change_24h'] ?? 0.0).toDouble(),
      marketCapChangePercentage24h:
          (json['market_cap_change_percentage_24h'] ?? 0.0).toDouble(),
      circulatingSupply: (json['circulating_supply'] ?? 0.0).toDouble(),
      totalSupply: json['total_supply'] != null
          ? (json['total_supply'] as num).toDouble()
          : null,
      maxSupply: json['max_supply'] != null
          ? (json['max_supply'] as num).toDouble()
          : null,
      ath: (json['ath'] ?? 0.0).toDouble(),
      athChangePercentage: (json['ath_change_percentage'] ?? 0.0).toDouble(),
      athDate: json['ath_date'] ?? '',
      atl: (json['atl'] ?? 0.0).toDouble(),
      atlChangePercentage: (json['atl_change_percentage'] ?? 0.0).toDouble(),
      atlDate: json['atl_date'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      sparklineIn7d: json['sparkline_in_7d']?['price'] != null
          ? List<double>.from(json['sparkline_in_7d']['price']
              .map((x) => (x ?? 0.0).toDouble()))
          : [],
      priceChangePercentage1hInCurrency:
          (json['price_change_percentage_1h_in_currency'] ?? 0.0).toDouble(),
      priceChangePercentage24hInCurrency:
          (json['price_change_percentage_24h_in_currency'] ?? 0.0).toDouble(),
      priceChangePercentage7dInCurrency:
          (json['price_change_percentage_7d_in_currency'] ?? 0.0).toDouble(),
    );
  }

  // Utility getters
  bool get isPositive => priceChangePercentage24h >= 0;

  String get formattedPrice => '\$${currentPrice.toStringAsFixed(2)}';

  String get formattedPriceChange =>
      '${isPositive ? '+' : ''}${priceChangePercentage24h.toStringAsFixed(2)}%';

  String get formattedMarketCap => _formatLargeNumber(marketCap);

  String get formattedVolume => _formatLargeNumber(totalVolume);

  String _formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '\$${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return '\$${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '\$${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '\$${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return '\$${number.toStringAsFixed(2)}';
    }
  }
}
