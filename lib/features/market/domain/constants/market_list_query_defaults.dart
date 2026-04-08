/// Значения по умолчанию для запросов на рынке.
abstract final class MarketListQueryDefaults {
  MarketListQueryDefaults._();

  static const String vsCurrency = 'usd';
  static const int page = 1;
  static const int perPage = 50;
  static const String order = 'market_cap_desc';
}
