import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:dio/dio.dart';

abstract interface class CryptoRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchMarkets({String vsCurrency});

  Future<Map<String, dynamic>> fetchCoin(String id);
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
        throw const AppException('Пустой ответ сервера');
      }
      return list
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
    } on DioException catch (e) {
      throw AppException(_messageFromDio(e));
    }
  }

  @override
  Future<Map<String, dynamic>> fetchCoin(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/coins/$id');
      final data = response.data;
      if (data == null) {
        throw const AppException('Пустой ответ сервера');
      }
      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AppException('Монета не найдена');
      }
      throw AppException(_messageFromDio(e));
    }
  }

  String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Превышено время ожидания. Проверьте сеть.';
    }
    if (status != null) {
      return 'Ошибка сервера ($status)';
    }
    return e.message ?? 'Ошибка сети';
  }
}
