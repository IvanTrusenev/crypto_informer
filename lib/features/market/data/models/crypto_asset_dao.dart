/// Локальная data-модель актива рынка.
class CryptoAssetDao {
  const CryptoAssetDao({
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

  final double? marketCapUsd;

  final String? imageUrl;
}
