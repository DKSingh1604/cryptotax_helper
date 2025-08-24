class Transaction {
  final String id;
  final String coinName;
  final String coinSymbol;
  final TransactionType type;
  final double amount;
  final double pricePerUnit;
  final DateTime date;
  final double totalValue;
  
  Transaction({
    required this.id,
    required this.coinName,
    required this.coinSymbol,
    required this.type,
    required this.amount,
    required this.pricePerUnit,
    required this.date,
  }) : totalValue = amount * pricePerUnit;

  Map<String, dynamic> toJson() => {
    'id': id,
    'coinName': coinName,
    'coinSymbol': coinSymbol,
    'type': type.toString(),
    'amount': amount,
    'pricePerUnit': pricePerUnit,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    coinName: json['coinName'],
    coinSymbol: json['coinSymbol'],
    type: TransactionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    amount: json['amount'].toDouble(),
    pricePerUnit: json['pricePerUnit'].toDouble(),
    date: DateTime.parse(json['date']),
  );
}

enum TransactionType { buy, sell }

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.buy:
        return 'Buy';
      case TransactionType.sell:
        return 'Sell';
    }
  }
}