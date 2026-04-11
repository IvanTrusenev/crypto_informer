/// Локальная data-модель деталей монеты.
class CoinDetailCacheModel {
  const CoinDetailCacheModel({
    required this.id,
    required this.symbol,
    required this.name,
    this.description,
    this.currentPriceUsd,
    this.priceChangePercent24h,
    this.imageUrl,
  });

  final String id;

  final String symbol;

  final String name;

  final String? description;

  final double? currentPriceUsd;

  final double? priceChangePercent24h;

  final String? imageUrl;
}
