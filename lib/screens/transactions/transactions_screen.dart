import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cryptotax_helper/models/transaction.dart';
import 'package:cryptotax_helper/models/user_settings.dart';
import 'package:cryptotax_helper/services/crypto_repository.dart';
import 'package:cryptotax_helper/widgets/transaction_item.dart';
import 'package:cryptotax_helper/utils/constants.dart';
import 'package:cryptotax_helper/utils/helpers.dart';

class TransactionsScreen extends StatefulWidget {
  final VoidCallback? onTransactionAdded;

  const TransactionsScreen({super.key, this.onTransactionAdded});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with AutomaticKeepAliveClientMixin {
  List<Transaction> _allTransactions = [];
  List<Transaction> _filteredTransactions = [];
  UserSettings _settings = UserSettings();
  bool _isLoading = true;
  final _repository = CryptoRepository();
  StreamSubscription<UserSettings?>? _settingsSub;
  StreamSubscription<List<Transaction>>? _txSub;
  StreamSubscription? _authSub;

  String _selectedCoin = 'All';
  TransactionType? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // React to auth; only load data when logged in
    _authSub = _repository.authStateChanges.listen((user) {
      if (user == null) {
        _cancelSubs();
        if (mounted) {
          setState(() {
            _allTransactions = [];
            _filteredTransactions = [];
            _isLoading = true;
          });
        }
      } else {
        _loadData();
      }
    });
    _loadData();
    _searchController.addListener(_filterTransactions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cancelSubs();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // Settings stream
      _settingsSub ??= _repository.getUserSettings().listen((settings) {
        if (!mounted || settings == null) return;
        setState(() => _settings = settings);
      });

      // Transactions stream (no limit)
      _txSub ??= _repository.getUserTransactions().listen((transactions) {
        if (!mounted) return;
        setState(() {
          _allTransactions = transactions;
          _filteredTransactions = _applyFilters(transactions);
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Helpers.showSnackBar(context, 'Error loading transactions: $e',
            isError: true);
      }
    }
  }

  void _cancelSubs() {
    _settingsSub?.cancel();
    _txSub?.cancel();
    _authSub?.cancel();
    _settingsSub = null;
    _txSub = null;
    _authSub = null;
  }

  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTransactions =
          _applyFilters(_allTransactions, searchQuery: query);
    });
  }

  List<Transaction> _applyFilters(List<Transaction> source,
      {String? searchQuery}) {
    final query = (searchQuery ?? _searchController.text).toLowerCase();

    return source.where((transaction) {
      final matchesSearch = query.isEmpty ||
          transaction.coinName.toLowerCase().contains(query) ||
          transaction.coinSymbol.toLowerCase().contains(query);

      final matchesCoin =
          _selectedCoin == 'All' || transaction.coinSymbol == _selectedCoin;

      final matchesType =
          _selectedType == null || transaction.type == _selectedType;

      return matchesSearch && matchesCoin && matchesType;
    }).toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list,
                color: Theme.of(context).colorScheme.primary),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingScreen()
          : Column(
              children: [
                // Search Bar
                _buildSearchBar(),

                // Filters Row
                _buildFiltersRow(),

                // Transactions List
                Expanded(child: _buildTransactionsList()),
              ],
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading transactions...',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: AppConstants.screenPadding,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          prefixIcon:
              Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Filters:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(width: 12),

          // Coin Filter
          if (_selectedCoin != 'All')
            Chip(
              label: Text(_selectedCoin),
              onDeleted: () {
                setState(() => _selectedCoin = 'All');
                _filterTransactions();
              },
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),

          const SizedBox(width: 8),

          // Type Filter
          if (_selectedType != null)
            Chip(
              label: Text(_selectedType!.displayName),
              onDeleted: () {
                setState(() => _selectedType = null);
                _filterTransactions();
              },
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: AppConstants.screenPadding,
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _filteredTransactions[index];
        return TransactionItem(
          transaction: transaction,
          currency: _settings.currency,
          onTap: () => _showTransactionDetails(transaction),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
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

  Widget _buildFilterBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Transactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Coin Filter
          Text(
            'Coin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              'All',
              ...AppConstants.availableCoins.map((coin) => coin['symbol']!)
            ]
                .map((coin) => FilterChip(
                      label: Text(coin),
                      selected: _selectedCoin == coin,
                      onSelected: (selected) {
                        setState(() => _selectedCoin = coin);
                        _filterTransactions();
                      },
                    ))
                .toList(),
          ),

          const SizedBox(height: 24),

          // Type Filter
          Text(
            'Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All Types'),
                selected: _selectedType == null,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = null);
                    _filterTransactions();
                  }
                },
              ),
              ...TransactionType.values.map((type) => FilterChip(
                    label: Text(type.displayName),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      setState(() => _selectedType = selected ? type : null);
                      _filterTransactions();
                    },
                  )),
            ],
          ),

          const SizedBox(height: 24),

          // Close Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('${transaction.type.displayName} ${transaction.coinSymbol}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Coin', transaction.coinName),
            _buildDetailRow('Amount', Helpers.formatAmount(transaction.amount)),
            _buildDetailRow(
                'Price per Unit',
                Helpers.formatCurrency(
                    transaction.pricePerUnit, _settings.currency)),
            _buildDetailRow(
                'Total Value',
                Helpers.formatCurrency(
                    transaction.totalValue, _settings.currency)),
            _buildDetailRow('Date', Helpers.formatDateTime(transaction.date)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
