import 'dart:math';
import '../models/transaction.dart';
import '../models/crypto_coin.dart';

class TradingService {
  static final TradingService _instance = TradingService._internal();
  factory TradingService() => _instance;
  TradingService._internal();

  // Simulated user balance (in USD)
  double _usdBalance = 10000.0;

  // Simulated coin holdings
  final Map<String, double> _coinHoldings = {};

  // Transaction history
  final List<Transaction> _transactions = [];

  // Getters
  double get usdBalance => _usdBalance;
  Map<String, double> get coinHoldings => Map.unmodifiable(_coinHoldings);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  // Get total portfolio value
  double getTotalPortfolioValue(List<CryptoCoin> coins) {
    double totalValue = _usdBalance;

    for (var entry in _coinHoldings.entries) {
      final coin = coins.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => CryptoCoin(
          id: entry.key,
          symbol: 'UNKNOWN',
          name: 'Unknown Coin',
          image: '',
          currentPrice: 0,
          marketCap: 0,
          marketCapRank: 0,
          totalVolume: 0,
          high24h: 0,
          low24h: 0,
          priceChange24h: 0,
          priceChangePercentage24h: 0,
          marketCapChange24h: 0,
          marketCapChangePercentage24h: 0,
          circulatingSupply: 0,
          totalSupply: 0,
          maxSupply: 0,
          ath: 0,
          athChangePercentage: 0,
          athDate: '',
          atl: 0,
          atlChangePercentage: 0,
          atlDate: '',
          lastUpdated: '',
          sparklineIn7d: [],
          priceChangePercentage1hInCurrency: 0,
          priceChangePercentage24hInCurrency: 0,
          priceChangePercentage7dInCurrency: 0,
        ),
      );
      totalValue += entry.value * coin.currentPrice;
    }

    return totalValue;
  }

  // Buy cryptocurrency
  Future<Transaction> buyCrypto({
    required CryptoCoin coin,
    required double amount,
    required double price,
  }) async {
    // Validate purchase
    final totalCost = amount * price;
    if (totalCost > _usdBalance) {
      throw Exception('Insufficient USD balance');
    }

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    // Create transaction
    final transaction = Transaction(
      id: _generateTransactionId(),
      coinId: coin.id,
      coinSymbol: coin.symbol,
      coinName: coin.name,
      coinImage: coin.image,
      type: TransactionType.buy,
      amount: amount,
      price: price,
      totalValue: totalCost,
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
      transactionHash: _generateTransactionHash(),
      fees: totalCost * 0.0025, // 0.25% fee
    );

    // Update balances
    _usdBalance -= totalCost;
    _coinHoldings[coin.id] = (_coinHoldings[coin.id] ?? 0) + amount;

    // Add to transaction history
    _transactions.add(transaction);

    return transaction;
  }

  // Sell cryptocurrency
  Future<Transaction> sellCrypto({
    required CryptoCoin coin,
    required double amount,
    required double price,
  }) async {
    // Validate sale
    final currentHolding = _coinHoldings[coin.id] ?? 0;
    if (amount > currentHolding) {
      throw Exception('Insufficient coin balance');
    }

    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 1));

    // Create transaction
    final totalValue = amount * price;
    final transaction = Transaction(
      id: _generateTransactionId(),
      coinId: coin.id,
      coinSymbol: coin.symbol,
      coinName: coin.name,
      coinImage: coin.image,
      type: TransactionType.sell,
      amount: amount,
      price: price,
      totalValue: totalValue,
      timestamp: DateTime.now(),
      status: TransactionStatus.completed,
      transactionHash: _generateTransactionHash(),
      fees: totalValue * 0.0025, // 0.25% fee
    );

    // Update balances
    _usdBalance += totalValue;
    _coinHoldings[coin.id] = currentHolding - amount;

    // Remove coin from holdings if balance becomes 0
    if (_coinHoldings[coin.id]! <= 0) {
      _coinHoldings.remove(coin.id);
    }

    // Add to transaction history
    _transactions.add(transaction);

    return transaction;
  }

  // Get transaction history with optional filtering
  List<Transaction> getTransactionHistory({
    String? coinId,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<Transaction> filtered = List.from(_transactions);

    if (coinId != null) {
      filtered = filtered.where((t) => t.coinId == coinId).toList();
    }

    if (type != null) {
      filtered = filtered.where((t) => t.type == type).toList();
    }

    if (status != null) {
      filtered = filtered.where((t) => t.status == status).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((t) => t.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((t) => t.timestamp.isBefore(endDate)).toList();
    }

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return filtered;
  }

  // Get coin holding details
  double getCoinHolding(String coinId) {
    return _coinHoldings[coinId] ?? 0;
  }

  // Get coin holding value
  double getCoinHoldingValue(String coinId, double currentPrice) {
    final holding = _coinHoldings[coinId] ?? 0;
    return holding * currentPrice;
  }

  // Reset demo data (for testing)
  void resetDemoData() {
    _usdBalance = 10000.0;
    _coinHoldings.clear();
    _transactions.clear();
  }

  // Private helper methods
  String _generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          16, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  String _generateTransactionHash() {
    const chars = 'abcdef0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          64, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
