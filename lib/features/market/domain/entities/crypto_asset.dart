/// Доменная сущность актива для списка рынка (без зависимостей от JSON / Dio).
class CryptoAsset {
  const CryptoAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPriceUsd,
    required this.priceChangePercent24h,
    this.marketCapUsd,
    this.imageUrl,
  });

  final String id;
  final String symbol;
  final String name;
  final double currentPriceUsd;
  final double priceChangePercent24h;

  /// Рыночная капитализация в USD (`market_cap` в CoinGecko).
  /// Может отсутствовать.
  final double? marketCapUsd;

  final String? imageUrl;
}
