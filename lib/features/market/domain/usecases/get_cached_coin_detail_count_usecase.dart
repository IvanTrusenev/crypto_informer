import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class GetCachedCoinDetailCountUseCase {
  const GetCachedCoinDetailCountUseCase(this._repository);

  final CryptoRepository _repository;

  Future<int> call() {
    return _repository.getCachedCoinDetailCount();
  }
}
