import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/trading_provider.dart';
import '../providers/crypto_provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TransactionType? _selectedType;
  TransactionStatus? _selectedStatus;
  String? _selectedCoinId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_hasActiveFilters) _buildFilterChips(),
          
          // Transaction list
          Expanded(
            child: Consumer2<TradingProvider, CryptoProvider>(
              builder: (context, tradingProvider, cryptoProvider, child) {
                final transactions = tradingProvider.getTransactionHistory(
                  coinId: _selectedCoinId,
                  type: _selectedType,
                  status: _selectedStatus,
                  startDate: _startDate,
                  endDate: _endDate,
                );

                if (transactions.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final coin = cryptoProvider.cryptocurrencies.firstWhere(
                      (c) => c.id == transaction.coinId,
                      orElse: () => cryptoProvider.cryptocurrencies.first,
                    );
                    
                    return _buildTransactionCard(transaction, coin);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedType != null ||
           _selectedStatus != null ||
           _selectedCoinId != null ||
           _startDate != null ||
           _endDate != null;
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedType != null)
            _buildFilterChip(
              label: _selectedType!.displayName,
              onRemove: () => setState(() => _selectedType = null),
            ),
          if (_selectedStatus != null)
            _buildFilterChip(
              label: _selectedStatus!.displayName,
              onRemove: () => setState(() => _selectedStatus = null),
            ),
          if (_selectedCoinId != null)
            _buildFilterChip(
              label: _getCoinSymbol(_selectedCoinId!),
              onRemove: () => setState(() => _selectedCoinId = null),
            ),
          if (_startDate != null)
            _buildFilterChip(
              label: 'From ${DateFormat('MMM dd').format(_startDate!)}',
              onRemove: () => setState(() => _startDate = null),
            ),
          if (_endDate != null)
            _buildFilterChip(
              label: 'To ${DateFormat('MMM dd').format(_endDate!)}',
              onRemove: () => setState(() => _endDate = null),
            ),
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, dynamic coin) {
    final isPositive = transaction.type == TransactionType.buy;
    final color = isPositive ? Colors.green : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Coin icon
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    transaction.coinImage,
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.currency_bitcoin, color: Colors.white, size: 16),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Coin info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.coinName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.coinSymbol,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Transaction type and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.type.displayName,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(transaction.status),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Transaction details
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    label: 'Amount',
                    value: '${transaction.amount.toStringAsFixed(6)} ${transaction.coinSymbol}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    label: 'Price',
                    value: '\$${transaction.price.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    label: 'Total',
                    value: '\$${transaction.totalValue.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Fees and timestamp
            Row(
              children: [
                if (transaction.fees != null)
                  Expanded(
                    child: _buildDetailItem(
                      label: 'Fees',
                      value: '\$${transaction.fees!.toStringAsFixed(2)}',
                    ),
                  ),
                Expanded(
                  child: _buildDetailItem(
                    label: 'Date',
                    value: DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp),
                  ),
                ),
              ],
            ),
            
            // Transaction hash (if available)
            if (transaction.transactionHash != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                label: 'Transaction Hash',
                value: '${transaction.transactionHash!.substring(0, 8)}...${transaction.transactionHash!.substring(transaction.transactionHash!.length - 8)}',
                isHash: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    bool isHash = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: isHash ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getCoinSymbol(String coinId) {
    final cryptoProvider = context.read<CryptoProvider>();
    final coin = cryptoProvider.cryptocurrencies.firstWhere(
      (c) => c.id == coinId,
      orElse: () => cryptoProvider.cryptocurrencies.first,
    );
    return coin.symbol;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        selectedCoinId: _selectedCoinId,
        startDate: _startDate,
        endDate: _endDate,
        onApply: (type, status, coinId, startDate, endDate) {
          setState(() {
            _selectedType = type;
            _selectedStatus = status;
            _selectedCoinId = coinId;
            _startDate = startDate;
            _endDate = endDate;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _selectedCoinId = null;
      _startDate = null;
      _endDate = null;
    });
  }
}

class _FilterDialog extends StatefulWidget {
  final TransactionType? selectedType;
  final TransactionStatus? selectedStatus;
  final String? selectedCoinId;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(
    TransactionType?,
    TransactionStatus?,
    String?,
    DateTime?,
    DateTime?,
  ) onApply;

  const _FilterDialog({
    required this.selectedType,
    required this.selectedStatus,
    required this.selectedCoinId,
    required this.startDate,
    required this.endDate,
    required this.onApply,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late TransactionType? _selectedType;
  late TransactionStatus? _selectedStatus;
  late String? _selectedCoinId;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedStatus = widget.selectedStatus;
    _selectedCoinId = widget.selectedCoinId;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Transactions'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transaction type filter
            _buildDropdownFilter<TransactionType>(
              label: 'Transaction Type',
              value: _selectedType,
              items: TransactionType.values,
              onChanged: (value) => setState(() => _selectedType = value),
              itemBuilder: (type) => type.displayName,
            ),
            
            const SizedBox(height: 16),
            
            // Transaction status filter
            _buildDropdownFilter<TransactionStatus>(
              label: 'Status',
              value: _selectedStatus,
              items: TransactionStatus.values,
              onChanged: (value) => setState(() => _selectedStatus = value),
              itemBuilder: (status) => status.displayName,
            ),
            
            const SizedBox(height: 16),
            
            // Date range filter
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Start Date',
                    value: _startDate,
                    onChanged: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'End Date',
                    value: _endDate,
                    onChanged: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => widget.onApply(
            _selectedType,
            _selectedStatus,
            _selectedCoinId,
            _startDate,
            _endDate,
          ),
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemBuilder,
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
        DropdownButtonFormField<T>(
          value: value,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: const Text('All'),
            ),
            ...items.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemBuilder(item)),
            )),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null
                        ? DateFormat('MMM dd, yyyy').format(value)
                        : 'Select date',
                    style: TextStyle(
                      color: value != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
