/// SQL-доступ к таблице кэша карточки монеты (`coin_detail_cache`).
abstract class CoinDetailCacheSql {
  Future<String?> readPayload(String coinId);

  Future<void> savePayload(String coinId, String payload);
}
