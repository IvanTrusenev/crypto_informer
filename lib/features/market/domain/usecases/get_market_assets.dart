import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class GetMarketAssets {
  const GetMarketAssets(this._repository);

  final CryptoRepository _repository;

  Future<List<CryptoAsset>> call({String vsCurrency = 'usd'}) {
    return _repository.getMarketAssets(vsCurrency: vsCurrency);
  }
}
