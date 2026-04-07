/// Доменная сущность актива для списка рынка (без зависимостей от JSON / Dio).
class CryptoAssetEntity {
  const CryptoAssetEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPriceUsd,
    required this.priceChangePercent24h,
    this.marketCapUsd,
    this.totalVolumeUsd,
    this.imageUrl,
  });

  final String id;
  final String symbol;
  final String name;
  final double currentPriceUsd;
  final double priceChangePercent24h;

  /// Рыночная капитализация в USD (`market_cap` в CoinGecko).
  final double? marketCapUsd;

  /// Объём торгов за 24 ч в USD (`total_volume` в CoinGecko).
  final double? totalVolumeUsd;

  final String? imageUrl;
}
