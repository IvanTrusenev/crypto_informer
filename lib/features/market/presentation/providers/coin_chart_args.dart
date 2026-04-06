import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:flutter/foundation.dart';

/// Ключ провайдера графика цены: монета и выбранный период.
@immutable
class CoinChartArgs {
  const CoinChartArgs({
    required this.coinId,
    required this.period,
  });

  final String coinId;
  final ChartPeriod period;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinChartArgs &&
          coinId == other.coinId &&
          period == other.period;

  @override
  int get hashCode => Object.hash(coinId, period);
}
