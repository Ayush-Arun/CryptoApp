import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/crypto_coin.dart';
import '../services/trading_service.dart';

class TradingProvider extends ChangeNotifier {
  final TradingService _tradingService = TradingService();

  // State variables
  bool _isLoading = false;
  String? _error;
  Transaction? _lastTransaction;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Transaction? get lastTransaction => _lastTransaction;
  double get usdBalance => _tradingService.usdBalance;
  Map<String, double> get coinHoldings => _tradingService.coinHoldings;
  List<Transaction> get transactions => _tradingService.transactions;

  // Get total portfolio value
  double getTotalPortfolioValue(List<CryptoCoin> coins) {
    return _tradingService.getTotalPortfolioValue(coins);
  }

  // Get coin holding details
  double getCoinHolding(String coinId) {
    return _tradingService.getCoinHolding(coinId);
  }

  // Get coin holding value
  double getCoinHoldingValue(String coinId, double currentPrice) {
    return _tradingService.getCoinHoldingValue(coinId, currentPrice);
  }

  // Buy cryptocurrency
  Future<bool> buyCrypto({
    required CryptoCoin coin,
    required double amount,
    required double price,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = await _tradingService.buyCrypto(
        coin: coin,
        amount: amount,
        price: price,
      );

      _lastTransaction = transaction;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sell cryptocurrency
  Future<bool> sellCrypto({
    required CryptoCoin coin,
    required double amount,
    required double price,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final transaction = await _tradingService.sellCrypto(
        coin: coin,
        amount: amount,
        price: price,
      );

      _lastTransaction = transaction;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Get transaction history with optional filtering
  List<Transaction> getTransactionHistory({
    String? coinId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _tradingService.getTransactionHistory(
      coinId: coinId,
      type: type,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Clear last transaction
  void clearLastTransaction() {
    _lastTransaction = null;
    notifyListeners();
  }

  // Reset demo data
  void resetDemoData() {
    _tradingService.resetDemoData();
    _lastTransaction = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}
