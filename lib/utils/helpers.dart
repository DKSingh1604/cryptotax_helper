import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cryptotax_helper/models/user_settings.dart';

class Helpers {
  // Date formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }
  
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }
  
  // Currency formatting
  static String formatCurrency(double amount, Currency currency) {
    final symbol = currency.symbol;
    if (amount.abs() >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }
  
  static String formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return amount.toStringAsFixed(4);
    }
  }
  
  static String formatPercentage(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(2)}%';
  }
  
  // Color helpers
  static Color getProfitLossColor(double value, bool isDarkMode) {
    if (value >= 0) {
      return isDarkMode 
          ? const Color(0xFF00E676) // Green for profit
          : const Color(0xFF2E7D32);
    } else {
      return isDarkMode 
          ? const Color(0xFFFF5252) // Red for loss
          : const Color(0xFFC62828);
    }
  }
  
  static IconData getProfitLossIcon(double value) {
    return value >= 0 ? Icons.trending_up : Icons.trending_down;
  }
  
  // Input validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    
    final double? amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    
    return null;
  }
  
  static String? validateTaxRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a tax rate';
    }
    
    final double? rate = double.tryParse(value);
    if (rate == null || rate < 0 || rate > 100) {
      return 'Please enter a valid tax rate (0-100)';
    }
    
    return null;
  }
  
  // Snackbar helpers
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // Debounce helper for search
  static void debounce(Function func, Duration delay) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, () => func());
  }
}