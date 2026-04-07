// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_coin_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CryptoCoinDetailDto _$CryptoCoinDetailDtoFromJson(Map<String, dynamic> json) =>
    CryptoCoinDetailDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as Map<String, dynamic>?,
      image: json['image'] == null
          ? null
          : CoinImageDto.fromJson(json['image'] as Map<String, dynamic>),
      marketData: json['market_data'] == null
          ? null
          : CoinMarketDataDto.fromJson(
              json['market_data'] as Map<String, dynamic>,
            ),
    );
