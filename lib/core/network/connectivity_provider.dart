import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Текущее состояние радио-интерфейсов (Wi‑Fi / мобильная сеть / offline).
final connectivityListProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final connectivity = Connectivity();
  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});

bool listIndicatesOffline(List<ConnectivityResult> results) {
  return results.contains(ConnectivityResult.none);
}
