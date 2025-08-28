import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/crypto_coin.dart';

class CryptoApiService {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Default headers. CoinGecko supports a public demo key which helps avoid some rate limits.
  static const Map<String, String> _defaultHeaders = {
    'accept': 'application/json',
    'user-agent': 'CoinCharger/1.0 (+flutter)'
  };

  // Some environments require the demo key to avoid empty responses/429s.
  // If you have a real key, replace 'demo' below and keep the same header name.
  static const String _demoKey = 'demo';

  Future<http.Response> _get(Uri uri) {
    final headers = {
      ..._defaultHeaders,
      'x-cg-demo-api-key': _demoKey,
    };
    return http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
  }

  // Get top cryptocurrencies by market cap
  Future<List<CryptoCoin>> getTopCryptocurrencies({int perPage = 100}) async {
    try {
      final response = await _get(Uri.parse(
          '$baseUrl/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=$perPage&page=1&sparkline=true&price_change_percentage=1h,24h,7d'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CryptoCoin.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load cryptocurrencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cryptocurrencies: $e');
    }
  }

  // Get detailed information about a specific cryptocurrency
  Future<CryptoCoin> getCryptocurrencyDetails(String id) async {
    try {
      final response = await _get(Uri.parse(
          '$baseUrl/coins/$id?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=true'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CryptoCoin.fromJson(data);
      } else {
        throw Exception(
            'Failed to load cryptocurrency details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cryptocurrency details: $e');
    }
  }

  // Search cryptocurrencies
  Future<List<CryptoCoin>> searchCryptocurrencies(String query) async {
    try {
      final response = await _get(Uri.parse('$baseUrl/search?query=$query'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> coins = data['coins'] ?? [];

        // Get detailed data for searched coins (parallelized, top 10)
        final ids = coins.take(10).map<String>((c) => c['id'] as String).toList();
        final futures = ids.map((id) => getCryptocurrencyDetails(id)).toList();
        final results = await Future.wait<CryptoCoin>(
          futures,
          eagerError: false,
        );
        return results;
      } else {
        throw Exception(
            'Failed to search cryptocurrencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching cryptocurrencies: $e');
    }
  }

  // Get trending cryptocurrencies
  Future<List<CryptoCoin>> getTrendingCryptocurrencies() async {
    try {
      final response = await _get(Uri.parse('$baseUrl/search/trending'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> trendingCoins = data['coins'] ?? [];

        // Get detailed data for trending coins (parallelized)
        final ids = trendingCoins
            .map<String>((tc) => (tc['item'] as Map<String, dynamic>)['id'] as String)
            .toList();
        final futures = ids.map((id) => getCryptocurrencyDetails(id)).toList();
        final results = await Future.wait<CryptoCoin>(
          futures,
          eagerError: false,
        );
        return results;
      } else {
        throw Exception(
            'Failed to load trending cryptocurrencies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching trending cryptocurrencies: $e');
    }
  }

  // Get global market overview
  Future<Map<String, dynamic>> getMarketOverview() async {
    try {
      final response = await _get(Uri.parse('$baseUrl/global'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception(
            'Failed to load market overview: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching market overview: $e');
    }
  }

  // Get historical market chart prices for a coin
  // Returns a list of prices only (timestamps omitted) for simple sparkline/line charts
  Future<List<double>> getMarketChartPrices(
    String id, {
    String vsCurrency = 'usd',
    int days = 7,
    String interval = 'hourly',
  }) async {
    try {
      final response = await _get(Uri.parse(
          '$baseUrl/coins/$id/market_chart?vs_currency=$vsCurrency&days=$days&interval=$interval'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> prices = data['prices'] ?? [];
        // Each entry is [timestamp, price]
        final List<double> onlyPrices = prices
            .whereType<List>()
            .map<double>((entry) => (entry[1] ?? 0.0).toDouble())
            .toList();
        return onlyPrices;
      } else {
        throw Exception(
            'Failed to load market chart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching market chart: $e');
    }
  }

  // Get OHLC data for candlestick charts
  // API returns [[timestamp, open, high, low, close], ...]
  Future<List<List<num>>> getOhlc(
    String id, {
      String vsCurrency = 'usd',
      int days = 7,
  }) async {
    try {
      final response = await _get(Uri.parse(
        '$baseUrl/coins/$id/ohlc?vs_currency=$vsCurrency&days=$days',
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .whereType<List>()
            .map<List<num>>((entry) => [
                  (entry[0] ?? 0) as num,
                  (entry[1] ?? 0).toDouble(),
                  (entry[2] ?? 0).toDouble(),
                  (entry[3] ?? 0).toDouble(),
                  (entry[4] ?? 0).toDouble(),
                ])
            .toList();
      } else {
        throw Exception('Failed to load OHLC: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching OHLC: $e');
    }
  }
}
