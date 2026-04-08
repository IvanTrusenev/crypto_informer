import 'package:crypto_informer/features/market/data/models/coin_description_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_image_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_market_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'crypto_coin_detail_dto.g.dart';

/// Сетевая модель деталей монеты (CoinGecko `/coins/{id}`).
@JsonSerializable(createToJson: false)
class CryptoCoinDetailDto {
  const CryptoCoinDetailDto({
    required this.id,
    required this.symbol,
    required this.name,
    this.description,
    this.image,
    this.marketData,
  });

  factory CryptoCoinDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CryptoCoinDetailDtoFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String symbol;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(fromJson: CoinDescriptionDto.fromJson)
  final CoinDescriptionDto? description;

  final CoinImageDto? image;

  @JsonKey(name: 'market_data')
  final CoinMarketDataDto? marketData;
}
