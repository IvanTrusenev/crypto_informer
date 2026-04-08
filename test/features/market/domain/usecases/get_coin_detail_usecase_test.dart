import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_coin_detail_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements CryptoRepository {}

const _fresh = CryptoCoinDetailEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Fresh',
  currentPriceUsd: 2,
);

void main() {
  late MockRepo repo;
  late GetCoinDetailUseCase useCase;

  setUp(() {
    repo = MockRepo();
    useCase = GetCoinDetailUseCase(repo);
  });

  setUpAll(() {
    registerFallbackValue('');
  });

  test('emits only network when cache miss', () async {
    when(() => repo.getCachedCoinDetail(any())).thenAnswer((_) async => null);
    when(() => repo.getCoinDetail(any())).thenAnswer((_) async => _fresh);

    expect(await useCase('bitcoin').toList(), [_fresh]);
  });

  test('emits stale then fresh', () async {
    const stale = CryptoCoinDetailEntity(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Stale',
      currentPriceUsd: 1,
    );
    when(() => repo.getCachedCoinDetail(any())).thenAnswer((_) async => stale);
    when(() => repo.getCoinDetail(any())).thenAnswer((_) async => _fresh);

    expect(await useCase('bitcoin').toList(), [stale, _fresh]);
  });

  test('throws when network fails and no cache', () async {
    when(() => repo.getCachedCoinDetail(any())).thenAnswer((_) async => null);
    when(() => repo.getCoinDetail(any())).thenThrow(Exception('net'));

    await expectLater(
      useCase('bitcoin').toList(),
      throwsA(isA<Exception>()),
    );
  });

  test('completes after stale when network fails', () async {
    const stale = CryptoCoinDetailEntity(
      id: 'bitcoin',
      symbol: 'BTC',
      name: 'Stale',
      currentPriceUsd: 1,
    );
    when(() => repo.getCachedCoinDetail(any())).thenAnswer((_) async => stale);
    when(() => repo.getCoinDetail(any())).thenThrow(Exception('net'));

    expect(await useCase('bitcoin').toList(), [stale]);
  });
}
