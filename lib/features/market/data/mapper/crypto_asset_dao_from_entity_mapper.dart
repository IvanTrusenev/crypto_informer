import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';

extension CryptoAssetDaoFromEntityMapper on CryptoAssetEntity {
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
