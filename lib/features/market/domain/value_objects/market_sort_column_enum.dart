/// Колонка серверной сортировки на экране «Рынок».
enum MarketSortColumnEnum {
  id(defaultAscending: true),
  volume(defaultAscending: false),
  marketCap(defaultAscending: false);

  const MarketSortColumnEnum({required this.defaultAscending});

  /// Направление сортировки при первом выборе этого сегмента.
  final bool defaultAscending;

  /// API-значение `order` для CoinGecko `/coins/markets`.
  String toApiOrder({required bool ascending}) => switch (this) {
    MarketSortColumnEnum.id => ascending ? 'id_asc' : 'id_desc',
    MarketSortColumnEnum.volume => ascending ? 'volume_asc' : 'volume_desc',
    MarketSortColumnEnum.marketCap =>
      ascending ? 'market_cap_asc' : 'market_cap_desc',
  };
}
