import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_detail/coin_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinDetailCubit extends Cubit<CoinDetailState> {
  CoinDetailCubit(this._getCoinDetailUseCase)
    : super(const CoinDetailInitial());

  final GetCoinDetailUseCase _getCoinDetailUseCase;

  Future<void> loadDetail(String coinId) async {
    emit(const CoinDetailLoading());
    try {
      await for (final detail in _getCoinDetailUseCase(coinId)) {
        if (!isClosed) emit(CoinDetailLoaded(detail));
      }
    } on Object catch (e) {
      if (state is CoinDetailLoaded) return;
      if (!isClosed) emit(CoinDetailError(e));
    }
  }
}
