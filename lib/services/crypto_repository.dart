import 'package:firebase_auth/firebase_auth.dart';
import 'package:cryptotax_helper/models/transaction.dart' as AppTransaction;
import 'package:cryptotax_helper/models/portfolio.dart';
import 'package:cryptotax_helper/models/user_settings.dart';
import 'package:cryptotax_helper/services/firebase_auth_service.dart';
import 'package:cryptotax_helper/services/firestore_service.dart';
import 'package:cryptotax_helper/services/mock_data_service.dart';

class CryptoRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final MockDataService _mockDataService = MockDataService();

  // Authentication methods
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _authService.signUpWithEmailPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (credential?.user != null) {
      await _firestoreService.createUserDocument(credential!.user!);
      
      // Initialize user with default settings and sample data
      await saveUserSettings(UserSettings());
      await _initializeUserData();
    }

    return credential;
  }

  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    if (credential?.user != null) {
      await _firestoreService.updateLastLoginTime();
    }

    return credential;
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);

  User? get currentUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  String getAuthErrorMessage(FirebaseAuthException e) =>
      _authService.getAuthErrorMessage(e);

  // AppTransaction.Transaction methods
  Future<void> addTransaction(AppTransaction.Transaction transaction) async {
    await _firestoreService.addTransaction(transaction);
    await _updatePortfolioCalculations();
  }

  Future<void> updateTransaction(String transactionId, AppTransaction.Transaction transaction) async {
    await _firestoreService.updateTransaction(transactionId, transaction);
    await _updatePortfolioCalculations();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firestoreService.deleteTransaction(transactionId);
    await _updatePortfolioCalculations();
  }

  Stream<List<AppTransaction.Transaction>> getUserTransactions({int? limit}) =>
      _firestoreService.getUserTransactions(limit: limit);

  Stream<List<AppTransaction.Transaction>> getTransactionsByCoin(String coinSymbol, {int? limit}) =>
      _firestoreService.getTransactionsByCoin(coinSymbol, limit: limit);

  // Portfolio methods
  Stream<Portfolio?> getUserPortfolio() => _firestoreService.getUserPortfolio();

  // User Settings methods
  Future<void> saveUserSettings(UserSettings settings) =>
      _firestoreService.saveUserSettings(settings);

  Stream<UserSettings?> getUserSettings() => _firestoreService.getUserSettings();

  // Account management
  Future<void> deleteAccount() async {
    await _firestoreService.deleteUserData();
    await _authService.deleteAccount();
  }

  // Helper methods
  Future<void> _initializeUserData() async {
    // Add some sample transactions for new users
    final sampleTransactions = MockDataService.generateMockTransactions(count: 5);
    for (final transaction in sampleTransactions.take(5)) {
      await _firestoreService.addTransaction(transaction);
    }
    
    // Update portfolio with initial calculations
    await _updatePortfolioCalculations();
  }

  Future<void> _updatePortfolioCalculations() async {
    // Get all user transactions
    final transactionsSnapshot = await getUserTransactions().first;
    
    if (transactionsSnapshot.isEmpty) return;

    // Calculate portfolio from transactions
    final portfolio = _calculatePortfolioFromTransactions(transactionsSnapshot);
    
    // Save updated portfolio
    await _firestoreService.updatePortfolio(portfolio);
  }

  Portfolio _calculatePortfolioFromTransactions(List<AppTransaction.Transaction> transactions) {
    final Map<String, CoinHolding> holdingsMap = {};
    double totalValue = 0;
    double totalCostBasis = 0;

    // Process each transaction to calculate current holdings
    for (final transaction in transactions) {
      final key = transaction.coinSymbol;
      final currentHolding = holdingsMap[key];
      
      if (currentHolding == null) {
        // First transaction for this coin
        holdingsMap[key] = CoinHolding(
          coinName: transaction.coinName,
          coinSymbol: transaction.coinSymbol,
          amount: transaction.type == AppTransaction.TransactionType.buy ? transaction.amount : -transaction.amount,
          currentPrice: transaction.pricePerUnit,
          profitLoss: 0,
          percentage: 0,
        );
      } else {
        // Update existing holding
        final newAmount = currentHolding.amount + 
            (transaction.type == AppTransaction.TransactionType.buy ? transaction.amount : -transaction.amount);
        
        holdingsMap[key] = CoinHolding(
          coinName: transaction.coinName,
          coinSymbol: transaction.coinSymbol,
          amount: newAmount,
          currentPrice: transaction.pricePerUnit, // Use latest price
          profitLoss: currentHolding.profitLoss,
          percentage: 0, // Will be calculated later
        );
      }
    }

    // Calculate portfolio metrics
    final holdings = holdingsMap.values.where((h) => h.amount > 0).toList();
    totalValue = holdings.fold(0, (sum, holding) => sum + holding.totalValue);
    
    // Calculate percentages and profit/loss
    final updatedHoldings = holdings.map((holding) {
      final percentage = totalValue > 0 ? (holding.totalValue / totalValue) * 100 : 0.0;
      // Simplified profit/loss calculation (would need more complex logic with real data)
      final profitLoss = holding.totalValue * 0.1; // Mock 10% profit
      
      return CoinHolding(
        coinName: holding.coinName,
        coinSymbol: holding.coinSymbol,
        amount: holding.amount,
        currentPrice: holding.currentPrice,
        profitLoss: profitLoss,
        percentage: percentage,
      );
    }).toList();

    final totalProfitLoss = updatedHoldings.fold(0.0, (sum, h) => sum + h.profitLoss);
    final estimatedTaxDue = totalProfitLoss > 0 ? totalProfitLoss * 0.2 : 0.0; // 20% tax rate

    return Portfolio(
      totalValue: totalValue,
      totalProfitLoss: totalProfitLoss,
      estimatedTaxDue: estimatedTaxDue,
      holdings: updatedHoldings,
      recentTransactions: transactions.take(10).toList(),
    );
  }
}