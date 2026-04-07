// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_coin_detail_dao.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoCoinDetailDao _$CryptoCoinDetailDaoFromJson(Map<String, dynamic> json) =>
    CryptoCoinDetailDao(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      currentPriceUsd: (json['current_price_usd'] as num?)?.toDouble(),
      priceChangePercent24h: (json['price_change_percentage_24h'] as num?)
          ?.toDouble(),
      imageUrl: json['image'] as String?,
    );

Map<String, dynamic> _$CryptoCoinDetailDaoToJson(
  CryptoCoinDetailDao instance,
) => <String, dynamic>{
  'id': instance.id,
  'symbol': instance.symbol,
  'name': instance.name,
  'description': instance.description,
  'current_price_usd': instance.currentPriceUsd,
  'price_change_percentage_24h': instance.priceChangePercent24h,
  'image': instance.imageUrl,
};
