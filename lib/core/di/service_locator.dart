import 'package:crypto_informer/core/network/coin_gecko_api_client.dart';
import 'package:crypto_informer/core/network/network_module.dart';
import 'package:crypto_informer/core/storage/cache/coin_cache_storage.dart';
import 'package:crypto_informer/core/storage/cache/coin_detail_cache_storage.dart';
import 'package:crypto_informer/core/storage/storage_module.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_cache_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_cache_data_source_impl.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source_impl.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initServiceLocator() async {
  registerNetworkModule(sl);
  await registerStorageModule(sl);

  sl
    ..registerLazySingleton<CryptoRemoteDataSource>(
      () => CryptoRemoteDataSourceImpl(sl<CoinGeckoApiClient>()),
    )
    ..registerLazySingleton<CryptoCacheDataSource>(
      () => CryptoCacheDataSourceImpl(
        sl<CoinCacheStorage>(),
        sl<CoinDetailCacheStorage>(),
      ),
    )
    ..registerLazySingleton<CryptoRepository>(
      () => CryptoRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<GetMarketAssetsUseCase>(
      () => GetMarketAssetsUseCase(sl<CryptoRepository>()),
    )
    ..registerLazySingleton<SearchCoinIdsUseCase>(
      () => SearchCoinIdsUseCase(sl<CryptoRepository>()),
    )
    ..registerFactory<SearchBloc>(
      () => SearchBloc(sl<SearchCoinIdsUseCase>()),
    )
    ..registerFactoryParam<MarketBloc, SearchBloc, void>(
      (searchBloc, _) => MarketBloc(
        sl<GetMarketAssetsUseCase>(),
        searchBloc,
      ),
    )
    ..registerLazySingleton<GetCoinDetailUseCase>(
      () => GetCoinDetailUseCase(sl<CryptoRepository>()),
    );
}
