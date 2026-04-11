import 'package:crypto_informer/core/storage/sqflite/tables/market_asset_cache_record.dart';
import 'package:froom/froom.dart';

@dao
abstract class MarketAssetsCacheDao {
  @Query('''
    SELECT *
    FROM market_assets_cache
    WHERE vs_currency = :vsCurrency
    ORDER BY sort_order ASC
  ''')
  Future<List<MarketAssetCacheRecord>> findByVsCurrency(String vsCurrency);

  @Query('DELETE FROM market_assets_cache WHERE vs_currency = :vsCurrency')
  Future<void> deleteByVsCurrency(String vsCurrency);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertRows(List<MarketAssetCacheRecord> rows);

  @transaction
  Future<void> replaceRows(
    String vsCurrency,
    List<MarketAssetCacheRecord> rows,
  ) async {
    await deleteByVsCurrency(vsCurrency);
    if (rows.isEmpty) return;
    await insertRows(rows);
  }
}
