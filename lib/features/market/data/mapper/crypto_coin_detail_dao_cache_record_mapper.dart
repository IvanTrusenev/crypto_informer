import 'package:crypto_informer/core/storage/sqflite/tables/coin_detail_cache_record.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';

extension CryptoCoinDetailDaoCacheRecordMapper on CryptoCoinDetailDao {
  CoinDetailCacheRecord toCacheRecord({
    required int updatedAt,
  }) {
    return CoinDetailCacheRecord(
      id: id,
      updatedAt: updatedAt,
      symbol: symbol,
      name: name,
      description: description,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      imageUrl: imageUrl,
    );
  }
}
