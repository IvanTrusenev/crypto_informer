import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_detail_entity.dart';

extension CoinDetailEntityMapper on CoinDetailEntity {
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
