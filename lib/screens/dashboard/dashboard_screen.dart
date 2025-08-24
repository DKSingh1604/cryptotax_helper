import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cryptotax_helper/models/portfolio.dart';
import 'package:cryptotax_helper/models/user_settings.dart';
import 'package:cryptotax_helper/models/transaction.dart' as AppTransaction;
import 'package:cryptotax_helper/screens/transactions/transactions_screen.dart';
import 'package:cryptotax_helper/screens/transactions/add_transaction_screen.dart';
import 'package:cryptotax_helper/screens/analytics/analytics_screen.dart';
import 'package:cryptotax_helper/screens/settings/settings_screen.dart';
import 'package:cryptotax_helper/services/crypto_repository.dart';
import 'package:cryptotax_helper/widgets/custom_bottom_nav.dart';
import 'package:cryptotax_helper/widgets/summary_card.dart';
import 'package:cryptotax_helper/widgets/transaction_item.dart';
import 'package:cryptotax_helper/utils/constants.dart';
import 'package:cryptotax_helper/utils/helpers.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Portfolio? _portfolio;
  UserSettings _settings = UserSettings();
  List<AppTransaction.Transaction> _recentTransactions = [];
  bool _isLoading = true;
  final _repository = CryptoRepository();
  StreamSubscription<UserSettings?>? _settingsSub;
  StreamSubscription<Portfolio?>? _portfolioSub;
  StreamSubscription<List<AppTransaction.Transaction>>? _txSub;
  StreamSubscription? _authSub;

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Manage subscriptions based on auth state
    _authSub = _repository.authStateChanges.listen((user) {
      if (user == null) {
        _cancelDataSubscriptions();
        if (mounted) {
          setState(() {
            _portfolio = null;
            _recentTransactions = [];
            _isLoading = true;
          });
        }
      } else {
        _loadData();
      }
    });
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  List<Widget> get _screens => [
        _buildDashboardContent(),
        TransactionsScreen(onTransactionAdded: _refreshPortfolio),
        const AnalyticsScreen(),
        SettingsScreen(onSettingsChanged: _onSettingsChanged),
      ];

  Future<void> _loadData() async {
    try {
      // Listen to user settings stream
      _settingsSub ??= _repository.getUserSettings().listen((settings) {
        if (settings != null && mounted) {
          setState(() {
            _settings = settings;
          });
        }
      });

      // Listen to portfolio stream
      _portfolioSub ??= _repository.getUserPortfolio().listen((portfolio) {
        if (portfolio != null && mounted) {
          setState(() {
            _portfolio = portfolio;
            _isLoading = false;
          });
          _fadeAnimationController.forward();
        }
      });

      // Listen to recent transactions stream
      _txSub ??=
          _repository.getUserTransactions(limit: 5).listen((transactions) {
        if (mounted) {
          setState(() {
            _recentTransactions = transactions;
          });
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading data: $e', isError: true);
      }
    }
  }

  void _refreshPortfolio() async {
    // Portfolio will be updated automatically through streams
    // No need to manually refresh since we're using Firebase streams
  }

  void _onSettingsChanged(UserSettings newSettings) {
    setState(() => _settings = newSettings);
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _showAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          onTransactionAdded: _refreshPortfolio,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _cancelDataSubscriptions();
    _authSub?.cancel();
    super.dispose();
  }

  void _cancelDataSubscriptions() {
    _settingsSub?.cancel();
    _portfolioSub?.cancel();
    _txSub?.cancel();
    _settingsSub = null;
    _portfolioSub = null;
    _txSub = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? _buildLoadingScreen()
          : IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransaction,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your portfolio...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Summary Cards
              _buildSummaryCards(),
              const SizedBox(height: 32),

              // Recent Transactions
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_getGreeting()}!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Here\'s your portfolio overview',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    if (_portfolio == null) return const SizedBox();

    return Column(
      children: [
        // Total Portfolio Value
        SummaryCard(
          title: AppStrings.totalPortfolioValue,
          value: Helpers.formatCurrency(
              _portfolio!.totalValue, _settings.currency),
          icon: Icons.account_balance_wallet_rounded,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // Total Profit/Loss
            Expanded(
              child: SummaryCard(
                title: AppStrings.totalProfitLoss,
                value: Helpers.formatCurrency(
                    _portfolio!.totalProfitLoss, _settings.currency),
                subtitle:
                    Helpers.formatPercentage(_portfolio!.profitLossPercentage),
                icon: Helpers.getProfitLossIcon(_portfolio!.totalProfitLoss),
                iconColor: Helpers.getProfitLossColor(
                    _portfolio!.totalProfitLoss, _settings.isDarkMode),
                isPositive: _portfolio!.isProfitable,
              ),
            ),
            const SizedBox(width: 16),

            // Estimated Tax Due
            Expanded(
              child: SummaryCard(
                title: AppStrings.estimatedTaxDue,
                value: Helpers.formatCurrency(
                    _portfolio!.estimatedTaxDue, _settings.currency),
                subtitle: '${_settings.taxRate}% rate',
                icon: Icons.receipt_long_rounded,
                iconColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    // Show empty state if there are no recent transactions
    if (_recentTransactions.isEmpty) {
      return _buildEmptyTransactions();
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentTransactions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            TextButton(
              onPressed: () => setState(() => _currentIndex = 1),
              child: Text(
                AppStrings.seeAll,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Transaction List (top 5 are already provided by the stream limit)
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentTransactions.length,
          itemBuilder: (context, index) {
            final transaction = _recentTransactions[index];
            return TransactionItem(
              transaction: transaction,
              currency: _settings.currency,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first crypto transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
