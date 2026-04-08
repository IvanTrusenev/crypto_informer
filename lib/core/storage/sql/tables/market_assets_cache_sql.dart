/// SQL-доступ к таблице кэша списка рынка (`market_assets_cache`).
abstract class MarketAssetsCacheSql {
  Future<String?> readPayload(String vsCurrency);

  Future<void> replacePayload(String vsCurrency, String payload);
}
