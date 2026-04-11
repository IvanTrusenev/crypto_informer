import 'package:crypto_informer/core/storage/cache/coin_cache_storage.dart';
import 'package:crypto_informer/core/storage/cache/coin_detail_cache_storage.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/core/storage/sqflite/coin/coin_cache_storage_impl.dart';
import 'package:crypto_informer/core/storage/sqflite/coin_detail/coin_detail_cache_storage_impl.dart';
import 'package:crypto_informer/core/storage/sqflite/database/app_database.dart';
import 'package:crypto_informer/core/storage/sqflite/database/migrations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> registerStorageModule(GetIt sl) async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<AppKeyValueStorage>(AppKeyValueStorageImpl(prefs));

  final appDb = await $FroomAppDatabase
      .databaseBuilder('crypto_informer.db')
      .addMigrations([migration1to2, migration2to3, migration3to4])
      .build();

  sl
    ..registerSingleton<AppDatabase>(appDb)
    ..registerLazySingleton<CoinCacheStorage>(
      () => CoinCacheStorageImpl(sl<AppDatabase>().coinCacheDao),
    )
    ..registerLazySingleton<CoinDetailCacheStorage>(
      () => CoinDetailCacheStorageImpl(sl<AppDatabase>().coinDetailCacheDao),
    );
}
