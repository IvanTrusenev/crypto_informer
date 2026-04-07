import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

const _btc = CryptoAsset(
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
      return MarketCubit(repo);
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
      return MarketCubit(repo);
    },
    act: (cubit) => cubit.loadAssets(),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketError>(),
    ],
  );
}
