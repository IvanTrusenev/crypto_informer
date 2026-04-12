import 'dart:io';

import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:crypto_informer/features/market/presentation/cubit/search/export.dart';
import 'package:crypto_informer/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MockCryptoRepository extends Mock implements CryptoRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Приложение строит нижнюю навигацию', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final AppKeyValueStorage storage = AppKeyValueStorageImpl(prefs);
    final mockRepo = _MockCryptoRepository();
    when(
      () => mockRepo.getCachedMarketAssetsFirstPage(
        vsCurrency: any(named: 'vsCurrency'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => mockRepo.getMarketAssets(
        vsCurrency: any(named: 'vsCurrency'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
        order: any(named: 'order'),
        ids: any(named: 'ids'),
      ),
    ).thenAnswer((_) async => []);

    final getAssets = GetMarketAssetsUseCase(mockRepo);
    final searchBloc = SearchBloc(
      SearchCoinIdsUseCase(mockRepo),
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
          BlocProvider(
            create: (_) => AppSettingsCubit(storage)..loadSettings(),
          ),
          BlocProvider.value(value: searchBloc),
          BlocProvider.value(value: marketBloc),
          BlocProvider(
            create: (_) => WatchlistCubit(storage)..loadIds(),
          ),
        ],
        child: const CryptoInformerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Market'), findsWidgets);
  });
}
