import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_detail_entity.dart';

extension CoinDetailCacheModelMapper on CoinDetailCacheModel {
  CoinDetailEntity toEntity() {
    return CoinDetailEntity(
      id: id,
      symbol: symbol.toUpperCase(),
      name: name,
      description: description,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      imageUrl: imageUrl.nonEmpty,
    );
  }
}
