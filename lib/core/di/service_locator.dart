import 'package:crypto_informer/core/network/rest/coingecko_rest_client.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/core/storage/sql/app_database.dart';
import 'package:crypto_informer/core/storage/sql/app_database_impl.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source_impl.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source_impl.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  sl
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://api.coingecko.com/api/v3',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      ),
    )
    ..registerLazySingleton<CoinGeckoRestClient>(
      () => CoinGeckoRestClient(sl()),
    )
    ..registerLazySingleton<CryptoRemoteDataSource>(
      () => CryptoRemoteDataSourceImpl(sl<CoinGeckoRestClient>()),
    );

  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<AppKeyValueStorage>(AppKeyValueStorageImpl(prefs));

  final appDb = await AppDatabaseImpl.open();
  sl
    ..registerSingleton<AppDatabase>(appDb)
    ..registerLazySingleton<CryptoLocalDataSource>(
      () => CryptoLocalDataSourceImpl(sl<AppDatabase>()),
    )
    ..registerLazySingleton<CryptoRepository>(
      () => CryptoRepositoryImpl(sl(), sl()),
    );
}
