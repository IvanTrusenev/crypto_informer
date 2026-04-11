import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';

extension CoinCacheModelMapper on CoinCacheModel {
  CoinEntity toEntity() {
    return CoinEntity(
      id: id,
      symbol: symbol.toUpperCase(),
      name: name,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      marketCapUsd: marketCapUsd,
      imageUrl: imageUrl.nonEmpty,
    );
  }
}
