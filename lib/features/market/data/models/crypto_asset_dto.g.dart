// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_asset_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoAssetDto _$CryptoAssetDtoFromJson(Map<String, dynamic> json) =>
    CryptoAssetDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      currentPriceUsd: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      priceChangePercent24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      marketCapUsd: (json['market_cap'] as num?)?.toDouble(),
      totalVolumeUsd: (json['total_volume'] as num?)?.toDouble(),
      imageUrl: json['image'] as String?,
    );
