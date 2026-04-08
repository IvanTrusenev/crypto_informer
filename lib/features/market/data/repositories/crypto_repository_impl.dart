import 'dart:async' show unawaited;
import 'dart:isolate';

import 'package:crypto_informer/features/market/data/datasources/crypto_local_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_asset_dao_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_asset_dto_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_asset_entity_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_coin_detail_dao_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_coin_detail_dto_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/crypto_coin_detail_entity_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/price_chart_point_dto_mapper.dart';
import 'package:crypto_informer/features/market/data/utils/price_chart_sampling.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._remote, this._local);

  final CryptoRemoteDataSource _remote;
  final CryptoLocalDataSource _local;

  @override
  Future<List<CryptoAssetEntity>?> getCachedMarketAssetsFirstPage({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    try {
      final daos = await _local.readMarketAssets(vsCurrency: vsCurrency);
      if (daos == null || daos.isEmpty) return null;
      return daos.map((d) => d.toEntity()).toList();
    } on Object {
      return null;
    }
  }

  @override
  Future<List<CryptoAssetEntity>> getMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
    int page = MarketListQueryDefaults.page,
    int perPage = MarketListQueryDefaults.perPage,
    String order = MarketListQueryDefaults.order,
    List<String>? ids,
  }) async {
    final models = await _remote.fetchMarkets(
      vsCurrency: vsCurrency,
      page: page,
      perPage: perPage,
      order: order,
      ids: ids,
    );
    final list = await Isolate.run(
      () => models.map((m) => m.toEntity()).toList(),
    );
    if (ids == null) {
      _cacheMarketAssetsFirstPageInBackground(list, vsCurrency);
    }
    return list;
  }

  @override
  Future<List<String>> searchCoinIds(String query) =>
      _remote.searchCoins(query);

  @override
  Future<CryptoCoinDetailEntity?> getCachedCoinDetail(String id) async {
    try {
      final dao = await _local.readCoinDetail(id);
      return dao?.toEntity();
    } on Object {
      return null;
    }
  }

  @override
  Future<CryptoCoinDetailEntity> getCoinDetail(String id) async {
    final model = await _remote.fetchCoin(id);
    final detail = model.toEntity();
    _cacheCoinDetailInBackground(detail);
    return detail;
  }

  @override
  Future<List<PriceChartPointEntity>> getPriceChart(
    String coinId, {
    ChartPeriodEnum period = ChartPeriodEnum.days7,
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    final dtos = await _remote.fetchMarketChart(
      coinId,
      period: period,
      vsCurrency: vsCurrency,
    );
    return Isolate.run(() {
      final entities = dtos.map((d) => d.toEntity()).toList();
      return samplePriceChartPoints(entities);
    });
  }

  /// Кэш первой страницы в фоне, без ожидания записи.
  void _cacheMarketAssetsFirstPageInBackground(
    List<CryptoAssetEntity> list,
    String vsCurrency,
  ) {
    unawaited(_persistMarketAssetsFirstPage(list, vsCurrency));
  }

  Future<void> _persistMarketAssetsFirstPage(
    List<CryptoAssetEntity> list,
    String vsCurrency,
  ) async {
    try {
      await _local.replaceMarketAssets(
        list.map((e) => e.toDao()).toList(),
        vsCurrency: vsCurrency,
      );
    } on Object {
      // Best-effort; при сбое кэш догонит при следующем успешном запросе.
    }
  }

  void _cacheCoinDetailInBackground(CryptoCoinDetailEntity detail) {
    unawaited(_persistCoinDetail(detail));
  }

  Future<void> _persistCoinDetail(CryptoCoinDetailEntity detail) async {
    try {
      await _local.saveCoinDetail(detail.toDao());
    } on Object {
      // Best-effort; при сбое кэш догонит при следующем успешном запросе.
    }
  }
}
