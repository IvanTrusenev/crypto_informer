import 'package:crypto_informer/core/storage/sqflite/tables/market_asset_cache_record.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';

extension MarketAssetCacheRecordMapper on MarketAssetCacheRecord {
  CryptoAssetDao toDao() {
    return CryptoAssetDao(
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
