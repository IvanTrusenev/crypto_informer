import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';

extension CryptoAssetDtoMapper on CryptoAssetDto {
  CryptoAssetEntity toEntity() {
    return CryptoAssetEntity(
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
