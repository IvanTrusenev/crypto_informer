// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_market_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinMarketDataDto _$CoinMarketDataDtoFromJson(Map<String, dynamic> json) =>
    CoinMarketDataDto(
      currentPrice: json['current_price'] as Map<String, dynamic>?,
      priceChangePercentage24h: (json['price_change_percentage_24h'] as num?)
          ?.toDouble(),
    );
