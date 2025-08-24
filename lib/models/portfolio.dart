import 'package:cryptotax_helper/models/transaction.dart';

class Portfolio {
  final double totalValue;
  final double totalProfitLoss;
  final double estimatedTaxDue;
  final List<CoinHolding> holdings;
  final List<Transaction> recentTransactions;

  Portfolio({
    required this.totalValue,
    required this.totalProfitLoss,
    required this.estimatedTaxDue,
    required this.holdings,
    required this.recentTransactions,
  });

  bool get isProfitable => totalProfitLoss >= 0;

  double get profitLossPercentage {
    if (totalValue == 0) return 0;
    return (totalProfitLoss / (totalValue - totalProfitLoss)) * 100;
  }

  Map<String, dynamic> toJson() => {
    'totalValue': totalValue,
    'totalProfitLoss': totalProfitLoss,
    'estimatedTaxDue': estimatedTaxDue,
    'holdings': holdings.map((h) => h.toJson()).toList(),
  };

  factory Portfolio.fromJson(Map<String, dynamic> json, List<Transaction> recentTransactions) => Portfolio(
    totalValue: (json['totalValue'] ?? 0.0).toDouble(),
    totalProfitLoss: (json['totalProfitLoss'] ?? 0.0).toDouble(),
    estimatedTaxDue: (json['estimatedTaxDue'] ?? 0.0).toDouble(),
    holdings: (json['holdings'] as List<dynamic>?)
        ?.map((h) => CoinHolding.fromJson(h as Map<String, dynamic>))
        .toList() ?? [],
    recentTransactions: recentTransactions,
  );
}

class CoinHolding {
  final String coinName;
  final String coinSymbol;
  final double amount;
  final double currentPrice;
  final double totalValue;
  final double profitLoss;
  final double percentage;

  CoinHolding({
    required this.coinName,
    required this.coinSymbol,
    required this.amount,
    required this.currentPrice,
    required this.profitLoss,
    required this.percentage,
  }) : totalValue = amount * currentPrice;

  bool get isProfitable => profitLoss >= 0;

  Map<String, dynamic> toJson() => {
    'coinName': coinName,
    'coinSymbol': coinSymbol,
    'amount': amount,
    'currentPrice': currentPrice,
    'totalValue': totalValue,
    'profitLoss': profitLoss,
    'percentage': percentage,
  };

  factory CoinHolding.fromJson(Map<String, dynamic> json) => CoinHolding(
    coinName: json['coinName'] ?? '',
    coinSymbol: json['coinSymbol'] ?? '',
    amount: (json['amount'] ?? 0.0).toDouble(),
    currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
    profitLoss: (json['profitLoss'] ?? 0.0).toDouble(),
    percentage: (json['percentage'] ?? 0.0).toDouble(),
  );
}

class ChartData {
  final DateTime date;
  final double value;

  ChartData({required this.date, required this.value});
}