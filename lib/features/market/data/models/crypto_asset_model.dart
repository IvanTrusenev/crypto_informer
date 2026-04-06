import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';

class CryptoAssetModel {
  const CryptoAssetModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPriceUsd,
    required this.priceChangePercent24h,
    this.imageUrl,
  });

  factory CryptoAssetModel.fromJson(Map<String, dynamic> json) {
    return CryptoAssetModel(
      id: json['id'] as String? ?? '',
      symbol: (json['symbol'] as String? ?? '').toUpperCase(),
      name: json['name'] as String? ?? '',
      currentPriceUsd: (json['current_price'] as num?)?.toDouble() ?? 0,
      priceChangePercent24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      imageUrl: (json['image'] as String?)?.isEmpty ?? true
          ? null
          : json['image'] as String,
    );
  }

  final String id;
  final String symbol;
  final String name;
  final double currentPriceUsd;
  final double priceChangePercent24h;
  final String? imageUrl;

  CryptoAsset toEntity() {
    return CryptoAsset(
      id: id,
      symbol: symbol,
      name: name,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      imageUrl: imageUrl,
    );
  }
}
