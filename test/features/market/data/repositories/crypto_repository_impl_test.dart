import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/coin_current_price_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_description_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_image_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_market_data_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/data/repositories/crypto_repository_impl.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements CryptoRemoteDataSource {}

class MockLocal extends Mock implements CryptoLocalDataSource {}

const _btcDto = CryptoAssetDto(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
  marketCapUsd: 1200000000000,
  imageUrl: 'https://example.com/btc.png',
);

const _btcDao = CryptoAssetDao(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
  marketCapUsd: 1200000000000,
  imageUrl: 'https://example.com/btc.png',
);

const _detailDto = CryptoCoinDetailDto(
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
    registerFallbackValue(<CryptoAssetDao>[]);
    registerFallbackValue(
      const CryptoCoinDetailDao(id: '', symbol: '', name: ''),
    );
    registerFallbackValue(ChartPeriod.days7);
  });

  group('getMarketAssets', () {
    test('returns data from network and caches it', () async {
      when(
        () => local.readMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      ).thenAnswer((_) async => null);
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
      when(
        () => local.readMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      ).thenAnswer((_) async => [_btcDao]);
      when(
        () => remote.fetchMarkets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenThrow(Exception('network'));

      final result = await repo.getMarketAssets();

      expect(result.length, 1);
      expect(result.first.id, 'bitcoin');
    });

    test('rethrows when no cache and network fails', () async {
      when(
        () => local.readMarketAssets(vsCurrency: any(named: 'vsCurrency')),
      ).thenAnswer((_) async => null);
      when(
        () => remote.fetchMarkets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenThrow(Exception('network'));

      expect(() => repo.getMarketAssets(), throwsA(isA<Exception>()));
    });
  });

  group('getCoinDetail', () {
    test('returns detail from network and caches', () async {
      when(() => local.readCoinDetail(any())).thenAnswer((_) async => null);
      when(() => remote.fetchCoin(any())).thenAnswer((_) async => _detailDto);
      when(() => local.saveCoinDetail(any())).thenAnswer((_) async {});

      final result = await repo.getCoinDetail('bitcoin');

      expect(result.id, 'bitcoin');
      expect(result.name, 'Bitcoin');
      verify(() => local.saveCoinDetail(any())).called(1);
    });

    test('returns cache on network error', () async {
      when(() => local.readCoinDetail(any())).thenAnswer(
        (_) async => const CryptoCoinDetailDao(
          id: 'bitcoin',
          symbol: 'BTC',
          name: 'Bitcoin',
        ),
      );
      when(() => remote.fetchCoin(any())).thenThrow(Exception('network'));

      final result = await repo.getCoinDetail('bitcoin');

      expect(result.id, 'bitcoin');
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
        period: ChartPeriod.days30,
      );

      expect(result.length, lessThanOrEqualTo(240));
    });
  });
}
