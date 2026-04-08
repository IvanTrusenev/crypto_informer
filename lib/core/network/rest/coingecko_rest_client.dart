import 'package:crypto_informer/core/network/rest/coingecko_api.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'coingecko_rest_client.g.dart';

@RestApi()
abstract class CoinGeckoRestClient {
  factory CoinGeckoRestClient(Dio dio, {String baseUrl}) =
      _CoinGeckoRestClient;

  @GET(CoinGeckoApi.coinsMarkets)
  Future<List<dynamic>> fetchMarkets(
    @Query('vs_currency') String vsCurrency,
    @Query('order') String order,
    @Query('per_page') int perPage,
    @Query('page') int page, {
    @Query('sparkline') bool sparkline = false,
    @Query('ids') String? ids,
  });

  @GET(CoinGeckoApi.search)
  Future<Map<String, dynamic>> search(
    @Query('query') String query,
  );

  @GET(CoinGeckoApi.coinById)
  Future<Map<String, dynamic>> fetchCoin(
    @Path('id') String id,
  );

  @GET(CoinGeckoApi.coinMarketChart)
  Future<Map<String, dynamic>> fetchMarketChart(
    @Path('id') String id,
    @Query('vs_currency') String vsCurrency,
    @Query('days') String days,
  );
}
