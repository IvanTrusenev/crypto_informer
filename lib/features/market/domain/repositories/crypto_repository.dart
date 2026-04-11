import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_detail_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';

/// Контракт доступа к данным о криптоактивах (реализация — в data).
abstract interface class CryptoRepository {
  /// Первая страница из локального кэша, без сети. `null` — нет данных.
  Future<List<CoinEntity>?> getCachedMarketAssetsFirstPage({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  });

  Future<List<CoinEntity>> getMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
    int page = MarketListQueryDefaults.page,
    int perPage = MarketListQueryDefaults.perPage,
    String order = MarketListQueryDefaults.order,
    List<String>? ids,
  });

  /// Full-text search via `/search?query=`. Returns matching coin IDs.
  Future<List<String>> searchCoinIds(String query);

  /// Карточка монеты из локального кэша, без сети. `null` — нет данных.
  Future<CoinDetailEntity?> getCachedCoinDetail(String id);

  Future<CoinDetailEntity> getCoinDetail(String id);

  /// История цен только с сети (кэш в БД не используется).
  Future<List<PriceChartPointEntity>> getPriceChart(
    String coinId, {
    ChartPeriodEnum period = ChartPeriodEnum.days7,
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  });
}
