import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_record.dart';
import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';

extension CoinCacheModelMapper on CoinCacheModel {
  CoinCacheRecord toCacheRecord({
    required String vsCurrency,
    required int sortOrder,
    required int updatedAt,
  }) {
    return CoinCacheRecord(
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
