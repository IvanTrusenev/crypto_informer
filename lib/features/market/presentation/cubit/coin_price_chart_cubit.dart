import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CoinPriceChartState {
  const CoinPriceChartState();
}

class CoinPriceChartInitial extends CoinPriceChartState {
  const CoinPriceChartInitial();
}

class CoinPriceChartLoading extends CoinPriceChartState {
  const CoinPriceChartLoading();
}

class CoinPriceChartLoaded extends CoinPriceChartState {
  const CoinPriceChartLoaded(this.points);
  final List<PriceChartPoint> points;
}

class CoinPriceChartError extends CoinPriceChartState {
  const CoinPriceChartError(this.error);
  final Object error;
}

class CoinPriceChartCubit extends Cubit<CoinPriceChartState> {
  CoinPriceChartCubit(this._repository)
      : super(const CoinPriceChartInitial());

  final CryptoRepository _repository;

  Future<void> loadChart(
    String coinId, {
    ChartPeriod period = ChartPeriod.days7,
  }) async {
    emit(const CoinPriceChartLoading());
    try {
      final points = await _repository.getPriceChart(
        coinId,
        period: period,
      );
      if (!isClosed) emit(CoinPriceChartLoaded(points));
    } on Object catch (e) {
      if (!isClosed) emit(CoinPriceChartError(e));
    }
  }
}
