import 'package:crypto_informer/core/storage/sql/app_database.dart';
import 'package:crypto_informer/core/storage/sql/tables/coin_detail_cache_sql.dart';
import 'package:sqflite/sqflite.dart';

class CoinDetailCacheSqlImpl implements CoinDetailCacheSql {
  CoinDetailCacheSqlImpl(this._appDb);

  final AppDatabase _appDb;

  static const _table = 'coin_detail_cache';

  @override
  Future<String?> readPayload(String coinId) async {
    final rows = await _appDb.database.query(
      _table,
      where: 'coin_id = ?',
      whereArgs: [coinId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['payload'] as String?;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  @override
  Future<void> savePayload(String coinId, String payload) async {
    await _appDb.database.insert(
      _table,
      {
        'coin_id': coinId,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
