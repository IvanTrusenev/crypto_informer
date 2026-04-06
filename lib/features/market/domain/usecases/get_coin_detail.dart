import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class GetCoinDetail {
  const GetCoinDetail(this._repository);

  final CryptoRepository _repository;

  Future<CryptoCoinDetail> call(String id) {
    return _repository.getCoinDetail(id);
  }
}
