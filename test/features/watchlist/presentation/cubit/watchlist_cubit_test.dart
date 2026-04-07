import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage_impl.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppKeyValueStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storage = AppKeyValueStorageImpl(prefs);
  });

  blocTest<WatchlistCubit, WatchlistState>(
    'loadIds loads empty list from SharedPreferences',
    build: () => WatchlistCubit(storage),
    act: (cubit) => cubit.loadIds(),
    expect: () => [
      isA<WatchlistLoaded>().having((s) => s.ids, 'ids', isEmpty),
    ],
  );

  blocTest<WatchlistCubit, WatchlistState>(
    'toggle adds an ID',
    build: () => WatchlistCubit(storage)..loadIds(),
    act: (cubit) => cubit.toggle('bitcoin'),
    expect: () => [
      isA<WatchlistLoaded>().having(
        (s) => s.ids,
        'ids',
        ['bitcoin'],
      ),
    ],
  );

  group('toggle removes an existing ID', () {
    blocTest<WatchlistCubit, WatchlistState>(
      'toggle removes existing ID',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          'watchlist_coin_ids': ['bitcoin', 'ethereum'],
        });
        final prefs = await SharedPreferences.getInstance();
        storage = AppKeyValueStorageImpl(prefs);
      },
      build: () => WatchlistCubit(storage)..loadIds(),
      act: (cubit) => cubit.toggle('bitcoin'),
      expect: () => [
        isA<WatchlistLoaded>().having(
          (s) => s.ids,
          'ids',
          ['ethereum'],
        ),
      ],
    );
  });
}
