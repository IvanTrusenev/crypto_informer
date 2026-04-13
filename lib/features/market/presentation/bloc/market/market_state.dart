import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';

/// Sentinel для [MarketLoaded.copyWith]: не менять [MarketLoaded.sortColumn].
const Object _keepSortColumn = Object();

sealed class MarketState {
  const MarketState();
}

class MarketInitial extends MarketState {
  const MarketInitial();
}

class MarketLoading extends MarketState {
  const MarketLoading();
}

class MarketLoaded extends MarketState {
  const MarketLoaded(
    this.assets, {
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.searchQuery = '',
    this.isSearching = false,
    this.searchNeedsRefinement = false,
    this.sortColumn,
    this.sortAscending = true,
  });

  final List<CoinEntity> assets;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final bool isSearching;
  final bool searchNeedsRefinement;
  final MarketSortColumnEnum? sortColumn;
  final bool sortAscending;

  MarketLoaded copyWith({
    List<CoinEntity>? assets,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    bool? isSearching,
    bool? searchNeedsRefinement,
    Object? sortColumn = _keepSortColumn,
    bool? sortAscending,
  }) => MarketLoaded(
    assets ?? this.assets,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    searchQuery: searchQuery ?? this.searchQuery,
    isSearching: isSearching ?? this.isSearching,
    searchNeedsRefinement:
        searchNeedsRefinement ?? this.searchNeedsRefinement,
    sortColumn: identical(sortColumn, _keepSortColumn)
        ? this.sortColumn
        : sortColumn as MarketSortColumnEnum?,
    sortAscending: sortAscending ?? this.sortAscending,
  );
}

class MarketError extends MarketState {
  const MarketError(this.error);
  final Object error;
}
