import 'package:crypto_informer/core/storage/sql/app_database.dart';
import 'package:crypto_informer/core/storage/sql/tables/market_assets_cache_sql.dart';
import 'package:sqflite/sqflite.dart';

class MarketAssetsCacheSqlImpl implements MarketAssetsCacheSql {
  MarketAssetsCacheSqlImpl(this._appDb);

  final AppDatabase _appDb;

  static const _table = 'market_assets_cache';

  @override
  Future<String?> readPayload(String vsCurrency) async {
    final rows = await _appDb.database.query(
      _table,
      where: 'vs_currency = ?',
      whereArgs: [vsCurrency],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['payload'] as String?;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  @override
  Future<void> replacePayload(String vsCurrency, String payload) async {
    await _appDb.database.insert(
      _table,
      {
        'vs_currency': vsCurrency,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
