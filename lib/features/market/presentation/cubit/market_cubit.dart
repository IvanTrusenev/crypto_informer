import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class MarketState {
  const MarketState();
}

class MarketInitial extends MarketState {
  const MarketInitial();
}

class MarketLoading extends MarketState {
  const MarketLoading();
}

class MarketLoaded extends MarketState {
  const MarketLoaded(this.assets);
  final List<CryptoAsset> assets;
}

class MarketError extends MarketState {
  const MarketError(this.error);
  final Object error;
}

class MarketCubit extends Cubit<MarketState> {
  MarketCubit(this._repository) : super(const MarketInitial());

  final CryptoRepository _repository;

  Future<void> loadAssets() async {
    emit(const MarketLoading());
    try {
      final assets = await _repository.getMarketAssets();
      if (!isClosed) emit(MarketLoaded(assets));
    } on Object catch (e) {
      if (!isClosed) emit(MarketError(e));
    }
  }

  Future<void> refresh() async {
    try {
      final assets = await _repository.getMarketAssets();
      if (!isClosed) emit(MarketLoaded(assets));
    } on Object catch (e) {
      if (!isClosed) emit(MarketError(e));
    }
  }
}
