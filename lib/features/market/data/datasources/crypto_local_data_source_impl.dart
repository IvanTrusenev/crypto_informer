import 'dart:convert';

import 'package:crypto_informer/core/storage/sql/tables/coin_detail_cache_sql.dart';
import 'package:crypto_informer/core/storage/sql/tables/market_assets_cache_sql.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/domain/market_list_query_defaults.dart';

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  CryptoLocalDataSourceImpl(this._marketAssets, this._coinDetail);

  final MarketAssetsCacheSql _marketAssets;
  final CoinDetailCacheSql _coinDetail;

  @override
  Future<List<CryptoAssetDao>?> readMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    final raw = await _marketAssets.readPayload(vsCurrency);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CryptoAssetDao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> replaceMarketAssets(
    List<CryptoAssetDao> items, {
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    final payload = jsonEncode(items.map((a) => a.toJson()).toList());
    await _marketAssets.replacePayload(vsCurrency, payload);
  }

  @override
  Future<CryptoCoinDetailDao?> readCoinDetail(String id) async {
    final raw = await _coinDetail.readPayload(id);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return CryptoCoinDetailDao.fromJson(map);
  }

  @override
  Future<void> saveCoinDetail(CryptoCoinDetailDao detail) async {
    final payload = jsonEncode(detail.toJson());
    await _coinDetail.savePayload(detail.id, payload);
  }
}
