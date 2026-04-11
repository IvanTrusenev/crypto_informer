import 'package:crypto_informer/core/storage/sqflite/coin_detail/coin_detail_cache_record.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';

extension CoinDetailCacheRecordMapper on CoinDetailCacheRecord {
  CoinDetailCacheModel toCacheModel() {
    return CoinDetailCacheModel(
      id: id,
      symbol: symbol,
      name: name,
      description: description,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      imageUrl: imageUrl,
    );
  }
}
