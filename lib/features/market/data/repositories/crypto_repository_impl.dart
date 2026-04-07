import 'dart:isolate';

import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_model.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_model.dart';
import 'package:crypto_informer/features/market/data/utils/price_chart_sampling.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._remote, this._local);

  final CryptoRemoteDataSource _remote;
  final CryptoLocalDataSource _local;

  @override
  Future<List<CryptoAsset>> getMarketAssets({
    String vsCurrency = 'usd',
  }) async {
    List<CryptoAsset>? cached;
    try {
      cached = await _local.readMarketAssets(vsCurrency: vsCurrency);
    } on Object {
      cached = null;
    }

    try {
      final rows = await _remote.fetchMarkets(vsCurrency: vsCurrency);
      final list = await Isolate.run(
        () => rows
            .map(CryptoAssetModel.fromJson)
            .map((m) => m.toEntity())
            .toList(),
      );
      await _local.replaceMarketAssets(list, vsCurrency: vsCurrency);
      return list;
    } on Object {
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<CryptoCoinDetail> getCoinDetail(String id) async {
    CryptoCoinDetail? cached;
    try {
      cached = await _local.readCoinDetail(id);
    } on Object {
      cached = null;
    }

    try {
      final row = await _remote.fetchCoin(id);
      final detail = CryptoCoinDetailModel.fromJson(row).toEntity();
      await _local.saveCoinDetail(detail);
      return detail;
    } on Object {
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<PriceChartPoint>> getPriceChart(
    String coinId, {
    ChartPeriod period = ChartPeriod.days7,
    String vsCurrency = 'usd',
  }) async {
    final raw = await _remote.fetchMarketChart(
      coinId,
      period: period,
      vsCurrency: vsCurrency,
    );
    return Isolate.run(() => samplePriceChartPoints(raw));
  }
}
