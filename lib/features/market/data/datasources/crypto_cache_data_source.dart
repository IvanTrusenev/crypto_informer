import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';

abstract interface class CryptoCacheDataSource {
  Future<List<CoinCacheModel>?> readCachedMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  });

  Future<void> replaceCachedMarketAssets(
    List<CoinCacheModel> items, {
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  });

  Future<CoinDetailCacheModel?> readCachedCoinDetail(String id);

  Future<void> saveCachedCoinDetail(CoinDetailCacheModel detail);
}
