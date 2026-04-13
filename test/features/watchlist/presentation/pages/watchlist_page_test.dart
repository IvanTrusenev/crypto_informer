import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/features/watchlist/presentation/pages/watchlist_page.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

void main() {
  testWidgets('shows empty state when no watchlist items', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = AppKeyValueStorageImpl(prefs);
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
    ).thenAnswer((_) async => []);
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
      MultiBlocProvider(
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
          home: WatchlistPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WatchlistPage), findsOneWidget);
  });
}
