import 'package:crypto_informer/core/storage/sqflite/tables/coin_detail_cache_record.dart';
import 'package:froom/froom.dart';

@dao
abstract class CoinDetailCacheDao {
  @Query('SELECT * FROM coin_detail_cache WHERE id = :id LIMIT 1')
  Future<CoinDetailCacheRecord?> findById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(CoinDetailCacheRecord row);
}
