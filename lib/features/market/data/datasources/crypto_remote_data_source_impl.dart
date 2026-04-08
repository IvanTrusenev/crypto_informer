import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/rest/coingecko_rest_client.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:dio/dio.dart';

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  CryptoRemoteDataSourceImpl(this._client);

  final CoinGeckoRestClient _client;

  @override
  Future<List<CryptoAssetDto>> fetchMarkets({
    required String vsCurrency,
    required int page,
    required int perPage,
    required String order,
    List<String>? ids,
  }) async {
    try {
      final list = await _client.fetchMarkets(
        vsCurrency,
        order,
        perPage,
        page,
        ids: ids != null && ids.isNotEmpty ? ids.join(',') : null,
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(CryptoAssetDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<String>> searchCoins(String query) async {
    try {
      final data = await _client.search(query);
      final coins = data['coins'];
      if (coins is! List) return const [];
      return coins
          .whereType<Map<String, dynamic>>()
          .map((c) => c['id'] as String)
          .toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<CryptoCoinDetailDto> fetchCoin(String id) async {
    try {
      final data = await _client.fetchCoin(id);
      return CryptoCoinDetailDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AppException(AppErrorCode.coinNotFound);
      }
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<PriceChartPointDto>> fetchMarketChart(
    String id, {
    required ChartPeriodEnum period,
    required String vsCurrency,
  }) async {
    try {
      final data = await _client.fetchMarketChart(
        id,
        vsCurrency,
        period.apiDays,
      );
      return _parsePrices(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AppException(AppErrorCode.coinNotFound);
      }
      throw _mapDioException(e);
    }
  }

  List<PriceChartPointDto> _parsePrices(Map<String, dynamic> json) {
    final raw = json['prices'];
    if (raw is! List) return const [];
    return raw
        .whereType<List<dynamic>>()
        .where((pair) => pair.length >= 2 && pair[0] is num && pair[1] is num)
        .map(
          (pair) => PriceChartPointDto(
            timestampMs: (pair[0] as num).toInt(),
            priceUsd: (pair[1] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }

  AppException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException(AppErrorCode.timeout);
    }
    if (status != null) {
      return AppException(AppErrorCode.serverError, statusCode: status);
    }
    return const AppException(AppErrorCode.network);
  }
}
