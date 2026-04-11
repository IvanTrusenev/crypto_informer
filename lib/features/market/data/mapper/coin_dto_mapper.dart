import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/coin_dto.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';

extension CoinDtoMapper on CoinDto {
  CoinEntity toEntity() {
    return CoinEntity(
      id: id,
      symbol: symbol.toUpperCase(),
      name: name,
      currentPriceUsd: currentPriceUsd,
      priceChangePercent24h: priceChangePercent24h,
      marketCapUsd: marketCapUsd,
      totalVolumeUsd: totalVolumeUsd,
      imageUrl: imageUrl.nonEmpty,
    );
  }
}
