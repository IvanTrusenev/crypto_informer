import 'package:crypto_informer/features/market/domain/entities/coin_detail_entity.dart';

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
  final CoinDetailEntity detail;
}

class CoinDetailError extends CoinDetailState {
  const CoinDetailError(this.error);
  final Object error;
}
