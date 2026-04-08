import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_price_chart/coin_price_chart_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinPriceChartCubit extends Cubit<CoinPriceChartState> {
  CoinPriceChartCubit(this._repository) : super(const CoinPriceChartInitial());

  final CryptoRepository _repository;

  Future<void> loadChart(
    String coinId, {
    ChartPeriodEnum period = ChartPeriodEnum.days7,
  }) async {
    emit(CoinPriceChartLoading(period: period));
    try {
      final points = await _repository.getPriceChart(
        coinId,
        period: period,
      );
      if (!isClosed) emit(CoinPriceChartLoaded(points, period: period));
    } on Object catch (e) {
      if (!isClosed) emit(CoinPriceChartError(e, period: period));
    }
  }
}
