import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';
import 'package:dio/dio.dart';

abstract interface class CryptoRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchMarkets({String vsCurrency});

  Future<Map<String, dynamic>> fetchCoin(String id);

  Future<List<PriceChartPoint>> fetchMarketChart(
    String id, {
    required ChartPeriod period,
    String vsCurrency = 'usd',
  });
}

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  CryptoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Map<String, dynamic>>> fetchMarkets({
    String vsCurrency = 'usd',
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/coins/markets',
        queryParameters: {
          'vs_currency': vsCurrency,
          'order': 'market_cap_desc',
          'per_page': 50,
          'page': 1,
          'sparkline': false,
        },
      );
      final list = response.data;
      if (list == null) {
        throw const AppException(AppErrorCode.emptyResponse);
      }
      return list.whereType<Map<String, dynamic>>().toList(growable: false);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchCoin(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/coins/$id');
      final data = response.data;
      if (data == null) {
        throw const AppException(AppErrorCode.emptyResponse);
      }
      return data;
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
      final response = await _dio.get<Map<String, dynamic>>(
        '/coins/$id/market_chart',
        queryParameters: {
          'vs_currency': vsCurrency,
          'days': period.apiDays,
        },
      );
      final data = response.data;
      if (data == null) {
        throw const AppException(AppErrorCode.emptyResponse);
      }
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
