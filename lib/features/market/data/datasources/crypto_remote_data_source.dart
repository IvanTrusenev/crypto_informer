import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';

abstract interface class CryptoRemoteDataSource {
  Future<List<CryptoAssetDto>> fetchMarkets({
    String vsCurrency,
    int page,
    int perPage,
    String order,
    List<String>? ids,
  });

  /// Full-text search via `/search?query=...`.
  /// Returns a list of coin IDs sorted by market cap.
  Future<List<String>> searchCoins(String query);

  Future<CryptoCoinDetailDto> fetchCoin(String id);

  Future<List<PriceChartPointDto>> fetchMarketChart(
    String id, {
    required ChartPeriod period,
    String vsCurrency = 'usd',
  });
}
