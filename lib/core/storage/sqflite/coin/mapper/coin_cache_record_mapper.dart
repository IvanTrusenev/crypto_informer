import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_record.dart';
import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';

extension CoinCacheRecordMapper on CoinCacheRecord {
  CoinCacheModel toCacheModel() {
    return CoinCacheModel(
      id: id,
      symbol: symbol,
      name: name,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      marketCapUsd: marketCapUsd,
      imageUrl: imageUrl,
    );
  }
}
