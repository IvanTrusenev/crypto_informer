// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_asset_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoAssetDao _$CryptoAssetDaoFromJson(Map<String, dynamic> json) =>
    CryptoAssetDao(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      currentPriceUsd: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      priceChangePercent24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      marketCapUsd: (json['market_cap'] as num?)?.toDouble(),
      imageUrl: json['image'] as String?,
    );

Map<String, dynamic> _$CryptoAssetDaoToJson(CryptoAssetDao instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'name': instance.name,
      'current_price': instance.currentPriceUsd,
      'price_change_percentage_24h': instance.priceChangePercent24h,
      'market_cap': instance.marketCapUsd,
      'image': instance.imageUrl,
    };
