import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';

extension CryptoCoinDetailEntityMapper on CryptoCoinDetailEntity {
  CryptoCoinDetailDao toDao() {
    return CryptoCoinDetailDao(
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
