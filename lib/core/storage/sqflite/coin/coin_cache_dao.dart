import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_record.dart';
import 'package:froom/froom.dart';

@dao
abstract class CoinCacheDao {
  @Query('''
    SELECT *
    FROM coin_cache
    WHERE vs_currency = :vsCurrency
    ORDER BY sort_order ASC
  ''')
  Future<List<CoinCacheRecord>> findByVsCurrency(String vsCurrency);

  @Query('DELETE FROM coin_cache WHERE vs_currency = :vsCurrency')
  Future<void> deleteByVsCurrency(String vsCurrency);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insert(List<CoinCacheRecord> records);

  @transaction
  Future<void> replaceByVsCurrency(
    String vsCurrency,
    List<CoinCacheRecord> records,
  ) async {
    await deleteByVsCurrency(vsCurrency);
    if (records.isEmpty) return;
    await insert(records);
  }
}
