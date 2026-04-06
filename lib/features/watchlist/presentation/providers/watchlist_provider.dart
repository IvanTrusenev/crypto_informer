import 'package:crypto_informer/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kWatchlistIds = 'watchlist_coin_ids';

final watchlistProvider =
    AsyncNotifierProvider<WatchlistNotifier, List<String>>(
      WatchlistNotifier.new,
    );

class WatchlistNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return List<String>.from(prefs.getStringList(_kWatchlistIds) ?? []);
  }

  Future<void> toggle(String id) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final prev = await future;
    final next = List<String>.from(prev);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    await prefs.setStringList(_kWatchlistIds, next);
    state = AsyncData(next);
  }
}
