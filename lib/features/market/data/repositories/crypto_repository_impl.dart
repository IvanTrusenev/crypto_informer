import 'dart:async' show unawaited;
import 'dart:isolate';

import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_cache_data_source.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_cache_model_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_detail_cache_model_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_detail_dto_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_detail_entity_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_dto_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/coin_entity_mapper.dart';
import 'package:crypto_informer/features/market/data/mapper/price_chart_point_dto_mapper.dart';
import 'package:crypto_informer/features/market/data/utils/price_chart_sampling.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._remote, this._cache);

  final CryptoRemoteDataSource _remote;
  final CryptoCacheDataSource _cache;

  @override
  Future<List<CoinEntity>?> getCachedMarketAssetsFirstPage({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  }) async {
    try {
      final models = await _cache.readCachedMarketAssets(
        vsCurrency: vsCurrency,
      );
      if (models?.isEmpty ?? true) return null;
      return models!.map((model) => model.toEntity()).toList();
    } on CacheException {
      return null;
    }
  }

  @override
  Future<List<CoinEntity>> getMarketAssets({
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
      _processInBackground(() async {
        await _cache.replaceCachedMarketAssets(
          list.map((e) => e.toCacheModel()).toList(),
          vsCurrency: vsCurrency,
        );
      });
    }
    return list;
  }

  @override
  Future<List<String>> searchCoinIds(String query) =>
      _remote.searchCoins(query);

  @override
  Future<CoinDetailEntity?> getCachedCoinDetail(String id) async {
    try {
      final model = await _cache.readCachedCoinDetail(id);
      return model?.toEntity();
    } on CacheException {
      return null;
    }
  }

  @override
  Future<CoinDetailEntity> getCoinDetail(String id) async {
    final model = await _remote.fetchCoin(id);
    final detail = model.toEntity();
    _processInBackground(() async {
      await _cache.saveCachedCoinDetail(detail.toCacheModel());
    });
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

  void _processInBackground(Future<void> Function() work) {
    unawaited(
      (() async {
        try {
          await work();
        } on CacheException {
          // Best-effort; при сбое кэш догонит при следующем успешном запросе.
        }
      })(),
    );
  }
}
