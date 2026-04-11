import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';

abstract interface class CoinCacheStorage {
  Future<List<CoinCacheModel>?> readByVsCurrency(String vsCurrency);

  Future<void> replaceByVsCurrency(
    String vsCurrency,
    List<CoinCacheModel> items,
  );
}
