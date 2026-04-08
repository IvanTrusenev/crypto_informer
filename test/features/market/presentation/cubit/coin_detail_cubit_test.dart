import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_detail/export.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

const _fresh = CryptoCoinDetailEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin fresh',
  currentPriceUsd: 70000,
);

const _stale = CryptoCoinDetailEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin stale',
  currentPriceUsd: 65000,
);

void main() {
  late MockCryptoRepository repo;

  setUp(() {
    repo = MockCryptoRepository();
    when(() => repo.getCachedCoinDetail(any())).thenAnswer((_) async => null);
  });

  blocTest<CoinDetailCubit, CoinDetailState>(
    'loadDetail emits loading then loaded',
    build: () {
      when(() => repo.getCoinDetail(any())).thenAnswer((_) async => _fresh);
      return CoinDetailCubit(GetCoinDetailUseCase(repo));
    },
    act: (cubit) => cubit.loadDetail('bitcoin'),
    expect: () => [
      isA<CoinDetailLoading>(),
      isA<CoinDetailLoaded>().having(
        (s) => s.detail.name,
        'name',
        'Bitcoin fresh',
      ),
    ],
  );

  blocTest<CoinDetailCubit, CoinDetailState>(
    'loadDetail emits error when no cache and network fails',
    build: () {
      when(() => repo.getCoinDetail(any())).thenThrow(Exception('fail'));
      return CoinDetailCubit(GetCoinDetailUseCase(repo));
    },
    act: (cubit) => cubit.loadDetail('bitcoin'),
    expect: () => [
      isA<CoinDetailLoading>(),
      isA<CoinDetailError>(),
    ],
  );

  blocTest<CoinDetailCubit, CoinDetailState>(
    'loadDetail emits stale from cache then fresh from network',
    build: () {
      when(
        () => repo.getCachedCoinDetail(any()),
      ).thenAnswer((_) async => _stale);
      when(() => repo.getCoinDetail(any())).thenAnswer((_) async => _fresh);
      return CoinDetailCubit(GetCoinDetailUseCase(repo));
    },
    act: (cubit) => cubit.loadDetail('bitcoin'),
    expect: () => [
      isA<CoinDetailLoading>(),
      isA<CoinDetailLoaded>().having(
        (s) => s.detail.name,
        'stale name',
        'Bitcoin stale',
      ),
      isA<CoinDetailLoaded>().having(
        (s) => s.detail.name,
        'fresh name',
        'Bitcoin fresh',
      ),
    ],
  );

  blocTest<CoinDetailCubit, CoinDetailState>(
    'loadDetail keeps cached detail when network fails after stale',
    build: () {
      when(
        () => repo.getCachedCoinDetail(any()),
      ).thenAnswer((_) async => _stale);
      when(() => repo.getCoinDetail(any())).thenThrow(Exception('fail'));
      return CoinDetailCubit(GetCoinDetailUseCase(repo));
    },
    act: (cubit) => cubit.loadDetail('bitcoin'),
    expect: () => [
      isA<CoinDetailLoading>(),
      isA<CoinDetailLoaded>().having(
        (s) => s.detail.name,
        'name',
        'Bitcoin stale',
      ),
    ],
  );
}
