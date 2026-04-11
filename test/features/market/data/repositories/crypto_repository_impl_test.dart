import 'package:crypto_informer/features/market/data/datasources/crypto_cache_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/coin_cache_model.dart';
import 'package:crypto_informer/features/market/data/models/coin_current_price_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_description_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_cache_model.dart';
import 'package:crypto_informer/features/market/data/models/coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_image_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_market_data_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements CryptoRemoteDataSource {}

class MockLocal extends Mock implements CryptoCacheDataSource {}

const _btcDto = CoinDto(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
  marketCapUsd: 1200000000000,
  imageUrl: 'https://example.com/btc.png',
);

const _btcDao = CoinCacheModel(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
  marketCapUsd: 1200000000000,
  imageUrl: 'https://example.com/btc.png',
);

const _detailDto = CoinDetailDto(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  description: CoinDescriptionDto(byLocale: {'en': 'A digital currency'}),
  image: CoinImageDto(large: 'https://example.com/btc_large.png'),
  marketData: CoinMarketDataDto(
    currentPrice: CoinCurrentPriceDto(byCurrency: {'usd': 65000.0}),
    priceChangePercentage24h: 2.5,
  ),
);

void main() {
  late MockRemote remote;
  late MockLocal local;
  late CryptoRepositoryImpl repo;

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    repo = CryptoRepositoryImpl(remote, local);
  });

  setUpAll(() {
    registerFallbackValue(<CoinCacheModel>[]);
    registerFallbackValue(
      const CoinDetailCacheModel(id: '', symbol: '', name: ''),
    );
    registerFallbackValue(ChartPeriodEnum.days7);
  });

  group('getCachedMarketAssetsFirstPage', () {
    test('returns entities when cache has rows', () async {
      when(
        () =>
            local.readCachedMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      ).thenAnswer((_) async => [_btcDao]);
      final r = await repo.getCachedMarketAssetsFirstPage();
      expect(r?.length, 1);
      expect(r!.first.id, 'bitcoin');
    });

    test('returns null when cache miss', () async {
      when(
        () =>
            local.readCachedMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      ).thenAnswer((_) async => null);
      expect(await repo.getCachedMarketAssetsFirstPage(), isNull);
    });

    test('returns null when cache is empty list', () async {
      when(
        () =>
            local.readCachedMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      ).thenAnswer((_) async => []);
      expect(await repo.getCachedMarketAssetsFirstPage(), isNull);
    });
  });

  group('getMarketAssets', () {
    test('returns data from network and caches it', () async {
      when(
        () => remote.fetchMarkets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenAnswer((_) async => [_btcDto]);
      when(
        () => local.replaceCachedMarketAssets(
          any(),
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.getMarketAssets();

      expect(result.length, 1);
      expect(result.first.id, 'bitcoin');
      verify(
        () => local.replaceCachedMarketAssets(
          any(),
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).called(1);
      verifyNever(
        () =>
            local.readCachedMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      );
    });

    test('network failure propagates (no second read from local)', () async {
      when(
        () => remote.fetchMarkets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenThrow(Exception('network'));

      await expectLater(repo.getMarketAssets(), throwsA(isA<Exception>()));
      verifyNever(
        () =>
            local.readCachedMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      );
    });
  });

  group('getCachedCoinDetail', () {
    test('returns entity when cache has row', () async {
      when(() => local.readCachedCoinDetail(any())).thenAnswer(
        (_) async => const CoinDetailCacheModel(
          id: 'bitcoin',
          symbol: 'BTC',
          name: 'Bitcoin',
        ),
      );
      final r = await repo.getCachedCoinDetail('bitcoin');
      expect(r?.id, 'bitcoin');
    });

    test('returns null when cache miss', () async {
      when(
        () => local.readCachedCoinDetail(any()),
      ).thenAnswer((_) async => null);
      expect(await repo.getCachedCoinDetail('bitcoin'), isNull);
    });
  });

  group('getCoinDetail', () {
    test('returns detail from network and caches in background', () async {
      when(() => remote.fetchCoin(any())).thenAnswer((_) async => _detailDto);
      when(() => local.saveCachedCoinDetail(any())).thenAnswer((_) async {});

      final result = await repo.getCoinDetail('bitcoin');

      expect(result.id, 'bitcoin');
      expect(result.name, 'Bitcoin');
      verify(() => local.saveCachedCoinDetail(any())).called(1);
      verifyNever(() => local.readCachedCoinDetail(any()));
    });

    test('network failure propagates (no read from local)', () async {
      when(() => remote.fetchCoin(any())).thenThrow(Exception('network'));

      await expectLater(
        repo.getCoinDetail('bitcoin'),
        throwsA(isA<Exception>()),
      );
      verifyNever(() => local.readCachedCoinDetail(any()));
    });
  });

  group('getPriceChart', () {
    test('returns sampled points from network', () async {
      final dtos = List.generate(
        300,
        (i) => PriceChartPointDto(
          timestampMs: DateTime(2024, 1, 1 + i).millisecondsSinceEpoch,
          priceUsd: 100.0 + i,
        ),
      );
      when(
        () => remote.fetchMarketChart(
          any(),
          period: any(named: 'period'),
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).thenAnswer((_) async => dtos);

      final result = await repo.getPriceChart(
        'bitcoin',
        period: ChartPeriodEnum.days30,
      );

      expect(result.length, lessThanOrEqualTo(240));
    });
  });
}
