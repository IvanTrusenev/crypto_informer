import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';

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
    this.sortColumn,
    this.sortAscending = true,
  });

  final List<CryptoAssetEntity> assets;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final bool isSearching;
  final MarketSortColumnEnum? sortColumn;
  final bool sortAscending;

  MarketLoaded copyWith({
    List<CryptoAssetEntity>? assets,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    bool? isSearching,
    MarketSortColumnEnum? Function()? sortColumnFn,
    bool? sortAscending,
  }) => MarketLoaded(
    assets ?? this.assets,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    searchQuery: searchQuery ?? this.searchQuery,
    isSearching: isSearching ?? this.isSearching,
    sortColumn: sortColumnFn != null ? sortColumnFn() : sortColumn,
    sortAscending: sortAscending ?? this.sortAscending,
  );
}

class MarketError extends MarketState {
  const MarketError(this.error);
  final Object error;
}
