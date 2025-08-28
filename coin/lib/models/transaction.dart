class Transaction {
  final String id;
  final String coinId;
  final String coinSymbol;
  final String coinName;
  final String coinImage;
  final TransactionType type;
  final double amount;
  final double price;
  final double totalValue;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? transactionHash;
  final double? fees;

  Transaction({
    required this.id,
    required this.coinId,
    required this.coinSymbol,
    required this.coinName,
    required this.coinImage,
    required this.type,
    required this.amount,
    required this.price,
    required this.totalValue,
    required this.timestamp,
    required this.status,
    this.transactionHash,
    this.fees,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      coinId: json['coinId'],
      coinSymbol: json['coinSymbol'],
      coinName: json['coinName'],
      coinImage: json['coinImage'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      amount: json['amount'].toDouble(),
      price: json['price'].toDouble(),
      totalValue: json['totalValue'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      transactionHash: json['transactionHash'],
      fees: json['fees']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coinId': coinId,
      'coinSymbol': coinSymbol,
      'coinName': coinName,
      'coinImage': coinImage,
      'type': type.toString().split('.').last,
      'amount': amount,
      'price': price,
      'totalValue': totalValue,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'transactionHash': transactionHash,
      'fees': fees,
    };
  }

  Transaction copyWith({
    String? id,
    String? coinId,
    String? coinSymbol,
    String? coinName,
    String? coinImage,
    TransactionType? type,
    double? amount,
    double? price,
    double? totalValue,
    DateTime? timestamp,
    TransactionStatus? status,
    String? transactionHash,
    double? fees,
  }) {
    return Transaction(
      id: id ?? this.id,
      coinId: coinId ?? this.coinId,
      coinSymbol: coinSymbol ?? this.coinSymbol,
      coinName: coinName ?? this.coinName,
      coinImage: coinImage ?? this.coinImage,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      totalValue: totalValue ?? this.totalValue,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      transactionHash: transactionHash ?? this.transactionHash,
      fees: fees ?? this.fees,
    );
  }
}

enum TransactionType {
  buy,
  sell,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
    }
  }

  String get actionName {
    switch (this) {
      case TransactionType.buy:
        return 'Purchase';
      case TransactionType.sell:
        return 'Sell';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }
}
