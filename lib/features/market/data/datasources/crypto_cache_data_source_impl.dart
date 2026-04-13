import 'package:crypto_informer/features/market/data/datasources/crypto_cache_data_source.dart';
import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';
import 'package:crypto_informer/features/market/data/storage/coin_cache_storage.dart';
import 'package:crypto_informer/features/market/data/storage/coin_detail_cache_storage.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';

class CryptoCacheDataSourceImpl implements CryptoCacheDataSource {
  CryptoCacheDataSourceImpl(this._coin, this._coinDetail);

  final CoinCacheStorage _coin;
  final CoinDetailCacheStorage _coinDetail;

  @override
  Future<List<CoinCacheModel>?> readCachedMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    return _coin.readByVsCurrency(vsCurrency);
  }

  @override
  Future<void> replaceCachedMarketAssets(
    List<CoinCacheModel> items, {
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    await _coin.replaceByVsCurrency(vsCurrency, items);
  }

  @override
  Future<CoinDetailCacheModel?> readCachedCoinDetail(String id) async {
    return _coinDetail.readById(id);
  }

  @override
  Future<int> countCachedCoinDetails() async {
    return _coinDetail.count();
  }

  @override
  Future<void> saveCachedCoinDetail(CoinDetailCacheModel detail) async {
    await _coinDetail.save(detail);
  }
}
