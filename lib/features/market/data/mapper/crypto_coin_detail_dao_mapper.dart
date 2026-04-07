import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';

extension CryptoCoinDetailDaoMapper on CryptoCoinDetailDao {
  CryptoCoinDetailEntity toEntity() {
    return CryptoCoinDetailEntity(
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
