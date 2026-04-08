import 'package:crypto_informer/features/market/data/models/crypto_asset_dao.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_dao.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';

abstract interface class CryptoLocalDataSource {
  Future<List<CryptoAssetDao>?> readMarketAssets({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  });

  Future<void> replaceMarketAssets(
    List<CryptoAssetDao> items, {
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
  });

  Future<CryptoCoinDetailDao?> readCoinDetail(String id);

  Future<void> saveCoinDetail(CryptoCoinDetailDao detail);
}
