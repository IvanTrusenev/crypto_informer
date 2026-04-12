import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';

/// Пагинация режима «весь рынок» (кэш для возврата из поиска и догрузки).
class MarketBrowseSnapshot {
  List<CoinEntity> cache = const [];
  int page = 1;
  bool hasMore = true;

  void reset() {
    cache = const [];
    page = 1;
    hasMore = true;
  }

  void applyFirstPage(List<CoinEntity> assets, int pageSize) {
    cache = assets;
    page = 1;
    hasMore = assets.length >= pageSize;
  }

  void applyLoadMore({
    required List<CoinEntity> mergedAssets,
    required int nextPage,
    required int newChunkLength,
    required int pageSize,
  }) {
    cache = mergedAssets;
    page = nextPage;
    hasMore = newChunkLength >= pageSize;
  }
}
