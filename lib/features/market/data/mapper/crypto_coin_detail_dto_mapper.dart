import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';

extension CryptoCoinDetailDtoMapper on CryptoCoinDetailDto {
  CryptoCoinDetailEntity toEntity() {
    return CryptoCoinDetailEntity(
      id: id,
      symbol: symbol.toUpperCase(),
      name: name,
      description: description?.en.cleanHtml(),
      currentPriceUsd: marketData?.currentPrice?.usd,
      priceChangePercent24h: marketData?.priceChangePercentage24h,
      imageUrl: image?.large.nonEmpty,
    );
  }
}
