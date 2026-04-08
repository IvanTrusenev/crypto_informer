import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

const _btc = CryptoAssetEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
);

void main() {
  late MockCryptoRepository repo;

  setUp(() {
    repo = MockCryptoRepository();
    when(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    ).thenAnswer((_) async => null);
  });

  blocTest<MarketCubit, MarketState>(
    'loadAssets emits loading then loaded',
    build: () {
      when(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenAnswer((_) async => [_btc]);
      return MarketCubit(GetMarketAssetsUseCase(repo), repo);
    },
    act: (cubit) => cubit.loadAssets(),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketLoaded>().having(
        (s) => s.assets.length,
        'assets length',
        1,
      ),
    ],
  );

  blocTest<MarketCubit, MarketState>(
    'loadAssets emits loading then error on failure',
    build: () {
      when(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenThrow(Exception('fail'));
      return MarketCubit(GetMarketAssetsUseCase(repo), repo);
    },
    act: (cubit) => cubit.loadAssets(),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketError>(),
    ],
  );

  blocTest<MarketCubit, MarketState>(
    'loadAssets emits stale from cache then fresh from network',
    build: () {
      const stale = CryptoAssetEntity(
        id: 'stale',
        symbol: 'ST',
        name: 'Stale',
        currentPriceUsd: 1,
        priceChangePercent24h: 0,
      );
      when(
        () => repo.getCachedMarketAssetsFirstPage(
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).thenAnswer((_) async => [stale]);
      when(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenAnswer((_) async => [_btc]);
      return MarketCubit(GetMarketAssetsUseCase(repo), repo);
    },
    act: (cubit) => cubit.loadAssets(),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketLoaded>().having((s) => s.assets.first.id, 'id', 'stale'),
      isA<MarketLoaded>().having((s) => s.assets.first.id, 'id', 'bitcoin'),
    ],
  );

  blocTest<MarketCubit, MarketState>(
    'loadAssets keeps cached list when network fails after stale',
    build: () {
      when(
        () => repo.getCachedMarketAssetsFirstPage(
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).thenAnswer((_) async => [_btc]);
      when(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenThrow(Exception('fail'));
      return MarketCubit(GetMarketAssetsUseCase(repo), repo);
    },
    act: (cubit) => cubit.loadAssets(),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketLoaded>().having((s) => s.assets.length, 'len', 1),
    ],
  );
}
