import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point.dart';

/// Контракт доступа к данным о криптоактивах (реализация — в data).
abstract interface class CryptoRepository {
  Future<List<CryptoAsset>> getMarketAssets({String vsCurrency});

  Future<CryptoCoinDetail> getCoinDetail(String id);

  /// История цен только с сети (кэш в БД не используется).
  Future<List<PriceChartPoint>> getPriceChart(
    String coinId, {
    ChartPeriod period,
    String vsCurrency,
  });
}
