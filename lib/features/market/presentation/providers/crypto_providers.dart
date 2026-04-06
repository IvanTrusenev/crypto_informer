import 'package:crypto_informer/core/database/app_database.dart';
import 'package:crypto_informer/core/network/dio_provider.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/presentation/providers/coin_chart_args.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

final databaseProvider = FutureProvider<Database>((ref) => openAppDatabase());

final cryptoRemoteDataSourceProvider = Provider<CryptoRemoteDataSource>((ref) {
  return CryptoRemoteDataSourceImpl(ref.watch(dioProvider));
});

/// Локальное хранилище после открытия БД.
final cryptoLocalDataSourceAsyncProvider =
    FutureProvider<CryptoLocalDataSource>((ref) async {
      final db = await ref.watch(databaseProvider.future);
      return CryptoLocalDataSourceImpl(db);
    });

final cryptoRepositoryProvider = FutureProvider<CryptoRepository>((ref) async {
  final remote = ref.watch(cryptoRemoteDataSourceProvider);
  final local = await ref.watch(cryptoLocalDataSourceAsyncProvider.future);
  return CryptoRepositoryImpl(remote, local);
});

final marketAssetsProvider = FutureProvider<List<CryptoAsset>>((ref) async {
  final repo = await ref.watch(cryptoRepositoryProvider.future);
  return repo.getMarketAssets();
});

final FutureProviderFamily<CryptoCoinDetail, String> coinDetailProvider =
    FutureProvider.family<CryptoCoinDetail, String>((ref, id) async {
      final repo = await ref.watch(cryptoRepositoryProvider.future);
      return repo.getCoinDetail(id);
    });

/// История цены (только сеть, без локального кэша).
final AutoDisposeFutureProviderFamily<List<PriceChartPoint>, CoinChartArgs>
coinPriceChartProvider = FutureProvider.autoDispose
    .family<List<PriceChartPoint>, CoinChartArgs>(
      (ref, args) async {
        final repo = await ref.watch(cryptoRepositoryProvider.future);
        return repo.getPriceChart(
          args.coinId,
          period: args.period,
        );
      },
    );
