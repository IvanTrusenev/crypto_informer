import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';

/// Контракт доступа к данным о криптоактивах (реализация — в data).
abstract interface class CryptoRepository {
  Future<List<CryptoAsset>> getMarketAssets({String vsCurrency});

  Future<CryptoCoinDetail> getCoinDetail(String id);
}
