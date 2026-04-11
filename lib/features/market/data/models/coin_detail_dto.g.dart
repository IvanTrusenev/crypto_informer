// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinDetailDto _$CoinDetailDtoFromJson(Map<String, dynamic> json) =>
    CoinDetailDto(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: CoinDescriptionDto.fromJson(json['description']),
      image: json['image'] == null
          ? null
          : CoinImageDto.fromJson(json['image'] as Map<String, dynamic>),
      marketData: json['market_data'] == null
          ? null
          : CoinMarketDataDto.fromJson(
              json['market_data'] as Map<String, dynamic>,
            ),
    );
