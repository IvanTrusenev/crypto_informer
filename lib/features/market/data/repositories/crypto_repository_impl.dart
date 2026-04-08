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
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:crypto_informer/features/market/domain/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._remote, this._local);

  final CryptoRemoteDataSource _remote;
  final CryptoLocalDataSource _local;

  @override
  Future<List<CryptoAssetEntity>> getMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
    int page = MarketListQueryDefaults.page,
    int perPage = MarketListQueryDefaults.perPage,
    String order = MarketListQueryDefaults.order,
    List<String>? ids,
  }) async {
    List<CryptoAssetEntity>? cached;
    if (page == 1 && ids == null) {
      try {
        final daos = await _local.readMarketAssets(vsCurrency: vsCurrency);
        cached = daos?.map((d) => d.toEntity()).toList();
      } on Object {
        cached = null;
      }
    }

    try {
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
        await _local.replaceMarketAssets(
          list.map((e) => e.toDao()).toList(),
          vsCurrency: vsCurrency,
        );
      }
      return list;
    } on Object {
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<String>> searchCoinIds(String query) =>
      _remote.searchCoins(query);

  @override
  Future<CryptoCoinDetailEntity> getCoinDetail(String id) async {
    CryptoCoinDetailEntity? cached;
    try {
      final dao = await _local.readCoinDetail(id);
      cached = dao?.toEntity();
    } on Object {
      cached = null;
    }

    try {
      final model = await _remote.fetchCoin(id);
      final detail = model.toEntity();
      await _local.saveCoinDetail(detail.toDao());
      return detail;
    } on Object {
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<PriceChartPointEntity>> getPriceChart(
    String coinId, {
    ChartPeriod period = ChartPeriod.days7,
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
}
