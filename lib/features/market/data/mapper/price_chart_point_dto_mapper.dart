import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';

extension PriceChartPointDtoMapper on PriceChartPointDto {
  PriceChartPointEntity toEntity() {
    return PriceChartPointEntity(
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      priceUsd: priceUsd,
    );
  }
}
