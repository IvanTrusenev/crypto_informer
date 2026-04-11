import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/coin_gecko_api_client.dart';
import 'package:crypto_informer/core/network/dio/coingecko_retrofit_api.dart';
import 'package:crypto_informer/core/network/dio/mapper/dio_exception_mapper.dart';
import 'package:crypto_informer/core/network/parser/coin_detail_response_parser.dart';
import 'package:crypto_informer/core/network/parser/market_chart_response_parser.dart';
import 'package:crypto_informer/core/network/parser/markets_response_parser.dart';
import 'package:crypto_informer/core/network/parser/search_ids_response_parser.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:dio/dio.dart';

class DioCoinGeckoApiClient implements CoinGeckoApiClient {
  DioCoinGeckoApiClient(
    this._client,
    this._marketsParser,
    this._searchIdsParser,
    this._coinDetailParser,
    this._marketChartParser,
  );

  final CoinGeckoRetrofitApi _client;
  final MarketsResponseParser _marketsParser;
  final SearchIdsResponseParser _searchIdsParser;
  final CoinDetailResponseParser _coinDetailParser;
  final MarketChartResponseParser _marketChartParser;

  @override
  Future<List<CryptoAssetDto>> fetchMarkets(
    String vsCurrency,
    String order,
    int perPage,
    int page, {
    bool sparkline = false,
    String? ids,
  }) async {
    final list = await _mapRequestErrors(
      () => _client.fetchMarkets(
        vsCurrency,
        order,
        perPage,
        page,
        sparkline: sparkline,
        ids: ids,
      ),
    );
    return _mapResponseParsing(() => _marketsParser.parse(list));
  }

  @override
  Future<List<String>> search(String query) async {
    final data = await _mapRequestErrors(() => _client.search(query));
    return _mapResponseParsing(() => _searchIdsParser.parse(data));
  }

  @override
  Future<CryptoCoinDetailDto> fetchCoin(String id) async {
    final data = await _mapRequestErrors(
      () => _client.fetchCoin(id),
      mapCoinNotFound: true,
    );
    return _mapResponseParsing(() => _coinDetailParser.parse(data));
  }

  @override
  Future<List<PriceChartPointDto>> fetchMarketChart(
    String id,
    String vsCurrency,
    String days,
  ) async {
    final data = await _mapRequestErrors(
      () => _client.fetchMarketChart(id, vsCurrency, days),
      mapCoinNotFound: true,
    );
    return _mapResponseParsing(() => _marketChartParser.parse(data));
  }

  Future<T> _mapRequestErrors<T>(
    Future<T> Function() request, {
    bool mapCoinNotFound = false,
  }) async {
    try {
      return await request();
    } on DioException catch (e) {
      final exception = e.toAppException();
      if (mapCoinNotFound && exception is NotFoundException) {
        throw const CoinNotFoundException();
      }
      throw exception;
    }
  }

  T _mapResponseParsing<T>(T Function() parse) {
    try {
      return parse();
    } on AppException {
      rethrow;
    } on Object catch (_) {
      throw const ResponseParsingException();
    }
  }
}
