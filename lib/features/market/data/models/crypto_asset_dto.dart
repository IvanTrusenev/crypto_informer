import 'package:json_annotation/json_annotation.dart';

part 'crypto_asset_dto.g.dart';

/// Сетевая модель актива (CoinGecko `/coins/markets`).
@JsonSerializable(createToJson: false)
class CryptoAssetDto {
  const CryptoAssetDto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPriceUsd,
    required this.priceChangePercent24h,
    this.marketCapUsd,
    this.totalVolumeUsd,
    this.imageUrl,
  });

  factory CryptoAssetDto.fromJson(Map<String, dynamic> json) =>
      _$CryptoAssetDtoFromJson(json);

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

  @JsonKey(name: 'total_volume')
  final double? totalVolumeUsd;

  @JsonKey(name: 'image')
  final String? imageUrl;
}
