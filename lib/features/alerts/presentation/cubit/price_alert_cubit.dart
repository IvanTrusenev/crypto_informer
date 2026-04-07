import 'dart:async';

import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:crypto_informer/features/alerts/domain/price_alert.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kPriceAlerts = 'price_alerts_v1';

class PriceAlertState {
  const PriceAlertState(this.alerts);
  final List<PriceAlert> alerts;

  PriceAlert? alertFor(String coinId) {
    for (final a in alerts) {
      if (a.coinId == coinId) return a;
    }
    return null;
  }
}

class PriceAlertCubit extends Cubit<PriceAlertState> {
  PriceAlertCubit(this._storage) : super(const PriceAlertState([]));

  final AppKeyValueStorage _storage;

  void loadAlerts() {
    final raw = _storage.getString(_kPriceAlerts);
    if (raw == null || raw.isEmpty) {
      emit(const PriceAlertState([]));
      return;
    }
    emit(PriceAlertState(PriceAlert.decodeList(raw)));
  }

  Future<void> setAlert(PriceAlert alert) async {
    final next = List<PriceAlert>.from(state.alerts)
      ..removeWhere((a) => a.coinId == alert.coinId)
      ..add(alert);
    await _persist(next);
    emit(PriceAlertState(next));
  }

  Future<void> removeAlert(String coinId) async {
    final next = List<PriceAlert>.from(state.alerts)
      ..removeWhere((a) => a.coinId == coinId);
    await _persist(next);
    emit(PriceAlertState(next));
  }

  List<PriceAlert> checkAndConsume(List<CryptoAssetEntity> assets) {
    final priceMap = {for (final a in assets) a.id: a.currentPriceUsd};
    final triggered = <PriceAlert>[];

    for (final alert in state.alerts) {
      final price = priceMap[alert.coinId];
      if (price == null) continue;
      final hit = alert.isAbove
          ? price >= alert.thresholdPrice
          : price <= alert.thresholdPrice;
      if (hit) triggered.add(alert);
    }

    if (triggered.isNotEmpty) {
      final remaining = List<PriceAlert>.from(state.alerts)
        ..removeWhere((a) => triggered.any((t) => t.coinId == a.coinId));
      unawaited(_persist(remaining));
      emit(PriceAlertState(remaining));
    }

    return triggered;
  }

  Future<void> _persist(List<PriceAlert> alerts) =>
      _storage.setString(_kPriceAlerts, PriceAlert.encodeList(alerts));
}
