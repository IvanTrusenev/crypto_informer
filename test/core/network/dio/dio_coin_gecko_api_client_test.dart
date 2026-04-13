import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/network/dio/coin_gecko_retrofit_api.dart';
import 'package:crypto_informer/core/network/dio/dio_coin_gecko_api_client.dart';
import 'package:crypto_informer/core/network/parser/coin_detail_response_parser.dart';
import 'package:crypto_informer/core/network/parser/market_chart_response_parser.dart';
import 'package:crypto_informer/core/network/parser/markets_response_parser.dart';
import 'package:crypto_informer/core/network/parser/search_ids_response_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCoinGeckoRetrofitApi extends Mock implements CoinGeckoRetrofitApi {}

void main() {
  late MockCoinGeckoRetrofitApi api;
  late DioCoinGeckoApiClient client;

  setUp(() {
    api = MockCoinGeckoRetrofitApi();
    client = DioCoinGeckoApiClient(
      api,
      const MarketsResponseParser(),
      const SearchIdsResponseParser(),
      const CoinDetailResponseParser(),
      const MarketChartResponseParser(),
    );
  });

  test(
    'fetchMarkets maps raw request exceptions to ResponseParsingException',
    () async {
      when(
        () => api.fetchMarkets(
          any(),
          any(),
          any(),
          any(),
          sparkline: any(named: 'sparkline'),
          ids: any(named: 'ids'),
        ),
      ).thenThrow(const FormatException('unexpected response shape'));

      await expectLater(
        () => client.fetchMarkets('usd', 'market_cap_desc', 50, 1),
        throwsA(isA<ResponseParsingException>()),
      );
    },
  );

  test('fetchMarkets still maps DioException to AppException', () async {
    when(
      () => api.fetchMarkets(
        any(),
        any(),
        any(),
        any(),
        sparkline: any(named: 'sparkline'),
        ids: any(named: 'ids'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/coins/markets'),
        type: DioExceptionType.connectionTimeout,
      ),
    );

    await expectLater(
      () => client.fetchMarkets('usd', 'market_cap_desc', 50, 1),
      throwsA(isA<NetworkTimeoutException>()),
    );
  });
}
