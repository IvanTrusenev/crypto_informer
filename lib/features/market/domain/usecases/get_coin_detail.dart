import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class GetCoinDetail {
  const GetCoinDetail(this._repository);

  final CryptoRepository _repository;

  Future<CryptoCoinDetailEntity> call(String id) {
    return _repository.getCoinDetail(id);
  }
}
