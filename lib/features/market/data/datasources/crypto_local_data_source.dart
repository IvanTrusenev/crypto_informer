import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail_entity.dart';

abstract interface class CryptoLocalDataSource {
  Future<List<CryptoAssetEntity>?> readMarketAssets({String vsCurrency});

  Future<void> replaceMarketAssets(
    List<CryptoAssetEntity> items, {
    String vsCurrency,
  });

  Future<CryptoCoinDetailEntity?> readCoinDetail(String id);

  Future<void> saveCoinDetail(CryptoCoinDetailEntity detail);
}
