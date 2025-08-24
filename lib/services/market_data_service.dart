import 'dart:convert';
import 'dart:collection';
import 'package:http/http.dart' as http;

/// Fetches live crypto market data from CoinGecko (no API key required).
/// Note: Respect rate limits; basic caching is used here.
class MarketDataService {
  static const String _base = 'https://api.coingecko.com/api/v3';

  // Cache symbol (uppercased) -> coingecko id
  final Map<String, String> _symbolToId = HashMap();
  DateTime? _lastCoinsSync;

  // A tiny built-in map for popular coins to avoid first network hit
  static const Map<String, String> _bootstrap = {
    'BTC': 'bitcoin',
    'ETH': 'ethereum',
    'ADA': 'cardano',
    'SOL': 'solana',
    'MATIC': 'matic-network',
    'LINK': 'chainlink',
    'DOT': 'polkadot',
    'AVAX': 'avalanche-2',
    'USDT': 'tether',
    'USDC': 'usd-coin',
    'XRP': 'ripple',
    'DOGE': 'dogecoin',
    'TRX': 'tron',
    'TON': 'the-open-network',
    'BCH': 'bitcoin-cash',
    'LTC': 'litecoin',
  };

  MarketDataService() {
    _symbolToId.addAll(_bootstrap);
  }

  Future<void> _ensureCoinMapLoaded({bool force = false}) async {
    // Refresh coin list daily or when forced
    final now = DateTime.now();
    if (!force &&
        _lastCoinsSync != null &&
        now.difference(_lastCoinsSync!).inHours < 24) {
      return;
    }

    final uri = Uri.parse('$_base/coins/list?include_platform=false');
    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) return; // Keep existing map on failure

    final List<dynamic> coins = jsonDecode(resp.body) as List<dynamic>;
    for (final c in coins) {
      final map = c as Map<String, dynamic>;
      final id = (map['id'] ?? '').toString();
      final symbol = (map['symbol'] ?? '').toString().toUpperCase();
      if (id.isEmpty || symbol.isEmpty) continue;
      // Prefer keeping bootstrap mappings; only fill gaps
      _symbolToId.putIfAbsent(symbol, () => id);
    }
    _lastCoinsSync = now;
  }

  /// Returns a map of SYMBOL -> priceUSD.
  Future<Map<String, double>> getPricesUsd(List<String> symbols) async {
    if (symbols.isEmpty) return {};

    // Load mapping if needed
    final missing = symbols
        .where((s) => !_symbolToId.containsKey(s.toUpperCase()))
        .toList();
    if (missing.isNotEmpty) {
      await _ensureCoinMapLoaded();
    }

    final ids = symbols
        .map((s) => _symbolToId[s.toUpperCase()])
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toList();

    if (ids.isEmpty) return {};

    // CoinGecko simple price endpoint
    final uri =
        Uri.parse('$_base/simple/price?ids=${ids.join(',')}&vs_currencies=usd');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) return {};

    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;

    // Map back to symbols
    final Map<String, double> out = {};
    for (final symbol in symbols) {
      final id = _symbolToId[symbol.toUpperCase()];
      if (id == null) continue;
      final entry = data[id] as Map<String, dynamic>?;
      final price = (entry?['usd'] as num?)?.toDouble();
      if (price != null) out[symbol.toUpperCase()] = price;
    }
    return out;
  }
}
