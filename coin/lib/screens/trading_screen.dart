import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/crypto_coin.dart';
import '../models/transaction.dart';
import '../providers/trading_provider.dart';

class TradingScreen extends StatefulWidget {
  final CryptoCoin coin;

  const TradingScreen({
    super.key,
    required this.coin,
  });

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  TransactionType _selectedType = TransactionType.buy;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Set initial price
    _priceController.text = widget.coin.currentPrice.toStringAsFixed(2);

    // Set initial amount to 100 USD worth
    _updateAmountFromTotal(100.0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      _selectedType = _tabController.index == 0
          ? TransactionType.buy
          : TransactionType.sell;
    });
  }

  void _updateAmountFromTotal(double total) {
    if (_isCalculating) return;
    _isCalculating = true;

    final price = double.tryParse(_priceController.text) ?? 0;
    if (price > 0) {
      final amount = total / price;
      _amountController.text = amount.toStringAsFixed(6);
    }

    _isCalculating = false;
  }

  void _updateTotalFromAmount() {
    if (_isCalculating) return;
    _isCalculating = true;

    final amount = double.tryParse(_amountController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = amount * price;
    _totalController.text = total.toStringAsFixed(2);

    _isCalculating = false;
  }

  Future<void> _executeTrade() async {
    final amount = double.tryParse(_amountController.text);
    final price = double.tryParse(_priceController.text);

    if (amount == null || amount <= 0 || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount and price')),
      );
      return;
    }

    final tradingProvider = context.read<TradingProvider>();
    bool success;

    if (_selectedType == TransactionType.buy) {
      success = await tradingProvider.buyCrypto(
        coin: widget.coin,
        amount: amount,
        price: price,
      );
    } else {
      success = await tradingProvider.sellCrypto(
        coin: widget.coin,
        amount: amount,
        price: price,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${_selectedType.displayName} order executed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _amountController.clear();
      _totalController.clear();
      _priceController.text = widget.coin.currentPrice.toStringAsFixed(2);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to execute ${_selectedType.displayName.toLowerCase()} order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('${_selectedType.displayName} ${widget.coin.symbol}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Coin info header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.coin.image,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.currency_bitcoin,
                            color: Colors.white),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.coin.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        widget.coin.formattedPrice,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.coin.formattedPriceChange,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: widget.coin.isPositive
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '24h',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary,
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'BUY'),
                Tab(text: 'SELL'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Trading form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Amount input
                  _buildInputField(
                    label: 'Amount (${widget.coin.symbol})',
                    controller: _amountController,
                    onChanged: (_) => _updateTotalFromAmount(),
                    suffix: widget.coin.symbol,
                  ),

                  const SizedBox(height: 16),

                  // Price input
                  _buildInputField(
                    label: 'Price (USD)',
                    controller: _priceController,
                    onChanged: (_) => _updateAmountFromTotal(
                      double.tryParse(_totalController.text) ?? 0,
                    ),
                    suffix: 'USD',
                  ),

                  const SizedBox(height: 16),

                  // Total input
                  _buildInputField(
                    label: 'Total (USD)',
                    controller: _totalController,
                    onChanged: (_) => _updateAmountFromTotal(
                      double.tryParse(_totalController.text) ?? 0,
                    ),
                    suffix: 'USD',
                  ),

                  const SizedBox(height: 24),

                  // Quick amount buttons
                  _buildQuickAmountButtons(),

                  const SizedBox(height: 32),

                  // Execute button
                  Consumer<TradingProvider>(
                    builder: (context, tradingProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              tradingProvider.isLoading ? null : _executeTrade,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedType == TransactionType.buy
                                    ? Colors.green
                                    : Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: tradingProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  _selectedType == TransactionType.buy
                                      ? 'Buy ${widget.coin.symbol}'
                                      : 'Sell ${widget.coin.symbol}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Balance info
                  Consumer<TradingProvider>(
                    builder: (context, tradingProvider, child) {
                      return _buildBalanceInfo(tradingProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButtons() {
    final amounts = [100, 500, 1000, 5000];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Amount (USD)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: amounts.map((amount) {
            return ElevatedButton(
              onPressed: () => _updateAmountFromTotal(amount.toDouble()),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('\$$amount'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBalanceInfo(TradingProvider tradingProvider) {
    final coinHolding = tradingProvider.getCoinHolding(widget.coin.id);
    final coinValue = tradingProvider.getCoinHoldingValue(
      widget.coin.id,
      widget.coin.currentPrice,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'USD Balance',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${tradingProvider.usdBalance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.coin.symbol} Balance',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${coinHolding.toStringAsFixed(6)} (${coinValue.toStringAsFixed(2)} USD)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
