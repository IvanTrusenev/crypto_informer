import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  WatchlistCubit(this._prefs) : super(const WatchlistInitial());

  final SharedPreferences _prefs;

  void loadIds() {
    final ids = List<String>.from(
      _prefs.getStringList(_kWatchlistIds) ?? [],
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
    await _prefs.setStringList(_kWatchlistIds, next);
    emit(WatchlistLoaded(next));
  }

  List<String> get _currentIds {
    final s = state;
    if (s is WatchlistLoaded) return s.ids;
    return [];
  }
}
