import 'package:crypto_informer/core/extensions/string_extensions.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_dto.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_detail_entity.dart';

extension CoinDetailDtoMapper on CoinDetailDto {
  CoinDetailEntity toEntity() {
    return CoinDetailEntity(
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
