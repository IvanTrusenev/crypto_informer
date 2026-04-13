import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements CryptoRepository {}

void main() {
  late MockRepo repo;

  setUp(() {
    repo = MockRepo();
  });

  blocTest<SearchBloc, SearchState>(
    'empty query emits idle state without repository call',
    build: () => SearchBloc(
      SearchCoinIdsUseCase(repo),
      searchDebounce: Duration.zero,
    ),
    act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
    expect: () => [
      isA<SearchState>()
          .having((s) => s.query, 'query', '')
          .having((s) => s.status, 'status', SearchStatusEnum.idle),
    ],
    verify: (_) {
      verifyNever(() => repo.searchCoinIds(any()));
    },
  );

  blocTest<SearchBloc, SearchState>(
    'query emits searching then ready with ids',
    build: () {
      when(
        () => repo.searchCoinIds('btc'),
      ).thenAnswer((_) async => ['bitcoin']);
      return SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
    },
    act: (bloc) async {
      bloc.add(const SearchQueryChanged('btc'));
      await Future<void>.delayed(const Duration(milliseconds: 1));
    },
    expect: () => [
      isA<SearchState>()
          .having((s) => s.query, 'query', 'btc')
          .having((s) => s.status, 'status', SearchStatusEnum.searching),
      isA<SearchState>()
          .having((s) => s.query, 'query', 'btc')
          .having((s) => s.status, 'status', SearchStatusEnum.ready)
          .having((s) => s.ids, 'ids', ['bitcoin']),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'query emits tooBroad when ids exceed threshold',
    build: () {
      when(() => repo.searchCoinIds('coin')).thenAnswer(
        (_) async => List.generate(
          MarketListQueryDefaults.maxSearchResultsForMarketFetch + 1,
          (index) => 'coin-$index',
        ),
      );
      return SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
    },
    act: (bloc) async {
      bloc.add(const SearchQueryChanged('coin'));
      await Future<void>.delayed(const Duration(milliseconds: 1));
    },
    expect: () => [
      isA<SearchState>()
          .having((s) => s.query, 'query', 'coin')
          .having((s) => s.status, 'status', SearchStatusEnum.searching),
      isA<SearchState>()
          .having((s) => s.query, 'query', 'coin')
          .having((s) => s.status, 'status', SearchStatusEnum.tooBroad)
          .having(
            (s) => s.ids.length,
            'ids length',
            MarketListQueryDefaults.maxSearchResultsForMarketFetch + 1,
          ),
    ],
  );
}
