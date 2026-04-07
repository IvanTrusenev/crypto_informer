import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kWatchlistIds = 'watchlist_coin_ids';

sealed class WatchlistState {
  const WatchlistState();
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoaded extends WatchlistState {
  const WatchlistLoaded(this.ids);
  final List<String> ids;
}

class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit(this._storage) : super(const WatchlistInitial());

  final AppKeyValueStorage _storage;

  void loadIds() {
    final ids = List<String>.from(
      _storage.getStringList(_kWatchlistIds) ?? [],
    );
    emit(WatchlistLoaded(ids));
  }

  Future<void> toggle(String id) async {
    final prev = _currentIds;
    final next = List<String>.from(prev);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    await _storage.setStringList(_kWatchlistIds, next);
    emit(WatchlistLoaded(next));
  }

  List<String> get _currentIds {
    final s = state;
    if (s is WatchlistLoaded) return s.ids;
    return [];
  }
}
