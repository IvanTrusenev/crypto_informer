import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

const _btc = CoinEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
);

void main() {
  late MockCryptoRepository repo;
  SearchBloc? searchBloc;

  setUp(() {
    repo = MockCryptoRepository();
    when(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    ).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await searchBloc?.close();
  });

  blocTest<MarketBloc, MarketState>(
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
      final getAssets = GetMarketAssetsUseCase(repo);
      searchBloc = SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
      return MarketBloc(
        getAssets,
        searchBloc!,
      );
    },
    act: (bloc) => bloc.add(const MarketLoadRequested()),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketLoaded>().having(
        (s) => s.assets.length,
        'assets length',
        1,
      ),
    ],
  );

  blocTest<MarketBloc, MarketState>(
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
      final getAssets = GetMarketAssetsUseCase(repo);
      searchBloc = SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
      return MarketBloc(
        getAssets,
        searchBloc!,
      );
    },
    act: (bloc) => bloc.add(const MarketLoadRequested()),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketError>(),
    ],
  );

  blocTest<MarketBloc, MarketState>(
    'loadAssets emits stale from cache then fresh from network',
    build: () {
      const stale = CoinEntity(
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
      final getAssets = GetMarketAssetsUseCase(repo);
      searchBloc = SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
      return MarketBloc(
        getAssets,
        searchBloc!,
      );
    },
    act: (bloc) => bloc.add(const MarketLoadRequested()),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketLoaded>().having((s) => s.assets.first.id, 'id', 'stale'),
      isA<MarketLoaded>().having((s) => s.assets.first.id, 'id', 'bitcoin'),
    ],
  );

  blocTest<MarketBloc, MarketState>(
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
      final getAssets = GetMarketAssetsUseCase(repo);
      searchBloc = SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
      return MarketBloc(
        getAssets,
        searchBloc!,
      );
    },
    act: (bloc) => bloc.add(const MarketLoadRequested()),
    expect: () => [
      isA<MarketLoading>(),
      isA<MarketLoaded>().having((s) => s.assets.length, 'len', 1),
    ],
  );

  blocTest<MarketBloc, MarketState>(
    'search emits refinement state when search returns too many ids',
    build: () {
      when(
        () => repo.searchCoinIds('coin'),
      ).thenAnswer(
        (_) async => List.generate(
          MarketListQueryDefaults.maxSearchResultsForMarketFetch + 1,
          (index) => 'coin-$index',
        ),
      );
      final getAssets = GetMarketAssetsUseCase(repo);
      searchBloc = SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
      return MarketBloc(
        getAssets,
        searchBloc!,
      );
    },
    act: (_) async {
      searchBloc!.add(const SearchQueryChanged('coin'));
      await Future<void>.delayed(const Duration(milliseconds: 1));
    },
    expect: () => [
      isA<MarketLoaded>()
          .having((s) => s.searchQuery, 'searchQuery', 'coin')
          .having((s) => s.isSearching, 'isSearching', true)
          .having(
            (s) => s.searchNeedsRefinement,
            'searchNeedsRefinement',
            false,
          ),
      isA<MarketLoaded>()
          .having((s) => s.searchQuery, 'searchQuery', 'coin')
          .having((s) => s.hasMore, 'hasMore', false)
          .having(
            (s) => s.searchNeedsRefinement,
            'searchNeedsRefinement',
            true,
          ),
    ],
    verify: (_) {
      verify(() => repo.searchCoinIds('coin')).called(1);
      verifyNever(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      );
    },
  );

  blocTest<MarketBloc, MarketState>(
    'search loadMore reveals next local page without second network call',
    build: () {
      final ids = List.generate(60, (index) => 'coin-$index');
      final assets = List.generate(
        60,
        (index) => CoinEntity(
          id: 'coin-$index',
          symbol: 'C$index',
          name: 'Coin $index',
          currentPriceUsd: index.toDouble(),
          priceChangePercent24h: index.toDouble(),
        ),
      );
      when(() => repo.searchCoinIds('coin')).thenAnswer((_) async => ids);
      when(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).thenAnswer((_) async => assets);
      final getAssets = GetMarketAssetsUseCase(repo);
      searchBloc = SearchBloc(
        SearchCoinIdsUseCase(repo),
        searchDebounce: Duration.zero,
      );
      return MarketBloc(
        getAssets,
        searchBloc!,
      );
    },
    act: (bloc) async {
      searchBloc!.add(const SearchQueryChanged('coin'));
      await Future<void>.delayed(const Duration(milliseconds: 1));
      bloc.add(const MarketLoadMoreRequested());
    },
    expect: () => [
      isA<MarketLoaded>()
          .having((s) => s.searchQuery, 'searchQuery', 'coin')
          .having((s) => s.isSearching, 'isSearching', true),
      isA<MarketLoaded>()
          .having((s) => s.searchQuery, 'searchQuery', 'coin')
          .having((s) => s.isSearching, 'isSearching', true)
          .having((s) => s.assets.length, 'assets length', 0),
      isA<MarketLoaded>()
          .having((s) => s.assets.length, 'assets length', 50)
          .having((s) => s.page, 'page', 1)
          .having((s) => s.hasMore, 'hasMore', true),
      isA<MarketLoaded>()
          .having((s) => s.isLoadingMore, 'isLoadingMore', true)
          .having((s) => s.assets.length, 'assets length', 50),
      isA<MarketLoaded>()
          .having((s) => s.assets.length, 'assets length', 60)
          .having((s) => s.page, 'page', 2)
          .having((s) => s.hasMore, 'hasMore', false),
    ],
    verify: (_) {
      verify(() => repo.searchCoinIds('coin')).called(1);
      verify(
        () => repo.getMarketAssets(
          vsCurrency: any(named: 'vsCurrency'),
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          order: any(named: 'order'),
          ids: any(named: 'ids'),
        ),
      ).called(1);
    },
  );
}
