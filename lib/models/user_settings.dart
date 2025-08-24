enum Currency { usd, eur, inr, gbp, cad, aud, jpy }

extension CurrencyExtension on Currency {
  String get displayName {
    switch (this) {
      case Currency.usd:
        return 'USD (\$)';
      case Currency.eur:
        return 'EUR (€)';
      case Currency.inr:
        return 'INR (₹)';
      case Currency.gbp:
        return 'GBP (£)';
      case Currency.cad:
        return 'CAD (C\$)';
      case Currency.aud:
        return 'AUD (A\$)';
      case Currency.jpy:
        return 'JPY (¥)';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.inr:
        return '₹';
      case Currency.gbp:
        return '£';
      case Currency.cad:
        return 'C\$';
      case Currency.aud:
        return 'A\$';
      case Currency.jpy:
        return '¥';
    }
  }
}

class UserSettings {
  final Currency currency;
  final double taxRate;
  final bool isDarkMode;

  UserSettings({
    this.currency = Currency.usd,
    this.taxRate = 20.0,
    this.isDarkMode = true,
  });

  Map<String, dynamic> toJson() => {
    'currency': currency.toString(),
    'taxRate': taxRate,
    'isDarkMode': isDarkMode,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    currency: Currency.values.firstWhere(
      (e) => e.toString() == json['currency'],
      orElse: () => Currency.usd,
    ),
    taxRate: json['taxRate']?.toDouble() ?? 20.0,
    isDarkMode: json['isDarkMode'] ?? true,
  );

  UserSettings copyWith({
    Currency? currency,
    double? taxRate,
    bool? isDarkMode,
  }) => UserSettings(
    currency: currency ?? this.currency,
    taxRate: taxRate ?? this.taxRate,
    isDarkMode: isDarkMode ?? this.isDarkMode,
  );
}