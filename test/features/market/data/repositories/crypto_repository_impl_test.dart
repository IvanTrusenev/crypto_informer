import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements CryptoRemoteDataSource {}

class MockLocal extends Mock implements CryptoLocalDataSource {}

const _btcJson = <String, dynamic>{
  'id': 'bitcoin',
  'symbol': 'btc',
  'name': 'Bitcoin',
  'current_price': 65000.0,
  'price_change_percentage_24h': 2.5,
  'market_cap': 1200000000000.0,
  'image': 'https://example.com/btc.png',
};

const _btcEntity = CryptoAsset(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
  marketCapUsd: 1200000000000,
  imageUrl: 'https://example.com/btc.png',
);

const _detailJson = <String, dynamic>{
  'id': 'bitcoin',
  'symbol': 'btc',
  'name': 'Bitcoin',
  'description': {'en': 'A digital currency'},
  'market_data': {
    'current_price': {'usd': 65000},
    'price_change_percentage_24h': 2.5,
  },
  'image': {'large': 'https://example.com/btc_large.png'},
};

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
    registerFallbackValue(<CryptoAsset>[]);
    registerFallbackValue(
      const CryptoCoinDetail(id: '', symbol: '', name: ''),
    );
    registerFallbackValue(ChartPeriod.days7);
  });

  group('getMarketAssets', () {
    test('returns data from network and caches it', () async {
      when(() => local.readMarketAssets(vsCurrency: any(named: 'vsCurrency')))
          .thenAnswer((_) async => null);
      when(() => remote.fetchMarkets(vsCurrency: any(named: 'vsCurrency')))
          .thenAnswer((_) async => [_btcJson]);
      when(
        () => local.replaceMarketAssets(
          any(),
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).thenAnswer((_) async {});

      final result = await repo.getMarketAssets();

      expect(result.length, 1);
      expect(result.first.id, 'bitcoin');
      verify(
        () => local.replaceMarketAssets(
          any(),
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).called(1);
    });

    test('returns cache on network error', () async {
      when(() => local.readMarketAssets(vsCurrency: any(named: 'vsCurrency')))
          .thenAnswer((_) async => [_btcEntity]);
      when(() => remote.fetchMarkets(vsCurrency: any(named: 'vsCurrency')))
          .thenThrow(Exception('network'));

      final result = await repo.getMarketAssets();

      expect(result.length, 1);
      expect(result.first.id, 'bitcoin');
    });

    test('rethrows when no cache and network fails', () async {
      when(() => local.readMarketAssets(vsCurrency: any(named: 'vsCurrency')))
          .thenAnswer((_) async => null);
      when(() => remote.fetchMarkets(vsCurrency: any(named: 'vsCurrency')))
          .thenThrow(Exception('network'));

      expect(() => repo.getMarketAssets(), throwsA(isA<Exception>()));
    });
  });

  group('getCoinDetail', () {
    test('returns detail from network and caches', () async {
      when(() => local.readCoinDetail(any()))
          .thenAnswer((_) async => null);
      when(() => remote.fetchCoin(any()))
          .thenAnswer((_) async => _detailJson);
      when(() => local.saveCoinDetail(any()))
          .thenAnswer((_) async {});

      final result = await repo.getCoinDetail('bitcoin');

      expect(result.id, 'bitcoin');
      expect(result.name, 'Bitcoin');
      verify(() => local.saveCoinDetail(any())).called(1);
    });

    test('returns cache on network error', () async {
      when(() => local.readCoinDetail(any())).thenAnswer(
        (_) async => const CryptoCoinDetail(
          id: 'bitcoin',
          symbol: 'BTC',
          name: 'Bitcoin',
        ),
      );
      when(() => remote.fetchCoin(any()))
          .thenThrow(Exception('network'));

      final result = await repo.getCoinDetail('bitcoin');

      expect(result.id, 'bitcoin');
    });
  });

  group('getPriceChart', () {
    test('returns sampled points from network', () async {
      final points = List.generate(
        300,
        (i) => PriceChartPoint(
          timestamp: DateTime(2024, 1, 1 + i),
          priceUsd: 100.0 + i,
        ),
      );
      when(
        () => remote.fetchMarketChart(
          any(),
          period: any(named: 'period'),
          vsCurrency: any(named: 'vsCurrency'),
        ),
      ).thenAnswer((_) async => points);

      final result = await repo.getPriceChart(
        'bitcoin',
        period: ChartPeriod.days30,
      );

      expect(result.length, lessThanOrEqualTo(240));
    });
  });
}
