import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements CryptoRepository {}

const _btc = CryptoAssetEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 1,
  priceChangePercent24h: 0,
);

void main() {
  late MockRepo repo;
  late GetMarketAssetsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(ChartPeriodEnum.days7);
  });

  setUp(() {
    repo = MockRepo();
    useCase = GetMarketAssetsUseCase(repo);
  });

  test('emits only network list when cache empty', () async {
    when(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repo.getMarketAssets(
        vsCurrency: any(named: 'vsCurrency'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        order: any(named: 'order'),
        ids: any(named: 'ids'),
      ),
    ).thenAnswer((_) async => [_btc]);

    expect(await useCase().toList(), [
      [_btc],
    ]);
  });

  test('emits stale then fresh on first browse page', () async {
    const stale = CryptoAssetEntity(
      id: 'x',
      symbol: 'X',
      name: 'Stale',
      currentPriceUsd: 0,
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

    expect(await useCase().toList(), [
      [stale],
      [_btc],
    ]);
  });

  test('first browse page skips cache when emitCachedFirst is false', () async {
    const stale = CryptoAssetEntity(
      id: 'x',
      symbol: 'X',
      name: 'Stale',
      currentPriceUsd: 0,
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

    expect(await useCase(emitCachedFirst: false).toList(), [
      [_btc],
    ]);
    verifyNever(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    );
  });

  test('page 2 skips cache read', () async {
    when(
      () => repo.getMarketAssets(
        vsCurrency: any(named: 'vsCurrency'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        order: any(named: 'order'),
        ids: any(named: 'ids'),
      ),
    ).thenAnswer((_) async => [_btc]);

    expect(await useCase(page: 2).toList(), [
      [_btc],
    ]);
    verifyNever(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    );
  });

  test('throws when network fails and cache was not shown', () async {
    when(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repo.getMarketAssets(
        vsCurrency: any(named: 'vsCurrency'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        order: any(named: 'order'),
        ids: any(named: 'ids'),
      ),
    ).thenThrow(Exception('net'));

    await expectLater(
      useCase().toList(),
      throwsA(isA<Exception>()),
    );
  });

  test('completes without throw when network fails after stale', () async {
    const stale = CryptoAssetEntity(
      id: 'x',
      symbol: 'X',
      name: 'Stale',
      currentPriceUsd: 0,
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
    ).thenThrow(Exception('net'));

    expect(await useCase().toList(), [
      [stale],
    ]);
  });
}
