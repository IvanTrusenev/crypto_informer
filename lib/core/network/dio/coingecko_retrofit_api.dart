import 'package:crypto_informer/core/network/coingecko_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'coingecko_retrofit_api.g.dart';

@RestApi()
abstract class CoinGeckoRetrofitApi {
  factory CoinGeckoRetrofitApi(Dio dio, {String baseUrl}) =
      _CoinGeckoRetrofitApi;

  @GET(CoinGeckoEndpoints.coinsMarkets)
  Future<List<dynamic>> fetchMarkets(
    @Query('vs_currency') String vsCurrency,
    @Query('order') String order,
    @Query('per_page') int perPage,
    @Query('page') int page, {
    @Query('sparkline') bool sparkline = false,
    @Query('ids') String? ids,
  });

  @GET(CoinGeckoEndpoints.search)
  Future<Map<String, dynamic>> search(
    @Query('query') String query,
  );

  @GET(CoinGeckoEndpoints.coinById)
  Future<Map<String, dynamic>> fetchCoin(
    @Path('id') String id,
  );

  @GET(CoinGeckoEndpoints.coinMarketChart)
  Future<Map<String, dynamic>> fetchMarketChart(
    @Path('id') String id,
    @Query('vs_currency') String vsCurrency,
    @Query('days') String days,
  );
}
