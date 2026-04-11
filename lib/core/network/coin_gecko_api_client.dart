import 'package:crypto_informer/features/market/data/models/coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/coin_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';

abstract interface class CoinGeckoApiClient {
  Future<List<CoinDto>> fetchMarkets(
    String vsCurrency,
    String order,
    int perPage,
    int page, {
    bool sparkline = false,
    String? ids,
  });

  Future<List<String>> search(String query);

  Future<CoinDetailDto> fetchCoin(String id);

  Future<List<PriceChartPointDto>> fetchMarketChart(
    String id,
    String vsCurrency,
    String days,
  );
}
