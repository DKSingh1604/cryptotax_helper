import 'package:firebase_auth/firebase_auth.dart';
import 'package:cryptotax_helper/models/transaction.dart' as AppTransaction;
import 'package:cryptotax_helper/models/portfolio.dart';
import 'package:cryptotax_helper/models/user_settings.dart';
import 'package:cryptotax_helper/services/firebase_auth_service.dart';
import 'package:cryptotax_helper/services/firestore_service.dart';
import 'package:cryptotax_helper/services/market_data_service.dart';

class CryptoRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final MarketDataService _marketData = MarketDataService();

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
      // Initialize user with default settings; no mock data
      await saveUserSettings(UserSettings());
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

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    await _authService.updateUserProfile(
        displayName: displayName, photoUrl: photoUrl);
    final user = _authService.currentUser;
    if (user != null) {
      // mirror the changes in Firestore user document
      await _firestoreService.createUserDocument(user);
    }
  }

  // AppTransaction.Transaction methods
  Future<void> addTransaction(AppTransaction.Transaction transaction) async {
    await _firestoreService.addTransaction(transaction);
    await _updatePortfolioCalculations();
  }

  Future<void> updateTransaction(
      String transactionId, AppTransaction.Transaction transaction) async {
    await _firestoreService.updateTransaction(transactionId, transaction);
    await _updatePortfolioCalculations();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _firestoreService.deleteTransaction(transactionId);
    await _updatePortfolioCalculations();
  }

  Stream<List<AppTransaction.Transaction>> getUserTransactions({int? limit}) =>
      _firestoreService.getUserTransactions(limit: limit);

  Stream<List<AppTransaction.Transaction>> getTransactionsByCoin(
          String coinSymbol,
          {int? limit}) =>
      _firestoreService.getTransactionsByCoin(coinSymbol, limit: limit);

  // Portfolio methods
  Stream<Portfolio?> getUserPortfolio() => _firestoreService.getUserPortfolio();

  // User Settings methods
  Future<void> saveUserSettings(UserSettings settings) =>
      _firestoreService.saveUserSettings(settings);

  Stream<UserSettings?> getUserSettings() =>
      _firestoreService.getUserSettings();

  // Account management
  Future<void> deleteAccount() async {
    await _firestoreService.deleteUserData();
    await _authService.deleteAccount();
  }

  // Helper methods
  // Removed mock data initialization

  Future<void> _updatePortfolioCalculations() async {
    // Get all user transactions
    final transactionsSnapshot = await getUserTransactions().first;

    if (transactionsSnapshot.isEmpty) return;

    // Calculate portfolio from transactions with live prices
    final portfolio =
        await _calculatePortfolioFromTransactions(transactionsSnapshot);

    // Save updated portfolio
    await _firestoreService.updatePortfolio(portfolio);
  }

  Future<Portfolio> _calculatePortfolioFromTransactions(
      List<AppTransaction.Transaction> transactions) async {
    final Map<String, double> positions = {}; // symbol -> net amount
    final Map<String, double> costBasis = {}; // symbol -> sum(cost)

    for (final t in transactions) {
      final sym = t.coinSymbol.toUpperCase();
      final signedAmount =
          t.type == AppTransaction.TransactionType.buy ? t.amount : -t.amount;
      positions[sym] = (positions[sym] ?? 0) + signedAmount;
      // Track cost basis (very simplified; ignores lots/fees)
      if (t.type == AppTransaction.TransactionType.buy) {
        costBasis[sym] = (costBasis[sym] ?? 0) + (t.amount * t.pricePerUnit);
      } else {
        costBasis[sym] = (costBasis[sym] ?? 0) - (t.amount * t.pricePerUnit);
      }
    }

    // Filter positive holdings
    final heldSymbols =
        positions.entries.where((e) => e.value > 0).map((e) => e.key).toList();
    if (heldSymbols.isEmpty) {
      return Portfolio(
        totalValue: 0,
        totalProfitLoss: 0,
        estimatedTaxDue: 0,
        holdings: [],
        recentTransactions: transactions.take(10).toList(),
      );
    }

    // Get live prices
    final prices = await _marketData.getPricesUsd(heldSymbols);

    double totalValue = 0.0;
    final List<CoinHolding> holdings = [];
    for (final sym in heldSymbols) {
      final amount = positions[sym] ?? 0;
      final price = prices[sym] ?? 0;
      final value = amount * price;
      totalValue += value;
      final basis = costBasis[sym] ?? 0;
      final pnl = value - basis; // extremely simplified PnL
      holdings.add(CoinHolding(
        coinName: sym, // Optionally map to full name later
        coinSymbol: sym,
        amount: amount,
        currentPrice: price,
        profitLoss: pnl,
        percentage: 0, // fill later
      ));
    }

    // Fill percentages
    final updatedHoldings = holdings.map((h) {
      final pct = totalValue > 0 ? (h.totalValue / totalValue) * 100 : 0.0;
      return CoinHolding(
        coinName: h.coinName,
        coinSymbol: h.coinSymbol,
        amount: h.amount,
        currentPrice: h.currentPrice,
        profitLoss: h.profitLoss,
        percentage: pct,
      );
    }).toList();

    final totalProfitLoss =
        updatedHoldings.fold(0.0, (sum, h) => sum + h.profitLoss);
    final estimatedTaxDue = totalProfitLoss > 0
        ? totalProfitLoss * 0.2
        : 0.0; // placeholder tax rate

    return Portfolio(
      totalValue: totalValue,
      totalProfitLoss: totalProfitLoss,
      estimatedTaxDue: estimatedTaxDue,
      holdings: updatedHoldings,
      recentTransactions: transactions.take(10).toList(),
    );
  }
}
