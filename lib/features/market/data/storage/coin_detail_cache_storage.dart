import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';

abstract interface class CoinDetailCacheStorage {
  Future<CoinDetailCacheModel?> readById(String id);

  Future<int> count();

  Future<void> save(CoinDetailCacheModel detail);
}
