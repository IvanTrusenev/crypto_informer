import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';

sealed class CoinPriceChartState {
  const CoinPriceChartState({required this.period});
  final ChartPeriodEnum period;
}

class CoinPriceChartInitial extends CoinPriceChartState {
  const CoinPriceChartInitial({super.period = ChartPeriodEnum.days7});
}

class CoinPriceChartLoading extends CoinPriceChartState {
  const CoinPriceChartLoading({required super.period});
}

class CoinPriceChartLoaded extends CoinPriceChartState {
  CoinPriceChartLoaded(this.points, {required super.period});
  final List<PriceChartPointEntity> points;
}

class CoinPriceChartError extends CoinPriceChartState {
  const CoinPriceChartError(this.error, {required super.period});
  final Object error;
}
