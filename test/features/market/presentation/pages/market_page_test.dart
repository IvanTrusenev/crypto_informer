import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:crypto_informer/features/market/presentation/pages/market_page.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

const _btc = CoinEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
);

Widget _buildApp({
  required SearchBloc searchBloc,
  required MarketBloc marketBloc,
}) {
  SharedPreferences.setMockInitialValues({});
  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const MaterialApp(home: SizedBox());
      }
      final storage = AppKeyValueStorageImpl(snapshot.data!);
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: searchBloc),
          BlocProvider.value(value: marketBloc),
          BlocProvider(
            create: (_) => WatchlistCubit(storage)..loadIds(),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: MarketPage(),
        ),
      );
    },
  );
}

void main() {
  testWidgets('shows list when loaded', (tester) async {
    final repo = MockCryptoRepository();
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
    final getAssets = GetMarketAssetsUseCase(repo);
    final searchBloc = SearchBloc(
      SearchCoinIdsUseCase(repo),
      searchDebounce: Duration.zero,
    );
    final marketBloc = MarketBloc(
      getAssets,
      searchBloc,
    )..add(const MarketLoadRequested());
    await tester.pump();

    await tester.pumpWidget(
      _buildApp(searchBloc: searchBloc, marketBloc: marketBloc),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bitcoin'), findsOneWidget);
  });

  testWidgets('shows error on failure', (tester) async {
    final repo = MockCryptoRepository();
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
    ).thenThrow(Exception('fail'));
    final getAssets = GetMarketAssetsUseCase(repo);
    final searchBloc = SearchBloc(
      SearchCoinIdsUseCase(repo),
      searchDebounce: Duration.zero,
    );
    final marketBloc = MarketBloc(
      getAssets,
      searchBloc,
    )..add(const MarketLoadRequested());
    await tester.pump();

    await tester.pumpWidget(
      _buildApp(searchBloc: searchBloc, marketBloc: marketBloc),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('shows refinement message when search returns too many matches', (
    tester,
  ) async {
    final repo = MockCryptoRepository();
    when(
      () => repo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repo.searchCoinIds('coin'),
    ).thenAnswer(
      (_) async => List.generate(
        MarketListQueryDefaults.maxSearchResultsForMarketFetch + 1,
        (index) => 'coin-$index',
      ),
    );

    final getAssets = GetMarketAssetsUseCase(repo);
    final searchBloc = SearchBloc(
      SearchCoinIdsUseCase(repo),
      searchDebounce: Duration.zero,
    );
    final marketBloc = MarketBloc(
      getAssets,
      searchBloc,
    );
    searchBloc.add(const SearchQueryChanged('coin'));
    await tester.pump();

    await tester.pumpWidget(
      _buildApp(searchBloc: searchBloc, marketBloc: marketBloc),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Too many results. Refine your search.'),
      findsOneWidget,
    );
  });
}
