import 'package:json_annotation/json_annotation.dart';

part 'crypto_asset_dao.g.dart';

/// Модель кэша (SQLite) для актива рынка.
@JsonSerializable()
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

  factory CryptoAssetDao.fromJson(Map<String, dynamic> json) =>
      _$CryptoAssetDaoFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String symbol;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(name: 'current_price', defaultValue: 0.0)
  final double currentPriceUsd;

  @JsonKey(name: 'price_change_percentage_24h', defaultValue: 0.0)
  final double priceChangePercent24h;

  @JsonKey(name: 'market_cap')
  final double? marketCapUsd;

  @JsonKey(name: 'image')
  final String? imageUrl;

  Map<String, dynamic> toJson() => _$CryptoAssetDaoToJson(this);
}
