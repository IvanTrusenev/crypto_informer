import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';

/// Список рынка со stale-while-revalidate для «основного» просмотра.
///
/// Первая страница без фильтра `ids`: сначала непустой кэш SQLite (если есть),
/// затем ответ сети. Ошибка сети после показа кэша не пробрасывается.
///
/// Пагинация и поиск (`ids` задан): кэш первой страницы не читается; один
/// элемент в потоке — ответ API.
class GetMarketAssets {
  const GetMarketAssets(this._repository);

  final CryptoRepository _repository;

  Stream<List<CryptoAssetEntity>> call({
    String vsCurrency = MarketListQueryDefaults.vsCurrency,
    int page = MarketListQueryDefaults.page,
    int perPage = MarketListQueryDefaults.perPage,
    String order = MarketListQueryDefaults.order,
    List<String>? ids,
  }) async* {
    final isBrowseFirstPage =
        page == MarketListQueryDefaults.page && ids == null;
    var yieldedStale = false;
    if (isBrowseFirstPage) {
      final stale = await _repository.getCachedMarketAssetsFirstPage(
        vsCurrency: vsCurrency,
      );
      if (stale != null && stale.isNotEmpty) {
        yield stale;
        yieldedStale = true;
      }
    }
    try {
      yield await _repository.getMarketAssets(
        vsCurrency: vsCurrency,
        page: page,
        perPage: perPage,
        order: order,
        ids: ids,
      );
    } on Object {
      if (!yieldedStale) rethrow;
    }
  }
}
