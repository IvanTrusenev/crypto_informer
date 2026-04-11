import 'package:crypto_informer/core/network/coin_gecko_api_client.dart';
import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_dto.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dto.dart';
import 'package:crypto_informer/features/market/data/models/price_chart_point_dto.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';

class CryptoRemoteDataSourceImpl implements CryptoRemoteDataSource {
  CryptoRemoteDataSourceImpl(this._client);

  final CoinGeckoApiClient _client;

  @override
  Future<List<CryptoAssetDto>> fetchMarkets({
    required String vsCurrency,
    required int page,
    required int perPage,
    required String order,
    List<String>? ids,
  }) async {
    return _client.fetchMarkets(
      vsCurrency,
      order,
      perPage,
      page,
      ids: ids != null && ids.isNotEmpty ? ids.join(',') : null,
    );
  }

  @override
  Future<List<String>> searchCoins(String query) async {
    return _client.search(query);
  }

  @override
  Future<CryptoCoinDetailDto> fetchCoin(String id) async {
    return _client.fetchCoin(id);
  }

  @override
  Future<List<PriceChartPointDto>> fetchMarketChart(
    String id, {
    required ChartPeriodEnum period,
    required String vsCurrency,
  }) async {
    return _client.fetchMarketChart(id, vsCurrency, period.apiDays);
  }
}
