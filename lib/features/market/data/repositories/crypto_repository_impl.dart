import 'package:crypto_informer/features/market/data/datasources/crypto_remote_data_source.dart';
import 'package:crypto_informer/features/market/data/models/crypto_asset_model.dart';
import 'package:crypto_informer/features/market/data/models/crypto_coin_detail_model.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_coin_detail.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  CryptoRepositoryImpl(this._remote);

  final CryptoRemoteDataSource _remote;

  @override
  Future<List<CryptoAsset>> getMarketAssets({String vsCurrency = 'usd'}) async {
    final rows = await _remote.fetchMarkets(vsCurrency: vsCurrency);
    return rows
        .map(CryptoAssetModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<CryptoCoinDetail> getCoinDetail(String id) async {
    final row = await _remote.fetchCoin(id);
    return CryptoCoinDetailModel.fromJson(row).toEntity();
  }
}
