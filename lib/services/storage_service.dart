import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptotax_helper/models/transaction.dart';
import 'package:cryptotax_helper/models/user_settings.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';
  static const String _settingsKey = 'user_settings';
  static const String _isFirstLaunchKey = 'is_first_launch';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Transactions
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await _prefs;
    final String? transactionsJson = prefs.getString(_transactionsKey);
    
    if (transactionsJson == null) return [];
    
    final List<dynamic> transactionsList = json.decode(transactionsJson);
    return transactionsList.map((json) => Transaction.fromJson(json)).toList();
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await _prefs;
    final String transactionsJson = json.encode(
      transactions.map((transaction) => transaction.toJson()).toList(),
    );
    await prefs.setString(_transactionsKey, transactionsJson);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  static Future<void> deleteTransaction(String transactionId) async {
    final transactions = await getTransactions();
    transactions.removeWhere((transaction) => transaction.id == transactionId);
    await saveTransactions(transactions);
  }

  // User Settings
  static Future<UserSettings> getUserSettings() async {
    final prefs = await _prefs;
    final String? settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null) {
      return UserSettings(); // Return default settings
    }
    
    return UserSettings.fromJson(json.decode(settingsJson));
  }

  static Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await _prefs;
    final String settingsJson = json.encode(settings.toJson());
    await prefs.setString(_settingsKey, settingsJson);
  }

  // First launch check
  static Future<bool> isFirstLaunch() async {
    final prefs = await _prefs;
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  static Future<void> setFirstLaunchComplete() async {
    final prefs = await _prefs;
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}