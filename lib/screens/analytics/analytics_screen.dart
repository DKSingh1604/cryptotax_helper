import 'package:flutter/material.dart';
import 'package:cryptotax_helper/models/portfolio.dart';
import 'package:cryptotax_helper/models/user_settings.dart';
import 'package:cryptotax_helper/services/storage_service.dart';
import 'package:cryptotax_helper/services/mock_data_service.dart';
import 'package:cryptotax_helper/widgets/crypto_chart.dart';
import 'package:cryptotax_helper/utils/constants.dart';
import 'package:cryptotax_helper/utils/helpers.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with AutomaticKeepAliveClientMixin {
  Portfolio? _portfolio;
  UserSettings _settings = UserSettings();
  List<ChartData> _profitLossData = [];
  bool _isLoading = true;
  
  String _selectedPeriod = '30D';
  final List<String> _periods = ['7D', '30D', '90D', '1Y'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final settings = await StorageService.getUserSettings();
      final transactions = await StorageService.getTransactions();
      final portfolio = MockDataService.calculatePortfolioFromTransactions(transactions);
      
      // Generate chart data based on selected period
      final days = _getPeriodDays(_selectedPeriod);
      final profitLossData = MockDataService.generateProfitLossChart(days: days);

      setState(() {
        _settings = settings;
        _portfolio = portfolio;
        _profitLossData = profitLossData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading analytics: $e', isError: true);
      }
    }
  }

  int _getPeriodDays(String period) {
    switch (period) {
      case '7D':
        return 7;
      case '30D':
        return 30;
      case '90D':
        return 90;
      case '1Y':
        return 365;
      default:
        return 30;
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _isLoading = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Period Selector
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: _onPeriodChanged,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPeriod,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
              ],
            ),
            itemBuilder: (context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading 
          ? _buildLoadingScreen()
          : SingleChildScrollView(
              padding: AppConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portfolio Overview
                  _buildPortfolioOverview(),
                  const SizedBox(height: 24),
                  
                  // Profit/Loss Chart
                  ProfitLossChart(
                    data: _profitLossData,
                    isDarkMode: _settings.isDarkMode,
                  ),
                  const SizedBox(height: 24),
                  
                  // Portfolio Distribution Chart
                  if (_portfolio != null && _portfolio!.holdings.isNotEmpty)
                    PortfolioDistributionChart(holdings: _portfolio!.holdings),
                  const SizedBox(height: 24),
                  
                  // Holdings List
                  _buildHoldingsList(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading analytics...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioOverview() {
    if (_portfolio == null) return const SizedBox();

    return Container(
      padding: AppConstants.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Performance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Value',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      Helpers.formatCurrency(_portfolio!.totalValue, _settings.currency),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Helpers.getProfitLossIcon(_portfolio!.totalProfitLoss),
                        color: Helpers.getProfitLossColor(_portfolio!.totalProfitLoss, _settings.isDarkMode),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatPercentage(_portfolio!.profitLossPercentage),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Helpers.getProfitLossColor(_portfolio!.totalProfitLoss, _settings.isDarkMode),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    Helpers.formatCurrency(_portfolio!.totalProfitLoss, _settings.currency),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsList() {
    if (_portfolio == null || _portfolio!.holdings.isEmpty) {
      return _buildEmptyHoldings();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Holdings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _portfolio!.holdings.length,
          itemBuilder: (context, index) {
            final holding = _portfolio!.holdings[index];
            return _buildHoldingItem(holding);
          },
        ),
      ],
    );
  }

  Widget _buildHoldingItem(CoinHolding holding) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Coin Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
            ),
            child: Icon(
              Icons.currency_bitcoin,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Coin Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      holding.coinSymbol,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      holding.coinName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${Helpers.formatAmount(holding.amount)} ${holding.coinSymbol}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Values
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Helpers.formatCurrency(holding.totalValue, _settings.currency),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Helpers.getProfitLossIcon(holding.profitLoss),
                    color: Helpers.getProfitLossColor(holding.profitLoss, _settings.isDarkMode),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Helpers.formatCurrency(holding.profitLoss, _settings.currency),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Helpers.getProfitLossColor(holding.profitLoss, _settings.isDarkMode),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHoldings() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No holdings to analyze',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some transactions to see your analytics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}