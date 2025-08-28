import 'package:flutter/foundation.dart';
import '../models/crypto_coin.dart';
import '../services/crypto_api_service.dart';

class CryptoProvider extends ChangeNotifier {
  final CryptoApiService _apiService = CryptoApiService();

  // Data lists
  List<CryptoCoin> _cryptocurrencies = [];
  List<CryptoCoin> _trendingCryptocurrencies = [];
  List<CryptoCoin> _searchResults = [];
  CryptoCoin? _selectedCryptocurrency;
  Map<String, dynamic> _marketOverview = {};

  // Chart state
  List<double> _heroChartPrices = [];
  String _heroChartCoinId = 'bitcoin';
  int _heroChartDays = 7; // 1,7,30,90,180,365, max
  // Cache: coinId -> days -> OHLC list
  final Map<String, Map<int, List<List<num>>>> _coinOhlcCache = {};
  String _selectedCoinForDetails = '';
  int _selectedCoinDays = 7;

  // State flags
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  // Getters
  List<CryptoCoin> get cryptocurrencies => _cryptocurrencies;
  List<CryptoCoin> get trendingCryptocurrencies => _trendingCryptocurrencies;
  List<CryptoCoin> get searchResults => _searchResults;
  CryptoCoin? get selectedCryptocurrency => _selectedCryptocurrency;
  Map<String, dynamic> get marketOverview => _marketOverview;
  List<double> get heroChartPrices => _heroChartPrices;
  String get heroChartCoinId => _heroChartCoinId;
  int get heroChartDays => _heroChartDays;
  List<List<num>> get selectedCoinOhlc =>
      _coinOhlcCache[_selectedCoinForDetails]?[_selectedCoinDays] ?? [];
  String get selectedCoinId => _selectedCoinForDetails;
  int get selectedDays => _selectedCoinDays;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  // Get top gainers and losers
  List<CryptoCoin> get getTopGainers {
    final sorted = List<CryptoCoin>.from(_cryptocurrencies);
    sorted.sort((a, b) =>
        b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    return sorted.take(5).toList();
  }

  List<CryptoCoin> get getTopLosers {
    final sorted = List<CryptoCoin>.from(_cryptocurrencies);
    sorted.sort((a, b) =>
        a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
    return sorted.take(5).toList();
  }

  // Initialize app data
  Future<void> initializeApp() async {
    await Future.wait([
      loadTopCryptocurrencies(),
      loadTrendingCryptocurrencies(),
      loadMarketOverview(),
    ]);
    // Load initial hero chart after lists ready (default bitcoin, 7d)
    await loadHeroChart();
  }

  // Load top cryptocurrencies
  Future<void> loadTopCryptocurrencies() async {
    try {
      _setLoading(true);
      _error = null;

      final coins = await _apiService.getTopCryptocurrencies(perPage: 100);
      _cryptocurrencies = coins;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load hero chart data
  Future<void> loadHeroChart({String? coinId, int? days}) async {
    try {
      if (coinId != null) _heroChartCoinId = coinId;
      if (days != null) _heroChartDays = days;
      final prices = await _apiService.getMarketChartPrices(
        _heroChartCoinId,
        days: _heroChartDays,
        vsCurrency: 'usd',
        interval: _heroChartDays <= 1 ? 'minutely' : 'hourly',
      );
      _heroChartPrices = prices;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading hero chart: $e');
    }
  }

  // Load per-coin OHLC data with simple in-memory caching
  Future<void> loadCoinOhlc({required String coinId, int? days}) async {
    try {
      if (days != null) _selectedCoinDays = days;
      _selectedCoinForDetails = coinId;
      // Serve from cache if present
      final cached = _coinOhlcCache[coinId]?[_selectedCoinDays];
      if (cached != null) {
        notifyListeners();
        return;
      }

      final data = await _apiService.getOhlc(
        coinId,
        days: _selectedCoinDays,
        vsCurrency: 'usd',
      );
      _coinOhlcCache.putIfAbsent(coinId, () => {});
      _coinOhlcCache[coinId]![_selectedCoinDays] = data;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading OHLC: $e');
    }
  }

  // Load trending cryptocurrencies
  Future<void> loadTrendingCryptocurrencies() async {
    try {
      final trending = await _apiService.getTrendingCryptocurrencies();
      _trendingCryptocurrencies = trending;
      notifyListeners();
    } catch (e) {
      // Don't set error for trending as it's not critical
      debugPrint('Error loading trending: $e');
    }
  }

  // Load market overview
  Future<void> loadMarketOverview() async {
    try {
      final overview = await _apiService.getMarketOverview();
      _marketOverview = overview;
      notifyListeners();
    } catch (e) {
      // Don't set error for market overview as it's not critical
      debugPrint('Error loading market overview: $e');
    }
  }

  // Search cryptocurrencies
  Future<void> searchCryptocurrencies(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    try {
      _setSearching(true);
      _error = null;

      final results = await _apiService.searchCryptocurrencies(query);
      _searchResults = results;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setSearching(false);
    }
  }

  // Select a cryptocurrency
  void selectCryptocurrency(CryptoCoin coin) {
    _selectedCryptocurrency = coin;
    notifyListeners();
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshData() async {
    await initializeApp();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
