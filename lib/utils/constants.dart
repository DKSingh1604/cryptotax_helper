import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'CryptoTax Helper';
  static const String appVersion = '1.0.0';
  
  // Animations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Layout
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  
  // Form validation
  static const int minPasswordLength = 6;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Crypto coins dropdown options
  static const List<Map<String, String>> availableCoins = [
    {'name': 'Bitcoin', 'symbol': 'BTC'},
    {'name': 'Ethereum', 'symbol': 'ETH'},
    {'name': 'Cardano', 'symbol': 'ADA'},
    {'name': 'Solana', 'symbol': 'SOL'},
    {'name': 'Polygon', 'symbol': 'MATIC'},
    {'name': 'Chainlink', 'symbol': 'LINK'},
    {'name': 'Polkadot', 'symbol': 'DOT'},
    {'name': 'Avalanche', 'symbol': 'AVAX'},
    {'name': 'Binance Coin', 'symbol': 'BNB'},
    {'name': 'XRP', 'symbol': 'XRP'},
  ];
  
  // Default values
  static const double defaultTaxRate = 20.0;
  static const int transactionsPerPage = 20;
  static const int maxRecentTransactions = 5;
}

class AppStrings {
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String transactions = 'Transactions';
  static const String analytics = 'Analytics';
  static const String settings = 'Settings';
  
  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String signInWithGoogle = 'Sign in with Google';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  
  // Dashboard
  static const String totalPortfolioValue = 'Total Portfolio Value';
  static const String totalProfitLoss = 'Total Profit/Loss';
  static const String estimatedTaxDue = 'Estimated Tax Due';
  static const String recentTransactions = 'Recent Transactions';
  static const String seeAll = 'See All';
  static const String addTransaction = 'Add Transaction';
  
  // Transactions
  static const String filterBy = 'Filter By';
  static const String allCoins = 'All Coins';
  static const String buyTransactions = 'Buy';
  static const String sellTransactions = 'Sell';
  static const String dateRange = 'Date Range';
  static const String amount = 'Amount';
  static const String pricePerUnit = 'Price per Unit';
  static const String totalValue = 'Total Value';
  static const String selectDate = 'Select Date';
  static const String selectCoin = 'Select Coin';
  
  // Settings
  static const String currency = 'Currency';
  static const String taxRate = 'Tax Rate (%)';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String themeMode = 'Theme Mode';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  
  // Errors
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsMismatch = 'Passwords do not match';
  static const String fieldRequired = 'This field is required';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String invalidPrice = 'Please enter a valid price';
  
  // Success
  static const String transactionAdded = 'Transaction added successfully';
  static const String settingsSaved = 'Settings saved successfully';
}