import 'package:json_annotation/json_annotation.dart';

part 'coin_market_data_dto.g.dart';

/// Вложенная сетевая модель рыночных данных монеты.
@JsonSerializable(createToJson: false)
class CoinMarketDataDto {
  const CoinMarketDataDto({
    this.currentPrice,
    this.priceChangePercentage24h,
  });

  factory CoinMarketDataDto.fromJson(Map<String, dynamic> json) =>
      _$CoinMarketDataDtoFromJson(json);

  @JsonKey(name: 'current_price')
  final Map<String, dynamic>? currentPrice;

  @JsonKey(name: 'price_change_percentage_24h')
  final double? priceChangePercentage24h;
}
