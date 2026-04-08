import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

/// Карточка монеты со stale-while-revalidate.
///
/// Сначала кэш из SQLite (если есть), затем данные с сети. Ошибка сети после
/// показа кэша не пробрасывается.
class GetCoinDetail {
  const GetCoinDetail(this._repository);

  final CryptoRepository _repository;

  Stream<CryptoCoinDetailEntity> call(String id) async* {
    final stale = await _repository.getCachedCoinDetail(id);
    final yieldedStale = stale != null;
    if (yieldedStale) yield stale;
    try {
      yield await _repository.getCoinDetail(id);
    } on Object {
      if (!yieldedStale) rethrow;
    }
  }
}
