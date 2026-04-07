import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/rest/coingecko_rest_client.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:dio/dio.dart';

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  CryptoRemoteDataSourceImpl(this._client);

  final CoinGeckoRestClient _client;

  @override
  Future<List<CryptoAssetDto>> fetchMarkets({
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
    required ChartPeriod period,
    String vsCurrency = 'usd',
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
    final out = <PriceChartPointDto>[];
    for (final item in raw) {
      if (item is List<dynamic> && item.length >= 2) {
        final t = item[0];
        final p = item[1];
        if (t is num && p is num) {
          out.add(
            PriceChartPointDto(
              timestampMs: t.toInt(),
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
