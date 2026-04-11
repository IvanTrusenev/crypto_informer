import 'package:crypto_informer/core/storage/sqflite/tables/coin_detail_cache_dao.dart';
import 'package:crypto_informer/core/storage/sqflite/tables/market_assets_cache_dao.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_detail_cache_record_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_asset_dao_cache_record_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_coin_detail_dao_cache_record_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/market_asset_cache_record_mapper.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';

class CryptoLocalDataSourceImpl implements CryptoLocalDataSource {
  CryptoLocalDataSourceImpl(this._marketAssets, this._coinDetail);

  final MarketAssetsCacheDao _marketAssets;
  final CoinDetailCacheDao _coinDetail;

  @override
  Future<List<CryptoAssetDao>?> readMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    final rows = await _marketAssets.findByVsCurrency(vsCurrency);
    if (rows.isEmpty) return null;
    return rows.map((row) => row.toDao()).toList(growable: false);
  }

  @override
  Future<void> replaceMarketAssets(
    List<CryptoAssetDao> items, {
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    final updatedAt = DateTime.now().millisecondsSinceEpoch;
    final rows = [
      for (var index = 0; index < items.length; index++)
        items[index].toCacheRecord(
          vsCurrency: vsCurrency,
          sortOrder: index,
          updatedAt: updatedAt,
        ),
    ];
    await _marketAssets.replaceRows(vsCurrency, rows);
  }

  @override
  Future<CryptoCoinDetailDao?> readCoinDetail(String id) async {
    final row = await _coinDetail.findById(id);
    return row?.toDao();
  }

  @override
  Future<void> saveCoinDetail(CryptoCoinDetailDao detail) async {
    await _coinDetail.upsert(
      detail.toCacheRecord(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
