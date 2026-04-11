import 'package:froom/froom.dart';

@Entity(tableName: 'market_assets_cache')
class MarketAssetCacheRecord {
  const MarketAssetCacheRecord({
    required this.cacheKey,
    required this.id,
    required this.vsCurrency,
    required this.sortOrder,
    required this.updatedAt,
    required this.symbol,
    required this.name,
    required this.currentPriceUsd,
    required this.priceChangePercent24h,
    this.marketCapUsd,
    this.imageUrl,
  });

  @primaryKey
  @ColumnInfo(name: 'cache_key')
  final String cacheKey;

  final String id;

  @ColumnInfo(name: 'vs_currency')
  final String vsCurrency;

  @ColumnInfo(name: 'sort_order')
  final int sortOrder;

  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  final String symbol;

  final String name;

  @ColumnInfo(name: 'current_price_usd')
  final double currentPriceUsd;

  @ColumnInfo(name: 'price_change_percent_24h')
  final double priceChangePercent24h;

  @ColumnInfo(name: 'market_cap_usd')
  final double? marketCapUsd;

  @ColumnInfo(name: 'image_url')
  final String? imageUrl;
}
