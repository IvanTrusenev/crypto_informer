import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class GetMarketAssets {
  const GetMarketAssets(this._repository);

  final CryptoRepository _repository;

  Future<List<CryptoAssetEntity>> call({String vsCurrency = 'usd'}) {
    return _repository.getMarketAssets(vsCurrency: vsCurrency);
  }
}
