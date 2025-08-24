import 'dart:math';
import 'package:cryptotax_helper/models/transaction.dart';
import 'package:cryptotax_helper/models/portfolio.dart';

class MockDataService {
  static final Random _random = Random();

  // Sample cryptocurrencies
  static final List<Map<String, String>> _cryptos = [
    {'name': 'Bitcoin', 'symbol': 'BTC'},
    {'name': 'Ethereum', 'symbol': 'ETH'},
    {'name': 'Cardano', 'symbol': 'ADA'},
    {'name': 'Solana', 'symbol': 'SOL'},
    {'name': 'Polygon', 'symbol': 'MATIC'},
    {'name': 'Chainlink', 'symbol': 'LINK'},
    {'name': 'Polkadot', 'symbol': 'DOT'},
    {'name': 'Avalanche', 'symbol': 'AVAX'},
  ];

  // Generate mock transactions
  static List<Transaction> generateMockTransactions({int count = 25}) {
    final List<Transaction> transactions = [];
    final DateTime now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final crypto = _cryptos[_random.nextInt(_cryptos.length)];
      final type = TransactionType.values[_random.nextInt(2)];
      final amount = _generateAmount(crypto['symbol']!);
      final price = _generatePrice(crypto['symbol']!);
      final date = now.subtract(Duration(days: _random.nextInt(365)));

      transactions.add(Transaction(
        id: 'tx_${i.toString().padLeft(3, '0')}',
        coinName: crypto['name']!,
        coinSymbol: crypto['symbol']!,
        type: type,
        amount: amount,
        pricePerUnit: price,
        date: date,
      ));
    }

    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  // Generate portfolio holdings
  static List<CoinHolding> generateMockHoldings() {
    return [
      CoinHolding(
        coinName: 'Bitcoin',
        coinSymbol: 'BTC',
        amount: 0.5,
        currentPrice: 45000.0,
        profitLoss: 2500.0,
        percentage: 45.0,
      ),
      CoinHolding(
        coinName: 'Ethereum',
        coinSymbol: 'ETH',
        amount: 2.5,
        currentPrice: 2800.0,
        profitLoss: 800.0,
        percentage: 25.0,
      ),
      CoinHolding(
        coinName: 'Cardano',
        coinSymbol: 'ADA',
        amount: 1000.0,
        currentPrice: 0.45,
        profitLoss: -50.0,
        percentage: 15.0,
      ),
      CoinHolding(
        coinName: 'Solana',
        coinSymbol: 'SOL',
        amount: 10.0,
        currentPrice: 95.0,
        profitLoss: 150.0,
        percentage: 15.0,
      ),
    ];
  }

  // Generate chart data for analytics
  static List<ChartData> generateProfitLossChart({int days = 30}) {
    final List<ChartData> data = [];
    final DateTime now = DateTime.now();
    double baseValue = 1000.0;

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      baseValue += (_random.nextDouble() - 0.5) * 200; // Random fluctuation
      data.add(ChartData(date: date, value: baseValue));
    }

    return data;
  }

  // Generate price based on crypto type
  static double _generatePrice(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 40000 + _random.nextDouble() * 20000; // 40k-60k
      case 'ETH':
        return 2000 + _random.nextDouble() * 2000; // 2k-4k
      case 'ADA':
        return 0.3 + _random.nextDouble() * 0.8; // 0.3-1.1
      case 'SOL':
        return 50 + _random.nextDouble() * 100; // 50-150
      case 'MATIC':
        return 0.5 + _random.nextDouble() * 2; // 0.5-2.5
      case 'LINK':
        return 10 + _random.nextDouble() * 30; // 10-40
      case 'DOT':
        return 5 + _random.nextDouble() * 15; // 5-20
      case 'AVAX':
        return 20 + _random.nextDouble() * 40; // 20-60
      default:
        return 1 + _random.nextDouble() * 10; // 1-11
    }
  }

  // Generate amount based on crypto type
  static double _generateAmount(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 0.01 + _random.nextDouble() * 2; // Small amounts for BTC
      case 'ETH':
        return 0.1 + _random.nextDouble() * 10;
      case 'ADA':
      case 'MATIC':
        return 100 + _random.nextDouble() * 5000; // Larger amounts for cheaper coins
      default:
        return 1 + _random.nextDouble() * 100;
    }
  }

  // Calculate portfolio summary from transactions
  static Portfolio calculatePortfolioFromTransactions(List<Transaction> transactions) {
    final holdings = generateMockHoldings();
    final totalValue = holdings.fold<double>(0, (sum, holding) => sum + holding.totalValue);
    final totalProfitLoss = holdings.fold<double>(0, (sum, holding) => sum + holding.profitLoss);
    final estimatedTaxDue = totalProfitLoss > 0 ? totalProfitLoss * 0.2 : 0.0; // 20% tax rate

    return Portfolio(
      totalValue: totalValue,
      totalProfitLoss: totalProfitLoss,
      estimatedTaxDue: estimatedTaxDue,
      holdings: holdings,
      recentTransactions: transactions.take(5).toList(),
    );
  }
}