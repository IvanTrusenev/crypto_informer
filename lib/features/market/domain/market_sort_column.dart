/// Колонка пользовательской сортировки на экране «Рынок».
enum MarketSortColumn {
  name,
  price,
  marketCap,
}

/// Начальное направление при первом выборе сегмента.
bool marketSortDefaultAscending(MarketSortColumn column) {
  return switch (column) {
    MarketSortColumn.name => true,
    MarketSortColumn.price => false,
    MarketSortColumn.marketCap => false,
  };
}
