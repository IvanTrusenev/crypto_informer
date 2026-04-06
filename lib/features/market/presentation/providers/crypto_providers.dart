import 'package:crypto_informer/core/network/dio_provider.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cryptoRemoteDataSourceProvider = Provider<CryptoRemoteDataSource>((ref) {
  return CryptoRemoteDataSourceImpl(ref.watch(dioProvider));
});

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) {
  return CryptoRepositoryImpl(ref.watch(cryptoRemoteDataSourceProvider));
});

final getMarketAssetsProvider = Provider<GetMarketAssets>((ref) {
  return GetMarketAssets(ref.watch(cryptoRepositoryProvider));
});

final getCoinDetailProvider = Provider<GetCoinDetail>((ref) {
  return GetCoinDetail(ref.watch(cryptoRepositoryProvider));
});

final marketAssetsProvider = FutureProvider<List<CryptoAsset>>((ref) {
  return ref.watch(getMarketAssetsProvider).call();
});

final FutureProviderFamily<CryptoCoinDetail, String> coinDetailProvider =
    FutureProvider.family<CryptoCoinDetail, String>((ref, id) {
  return ref.watch(getCoinDetailProvider).call(id);
});
