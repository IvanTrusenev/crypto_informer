import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
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
  final CryptoCoinDetail detail;
}

class CoinDetailError extends CoinDetailState {
  const CoinDetailError(this.error);
  final Object error;
}

class CoinDetailCubit extends Cubit<CoinDetailState> {
  CoinDetailCubit(this._repository) : super(const CoinDetailInitial());

  final CryptoRepository _repository;

  Future<void> loadDetail(String coinId) async {
    emit(const CoinDetailLoading());
    try {
      final detail = await _repository.getCoinDetail(coinId);
      if (!isClosed) emit(CoinDetailLoaded(detail));
    } on Object catch (e) {
      if (!isClosed) emit(CoinDetailError(e));
    }
  }
}
