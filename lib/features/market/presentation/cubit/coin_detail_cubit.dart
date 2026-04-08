import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class CoinDetailState {
  const CoinDetailState();
}

class CoinDetailInitial extends CoinDetailState {
  const CoinDetailInitial();
}

class CoinDetailLoading extends CoinDetailState {
  const CoinDetailLoading();
}

class CoinDetailLoaded extends CoinDetailState {
  const CoinDetailLoaded(this.detail);
  final CryptoCoinDetailEntity detail;
}

class CoinDetailError extends CoinDetailState {
  const CoinDetailError(this.error);
  final Object error;
}

class CoinDetailCubit extends Cubit<CoinDetailState> {
  CoinDetailCubit(this._getCoinDetail) : super(const CoinDetailInitial());

  final GetCoinDetail _getCoinDetail;

  Future<void> loadDetail(String coinId) async {
    emit(const CoinDetailLoading());
    try {
      await for (final detail in _getCoinDetail(coinId)) {
        if (!isClosed) emit(CoinDetailLoaded(detail));
      }
    } on Object catch (e) {
      if (state is CoinDetailLoaded) return;
      if (!isClosed) emit(CoinDetailError(e));
    }
  }
}
