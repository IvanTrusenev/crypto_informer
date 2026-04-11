import 'dart:async';

import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_dao.dart';
import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_record.dart';
import 'package:crypto_informer/core/storage/sqflite/coin_detail/coin_detail_cache_dao.dart';
import 'package:crypto_informer/core/storage/sqflite/coin_detail/coin_detail_cache_record.dart';
import 'package:froom/froom.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(
  version: 4,
  entities: [
    CoinCacheRecord,
    CoinDetailCacheRecord,
  ],
)
abstract class AppDatabase extends FroomDatabase {
  CoinCacheDao get coinCacheDao;

  CoinDetailCacheDao get coinDetailCacheDao;
}
