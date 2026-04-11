import 'package:crypto_informer/core/network/coin_gecko_api_client.dart';
import 'package:crypto_informer/core/network/coingecko_endpoints.dart';
import 'package:crypto_informer/core/network/dio/coingecko_retrofit_api.dart';
import 'package:crypto_informer/core/network/dio/dio_coin_gecko_api_client.dart';
import 'package:crypto_informer/core/network/parser/coin_detail_response_parser.dart';
import 'package:crypto_informer/core/network/parser/market_chart_response_parser.dart';
import 'package:crypto_informer/core/network/parser/markets_response_parser.dart';
import 'package:crypto_informer/core/network/parser/search_ids_response_parser.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

void registerNetworkModule(GetIt sl) {
  sl
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: CoinGeckoEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      ),
    )
    ..registerLazySingleton<CoinGeckoRetrofitApi>(
      () => CoinGeckoRetrofitApi(sl<Dio>()),
    )
    ..registerLazySingleton<MarketsResponseParser>(MarketsResponseParser.new)
    ..registerLazySingleton<SearchIdsResponseParser>(SearchIdsResponseParser.new)
    ..registerLazySingleton<CoinDetailResponseParser>(
      CoinDetailResponseParser.new,
    )
    ..registerLazySingleton<MarketChartResponseParser>(
      MarketChartResponseParser.new,
    )
    ..registerLazySingleton<CoinGeckoApiClient>(
      () => DioCoinGeckoApiClient(
        sl<CoinGeckoRetrofitApi>(),
        sl<MarketsResponseParser>(),
        sl<SearchIdsResponseParser>(),
        sl<CoinDetailResponseParser>(),
        sl<MarketChartResponseParser>(),
      ),
    );
}
