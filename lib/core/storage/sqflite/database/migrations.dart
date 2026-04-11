import 'package:froom/froom.dart';

final Migration migration1to2 = Migration(1, 2, (database) async {
  await database.execute('DROP TABLE IF EXISTS market_assets_cache');
  await database.execute('DROP TABLE IF EXISTS coin_detail_cache');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS market_assets_cache (
      cache_key TEXT NOT NULL,
      id TEXT NOT NULL,
      vs_currency TEXT NOT NULL,
      sort_order INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      symbol TEXT NOT NULL,
      name TEXT NOT NULL,
      current_price_usd REAL NOT NULL,
      price_change_percent_24h REAL NOT NULL,
      market_cap_usd REAL,
      image_url TEXT,
      PRIMARY KEY (cache_key)
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS coin_detail_cache (
      id TEXT NOT NULL,
      updated_at INTEGER NOT NULL,
      symbol TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      current_price_usd REAL,
      price_change_percent_24h REAL,
      image_url TEXT,
      PRIMARY KEY (id)
    )
  ''');
});

final Migration migration2to3 = Migration(2, 3, (database) async {
  await database.execute(
    'ALTER TABLE market_assets_cache RENAME TO coins_cache',
  );
});

final Migration migration3to4 = Migration(3, 4, (database) async {
  await database.execute(
    'ALTER TABLE coins_cache RENAME TO coin_cache',
  );
});
