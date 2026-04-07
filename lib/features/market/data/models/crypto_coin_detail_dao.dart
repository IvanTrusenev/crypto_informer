import 'package:json_annotation/json_annotation.dart';

part 'crypto_coin_detail_dao.g.dart';

/// Модель кэша (SQLite) для деталей монеты.
@JsonSerializable()
class CryptoCoinDetailDao {
  const CryptoCoinDetailDao({
    required this.id,
    required this.symbol,
    required this.name,
    this.description,
    this.currentPriceUsd,
    this.priceChangePercent24h,
    this.imageUrl,
  });

  factory CryptoCoinDetailDao.fromJson(Map<String, dynamic> json) =>
      _$CryptoCoinDetailDaoFromJson(json);

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String symbol;

  @JsonKey(defaultValue: '')
  final String name;

  final String? description;

  @JsonKey(name: 'current_price_usd')
  final double? currentPriceUsd;

  @JsonKey(name: 'price_change_percentage_24h')
  final double? priceChangePercent24h;

  @JsonKey(name: 'image')
  final String? imageUrl;

  Map<String, dynamic> toJson() => _$CryptoCoinDetailDaoToJson(this);
}
