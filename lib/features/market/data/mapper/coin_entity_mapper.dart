import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';

extension CoinEntityMapper on CoinEntity {
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
