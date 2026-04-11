/// Базовый URL и пути CoinGecko REST API v3.
///
/// См. [документацию](https://docs.coingecko.com/reference/introduction).
abstract final class CoinGeckoEndpoints {
  CoinGeckoEndpoints._();

  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  /// `GET /coins/markets`
  static const String coinsMarkets = '/coins/markets';

  /// `GET /search`
  static const String search = '/search';

  /// `GET /coins/{id}` (шаблон для Retrofit).
  static const String coinById = '/coins/{id}';

  /// `GET /coins/{id}/market_chart` (шаблон для Retrofit).
  static const String coinMarketChart = '/coins/{id}/market_chart';

  /// Разрешённый путь для [coinById].
  static String coinPath(String id) => '/coins/$id';

  /// Разрешённый путь для [coinMarketChart].
  static String coinMarketChartPath(String id) => '/coins/$id/market_chart';
}
