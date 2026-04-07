import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/rest/coingecko_rest_client.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';
import 'package:dio/dio.dart';

abstract interface class CryptoRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchMarkets({
    String vsCurrency,
    int page,
    int perPage,
    String order,
    List<String>? ids,
  });

  /// Full-text search via `/search?query=...`.
  /// Returns a list of coin IDs sorted by market cap.
  Future<List<String>> searchCoins(String query);

  Future<Map<String, dynamic>> fetchCoin(String id);

  Future<List<PriceChartPoint>> fetchMarketChart(
    String id, {
    required ChartPeriod period,
    String vsCurrency = 'usd',
  });
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  CryptoRemoteDataSourceImpl(this._client);

  final CoinGeckoRestClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchMarkets({
    String vsCurrency = 'usd',
    int page = 1,
    int perPage = 50,
    String order = 'market_cap_desc',
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
      return list.whereType<Map<String, dynamic>>().toList(growable: false);
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
  Future<Map<String, dynamic>> fetchCoin(String id) async {
    try {
      return await _client.fetchCoin(id);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AppException(AppErrorCode.coinNotFound);
      }
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<PriceChartPoint>> fetchMarketChart(
    String id, {
    required ChartPeriod period,
    String vsCurrency = 'usd',
  }) async {
    try {
      final data = await _client.fetchMarketChart(
        id,
        vsCurrency,
        period.apiDays,
      );
      return _parseMarketChartPrices(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AppException(AppErrorCode.coinNotFound);
      }
      throw _mapDioException(e);
    }
  }

  List<PriceChartPoint> _parseMarketChartPrices(Map<String, dynamic> json) {
    final raw = json['prices'];
    if (raw is! List) {
      return const [];
    }
    final out = <PriceChartPoint>[];
    for (final item in raw) {
      if (item is List<dynamic> && item.length >= 2) {
        final t = item[0];
        final p = item[1];
        if (t is num && p is num) {
          out.add(
            PriceChartPoint(
              timestamp: DateTime.fromMillisecondsSinceEpoch(t.toInt()),
              priceUsd: p.toDouble(),
            ),
          );
        }
      }
    }
    return out;
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
