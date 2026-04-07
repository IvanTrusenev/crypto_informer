import 'package:bloc_test/bloc_test.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  blocTest<WatchlistCubit, WatchlistState>(
    'loadIds loads empty list from SharedPreferences',
    build: () => WatchlistCubit(prefs),
    act: (cubit) => cubit.loadIds(),
    expect: () => [
      isA<WatchlistLoaded>().having((s) => s.ids, 'ids', isEmpty),
    ],
  );

  blocTest<WatchlistCubit, WatchlistState>(
    'toggle adds an ID',
    build: () => WatchlistCubit(prefs)..loadIds(),
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
        prefs = await SharedPreferences.getInstance();
      },
      build: () => WatchlistCubit(prefs)..loadIds(),
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
