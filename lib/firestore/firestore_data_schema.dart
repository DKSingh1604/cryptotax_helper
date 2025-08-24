/// Firestore Data Schema for CryptoTax Helper
/// 
/// Collections:
/// 1. users/{userId} - User profile and settings
/// 2. transactions/{transactionId} - Individual crypto transactions
/// 3. portfolios/{userId} - User portfolio summary and holdings
/// 4. userSettings/{userId} - User preferences and settings

class FirestoreCollections {
  static const String users = 'users';
  static const String transactions = 'transactions';
  static const String portfolios = 'portfolios';
  static const String userSettings = 'userSettings';
}

/// User document structure
/// Path: users/{userId}
class UserDocument {
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String createdAt = 'createdAt'; // TIMESTAMP
  static const String updatedAt = 'updatedAt'; // TIMESTAMP
  static const String lastLoginAt = 'lastLoginAt'; // TIMESTAMP
}

/// Transaction document structure
/// Path: transactions/{transactionId}
class TransactionDocument {
  static const String id = 'id';
  static const String userId = 'userId';
  static const String coinName = 'coinName';
  static const String coinSymbol = 'coinSymbol';
  static const String type = 'type'; // 'buy' or 'sell'
  static const String amount = 'amount'; // double
  static const String pricePerUnit = 'pricePerUnit'; // double
  static const String totalValue = 'totalValue'; // double
  static const String date = 'date'; // TIMESTAMP
  static const String createdAt = 'createdAt'; // TIMESTAMP
  static const String updatedAt = 'updatedAt'; // TIMESTAMP
}

/// Portfolio document structure
/// Path: portfolios/{userId}
class PortfolioDocument {
  static const String userId = 'userId';
  static const String totalValue = 'totalValue'; // double
  static const String totalProfitLoss = 'totalProfitLoss'; // double
  static const String estimatedTaxDue = 'estimatedTaxDue'; // double
  static const String holdings = 'holdings'; // array of CoinHolding objects
  static const String updatedAt = 'updatedAt'; // TIMESTAMP
}

/// CoinHolding sub-document structure (within portfolio holdings array)
class CoinHoldingDocument {
  static const String coinName = 'coinName';
  static const String coinSymbol = 'coinSymbol';
  static const String amount = 'amount'; // double
  static const String currentPrice = 'currentPrice'; // double
  static const String totalValue = 'totalValue'; // double
  static const String profitLoss = 'profitLoss'; // double
  static const String percentage = 'percentage'; // double
}

/// UserSettings document structure
/// Path: userSettings/{userId}
class UserSettingsDocument {
  static const String userId = 'userId';
  static const String currency = 'currency'; // enum string
  static const String taxRate = 'taxRate'; // double
  static const String isDarkMode = 'isDarkMode'; // boolean
  static const String updatedAt = 'updatedAt'; // TIMESTAMP
}