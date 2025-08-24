import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cryptotax_helper/firestore/firestore_data_schema.dart';
import 'package:cryptotax_helper/models/transaction.dart' as AppTransaction;
import 'package:cryptotax_helper/models/portfolio.dart';
import 'package:cryptotax_helper/models/user_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // User Management
  Future<void> createUserDocument(User user) async {
    if (user.uid.isEmpty) return;

    try {
      await _firestore.collection(FirestoreCollections.users).doc(user.uid).set({
        UserDocument.email: user.email,
        UserDocument.displayName: user.displayName ?? '',
        UserDocument.photoUrl: user.photoURL ?? '',
        UserDocument.createdAt: FieldValue.serverTimestamp(),
        UserDocument.updatedAt: FieldValue.serverTimestamp(),
        UserDocument.lastLoginAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  Future<void> updateLastLoginTime() async {
    if (_currentUserId == null) return;

    try {
      await _firestore.collection(FirestoreCollections.users).doc(_currentUserId).update({
        UserDocument.lastLoginAt: FieldValue.serverTimestamp(),
        UserDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login time: $e');
    }
  }

  // Transaction Management
  Future<void> addTransaction(AppTransaction.Transaction transaction) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final docRef = _firestore.collection(FirestoreCollections.transactions).doc();
      
      await docRef.set({
        TransactionDocument.id: docRef.id,
        TransactionDocument.userId: _currentUserId,
        TransactionDocument.coinName: transaction.coinName,
        TransactionDocument.coinSymbol: transaction.coinSymbol,
        TransactionDocument.type: transaction.type.name,
        TransactionDocument.amount: transaction.amount,
        TransactionDocument.pricePerUnit: transaction.pricePerUnit,
        TransactionDocument.totalValue: transaction.totalValue,
        TransactionDocument.date: Timestamp.fromDate(transaction.date),
        TransactionDocument.createdAt: FieldValue.serverTimestamp(),
        TransactionDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(String transactionId, AppTransaction.Transaction transaction) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _firestore.collection(FirestoreCollections.transactions).doc(transactionId).update({
        TransactionDocument.coinName: transaction.coinName,
        TransactionDocument.coinSymbol: transaction.coinSymbol,
        TransactionDocument.type: transaction.type.name,
        TransactionDocument.amount: transaction.amount,
        TransactionDocument.pricePerUnit: transaction.pricePerUnit,
        TransactionDocument.totalValue: transaction.totalValue,
        TransactionDocument.date: Timestamp.fromDate(transaction.date),
        TransactionDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection(FirestoreCollections.transactions).doc(transactionId).delete();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Stream<List<AppTransaction.Transaction>> getUserTransactions({int? limit}) {
    if (_currentUserId == null) return Stream.value([]);

    Query query = _firestore
        .collection(FirestoreCollections.transactions)
        .where(TransactionDocument.userId, isEqualTo: _currentUserId)
        .orderBy(TransactionDocument.date, descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppTransaction.Transaction(
          id: data[TransactionDocument.id] ?? doc.id,
          coinName: data[TransactionDocument.coinName] ?? '',
          coinSymbol: data[TransactionDocument.coinSymbol] ?? '',
          type: AppTransaction.TransactionType.values.firstWhere(
            (e) => e.name == data[TransactionDocument.type],
            orElse: () => AppTransaction.TransactionType.buy,
          ),
          amount: (data[TransactionDocument.amount] ?? 0.0).toDouble(),
          pricePerUnit: (data[TransactionDocument.pricePerUnit] ?? 0.0).toDouble(),
          date: (data[TransactionDocument.date] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  Stream<List<AppTransaction.Transaction>> getTransactionsByCoin(String coinSymbol, {int? limit}) {
    if (_currentUserId == null) return Stream.value([]);

    Query query = _firestore
        .collection(FirestoreCollections.transactions)
        .where(TransactionDocument.userId, isEqualTo: _currentUserId)
        .where(TransactionDocument.coinSymbol, isEqualTo: coinSymbol)
        .orderBy(TransactionDocument.date, descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AppTransaction.Transaction(
          id: data[TransactionDocument.id] ?? doc.id,
          coinName: data[TransactionDocument.coinName] ?? '',
          coinSymbol: data[TransactionDocument.coinSymbol] ?? '',
          type: AppTransaction.TransactionType.values.firstWhere(
            (e) => e.name == data[TransactionDocument.type],
            orElse: () => AppTransaction.TransactionType.buy,
          ),
          amount: (data[TransactionDocument.amount] ?? 0.0).toDouble(),
          pricePerUnit: (data[TransactionDocument.pricePerUnit] ?? 0.0).toDouble(),
          date: (data[TransactionDocument.date] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  // Portfolio Management
  Future<void> updatePortfolio(Portfolio portfolio) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _firestore.collection(FirestoreCollections.portfolios).doc(_currentUserId).set({
        PortfolioDocument.userId: _currentUserId,
        PortfolioDocument.totalValue: portfolio.totalValue,
        PortfolioDocument.totalProfitLoss: portfolio.totalProfitLoss,
        PortfolioDocument.estimatedTaxDue: portfolio.estimatedTaxDue,
        PortfolioDocument.holdings: portfolio.holdings.map((holding) => {
          CoinHoldingDocument.coinName: holding.coinName,
          CoinHoldingDocument.coinSymbol: holding.coinSymbol,
          CoinHoldingDocument.amount: holding.amount,
          CoinHoldingDocument.currentPrice: holding.currentPrice,
          CoinHoldingDocument.totalValue: holding.totalValue,
          CoinHoldingDocument.profitLoss: holding.profitLoss,
          CoinHoldingDocument.percentage: holding.percentage,
        }).toList(),
        PortfolioDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating portfolio: $e');
      rethrow;
    }
  }

  Stream<Portfolio?> getUserPortfolio() {
    if (_currentUserId == null) return Stream.value(null);

    return _firestore
        .collection(FirestoreCollections.portfolios)
        .doc(_currentUserId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final data = doc.data()!;
      final holdingsData = data[PortfolioDocument.holdings] as List<dynamic>? ?? [];
      
      return Portfolio(
        totalValue: (data[PortfolioDocument.totalValue] ?? 0.0).toDouble(),
        totalProfitLoss: (data[PortfolioDocument.totalProfitLoss] ?? 0.0).toDouble(),
        estimatedTaxDue: (data[PortfolioDocument.estimatedTaxDue] ?? 0.0).toDouble(),
        holdings: holdingsData.map((holdingMap) {
          final holding = holdingMap as Map<String, dynamic>;
          return CoinHolding(
            coinName: holding[CoinHoldingDocument.coinName] ?? '',
            coinSymbol: holding[CoinHoldingDocument.coinSymbol] ?? '',
            amount: (holding[CoinHoldingDocument.amount] ?? 0.0).toDouble(),
            currentPrice: (holding[CoinHoldingDocument.currentPrice] ?? 0.0).toDouble(),
            profitLoss: (holding[CoinHoldingDocument.profitLoss] ?? 0.0).toDouble(),
            percentage: (holding[CoinHoldingDocument.percentage] ?? 0.0).toDouble(),
          );
        }).toList(),
        recentTransactions: [], // This will be loaded separately
      );
    });
  }

  // User Settings Management
  Future<void> saveUserSettings(UserSettings settings) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _firestore.collection(FirestoreCollections.userSettings).doc(_currentUserId).set({
        UserSettingsDocument.userId: _currentUserId,
        UserSettingsDocument.currency: settings.currency.name,
        UserSettingsDocument.taxRate: settings.taxRate,
        UserSettingsDocument.isDarkMode: settings.isDarkMode,
        UserSettingsDocument.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving user settings: $e');
      rethrow;
    }
  }

  Stream<UserSettings?> getUserSettings() {
    if (_currentUserId == null) return Stream.value(null);

    return _firestore
        .collection(FirestoreCollections.userSettings)
        .doc(_currentUserId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserSettings(
        currency: Currency.values.firstWhere(
          (e) => e.name == data[UserSettingsDocument.currency],
          orElse: () => Currency.usd,
        ),
        taxRate: (data[UserSettingsDocument.taxRate] ?? 20.0).toDouble(),
        isDarkMode: data[UserSettingsDocument.isDarkMode] ?? true,
      );
    });
  }

  // Cleanup user data when account is deleted
  Future<void> deleteUserData() async {
    if (_currentUserId == null) return;

    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection(FirestoreCollections.users).doc(_currentUserId!));

      // Delete portfolio
      batch.delete(_firestore.collection(FirestoreCollections.portfolios).doc(_currentUserId!));

      // Delete user settings
      batch.delete(_firestore.collection(FirestoreCollections.userSettings).doc(_currentUserId!));

      // Delete all transactions
      final transactionsQuery = await _firestore
          .collection(FirestoreCollections.transactions)
          .where(TransactionDocument.userId, isEqualTo: _currentUserId)
          .get();

      for (final doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }
}