import 'package:froom/froom.dart';

@Entity(tableName: 'coin_detail_cache')
class CoinDetailCacheRecord {
  const CoinDetailCacheRecord({
    required this.id,
    required this.updatedAt,
    required this.symbol,
    required this.name,
    this.description,
    this.currentPriceUsd,
    this.priceChangePercent24h,
    this.imageUrl,
  });

  @primaryKey
  final String id;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  final String symbol;

  final String name;

  final String? description;

  @ColumnInfo(name: 'current_price_usd')
  final double? currentPriceUsd;

  @ColumnInfo(name: 'price_change_percent_24h')
  final double? priceChangePercent24h;

  @ColumnInfo(name: 'image_url')
  final String? imageUrl;
}
