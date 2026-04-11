import 'package:crypto_informer/core/storage/sqflite/tables/market_asset_cache_record.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';

extension CryptoAssetDaoCacheRecordMapper on CryptoAssetDao {
  MarketAssetCacheRecord toCacheRecord({
    required String vsCurrency,
    required int sortOrder,
    required int updatedAt,
  }) {
    return MarketAssetCacheRecord(
      cacheKey: '$vsCurrency:$id',
      id: id,
      vsCurrency: vsCurrency,
      sortOrder: sortOrder,
      updatedAt: updatedAt,
      symbol: symbol,
      name: name,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      marketCapUsd: marketCapUsd,
      imageUrl: imageUrl,
    );
  }
}
