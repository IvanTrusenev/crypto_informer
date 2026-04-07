import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';

/// Контракт доступа к данным о криптоактивах (реализация — в data).
abstract interface class CryptoRepository {
  Future<List<CryptoAssetEntity>> getMarketAssets({
    String vsCurrency,
    int page,
    int perPage,
    String order,
    List<String>? ids,
  });

  /// Full-text search via `/search?query=`. Returns matching coin IDs.
  Future<List<String>> searchCoinIds(String query);

  Future<CryptoCoinDetailEntity> getCoinDetail(String id);

  /// История цен только с сети (кэш в БД не используется).
  Future<List<PriceChartPointEntity>> getPriceChart(
    String coinId, {
    ChartPeriod period,
    String vsCurrency,
  });
}
