/// Колонка серверной сортировки на экране «Рынок».
enum MarketSortColumn {
  id,
  volume,
  marketCap;

  /// API-значение `order` для CoinGecko `/coins/markets`.
  String toApiOrder({required bool ascending}) => switch (this) {
        MarketSortColumn.id => ascending ? 'id_asc' : 'id_desc',
        MarketSortColumn.volume =>
          ascending ? 'volume_asc' : 'volume_desc',
        MarketSortColumn.marketCap =>
          ascending ? 'market_cap_asc' : 'market_cap_desc',
      };
}

/// Начальное направление при первом выборе сегмента.
bool marketSortDefaultAscending(MarketSortColumn column) {
  return switch (column) {
    MarketSortColumn.id => true,
    MarketSortColumn.volume => false,
    MarketSortColumn.marketCap => false,
  };
}
