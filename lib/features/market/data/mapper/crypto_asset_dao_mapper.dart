import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';

extension CryptoAssetDaoMapper on CryptoAssetDao {
  CryptoAssetEntity toEntity() {
    return CryptoAssetEntity(
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
