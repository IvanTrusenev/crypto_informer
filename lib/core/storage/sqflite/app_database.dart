import 'dart:async';

import 'package:crypto_informer/core/storage/sqflite/tables/coin_detail_cache_dao.dart';
import 'package:crypto_informer/core/storage/sqflite/tables/coin_detail_cache_record.dart';
import 'package:crypto_informer/core/storage/sqflite/tables/market_asset_cache_record.dart';
import 'package:crypto_informer/core/storage/sqflite/tables/market_assets_cache_dao.dart';
import 'package:froom/froom.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(
  version: 2,
  entities: [
    MarketAssetCacheRecord,
    CoinDetailCacheRecord,
  ],
)
abstract class AppDatabase extends FroomDatabase {
  MarketAssetsCacheDao get marketAssetsCacheDao;

  CoinDetailCacheDao get coinDetailCacheDao;
}
