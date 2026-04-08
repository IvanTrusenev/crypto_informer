// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coingecko_rest_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _CoinGeckoRestClient implements CoinGeckoRestClient {
  _CoinGeckoRestClient(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  @override
  Future<List<dynamic>> fetchMarkets(
    String vsCurrency,
    String order,
    int perPage,
    int page, {
    bool sparkline = false,
    String? ids,
  }) async {
    final queryParameters = <String, dynamic>{
      'vs_currency': vsCurrency,
      'order': order,
      'per_page': perPage,
      'page': page,
      'sparkline': sparkline,
    };
    if (ids != null) {
      queryParameters['ids'] = ids;
    }
    final result = await _dio.fetch<List<dynamic>>(
      Options(method: 'GET').compose(
        _dio.options,
        CoinGeckoApi.coinsMarkets,
        queryParameters: queryParameters,
      ),
    );
    return result.data!;
  }

  @override
  Future<Map<String, dynamic>> search(String query) async {
    final result = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(
        _dio.options,
        CoinGeckoApi.search,
        queryParameters: <String, dynamic>{'query': query},
      ),
    );
    return result.data!;
  }

  @override
  Future<Map<String, dynamic>> fetchCoin(String id) async {
    final result = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(
        _dio.options,
        CoinGeckoApi.coinPath(id),
      ),
    );
    return result.data!;
  }

  @override
  Future<Map<String, dynamic>> fetchMarketChart(
    String id,
    String vsCurrency,
    String days,
  ) async {
    final result = await _dio.fetch<Map<String, dynamic>>(
      Options(method: 'GET').compose(
        _dio.options,
        CoinGeckoApi.coinMarketChartPath(id),
        queryParameters: <String, dynamic>{
          'vs_currency': vsCurrency,
          'days': days,
        },
      ),
    );
    return result.data!;
  }
}
