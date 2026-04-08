import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:crypto_informer/features/market/presentation/pages/market_page.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCryptoRepository extends Mock implements CryptoRepository {}

const _btc = CryptoAssetEntity(
  id: 'bitcoin',
  symbol: 'BTC',
  name: 'Bitcoin',
  currentPriceUsd: 65000,
  priceChangePercent24h: 2.5,
);

Widget _buildApp({required MarketCubit marketCubit}) {
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
          BlocProvider.value(value: marketCubit),
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
    final cubit = MarketCubit(GetMarketAssetsUseCase(repo), repo);
    await cubit.loadAssets();

    await tester.pumpWidget(_buildApp(marketCubit: cubit));
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
    final cubit = MarketCubit(GetMarketAssetsUseCase(repo), repo);
    await cubit.loadAssets();

    await tester.pumpWidget(_buildApp(marketCubit: cubit));
    await tester.pumpAndSettle();

    expect(find.byType(FilledButton), findsOneWidget);
  });
}
