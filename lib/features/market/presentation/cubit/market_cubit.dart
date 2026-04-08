import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kPageSize = MarketListQueryDefaults.perPage;
const String _kDefaultOrder = MarketListQueryDefaults.order;

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

class MarketCubit extends Cubit<MarketState> {
  MarketCubit(this._getMarketAssets, this._repository)
    : super(const MarketInitial());

  final GetMarketAssets _getMarketAssets;
  final CryptoRepository _repository;

  List<CryptoAssetEntity> _browseCache = const [];
  int _browsePage = 1;
  bool _browseHasMore = true;

  List<String> _searchIds = const [];

  MarketSortColumnEnum? _sortColumn;
  bool _sortAscending = true;

  String get _apiOrder =>
      _sortColumn?.toApiOrder(ascending: _sortAscending) ?? _kDefaultOrder;

  Future<void> loadAssets() async {
    emit(const MarketLoading());
    try {
      await for (final assets in _getMarketAssets(order: _apiOrder)) {
        if (isClosed) return;
        _browseCache = assets;
        _browsePage = 1;
        _browseHasMore = assets.length >= _kPageSize;
        emit(
          MarketLoaded(
            assets,
            hasMore: _browseHasMore,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
          ),
        );
      }
    } on Object catch (e) {
      if (state is MarketLoaded) return;
      if (!isClosed) emit(MarketError(e));
    }
  }

  Future<void> refresh() async {
    try {
      final current = state;
      final query = current is MarketLoaded ? current.searchQuery : '';

      if (query.isNotEmpty) {
        _searchIds = await _repository.searchCoinIds(query);
        final chunk = _searchIds.take(_kPageSize).toList();
        if (chunk.isEmpty) {
          if (!isClosed) {
            emit(
              MarketLoaded(
                const [],
                searchQuery: query,
                hasMore: _searchIds.length > _kPageSize,
                sortColumn: _sortColumn,
                sortAscending: _sortAscending,
              ),
            );
          }
        } else {
          await for (final assets in _getMarketAssets(
            ids: chunk,
            order: _apiOrder,
          )) {
            if (!isClosed) {
              emit(
                MarketLoaded(
                  assets,
                  searchQuery: query,
                  hasMore: _searchIds.length > _kPageSize,
                  sortColumn: _sortColumn,
                  sortAscending: _sortAscending,
                ),
              );
            }
          }
        }
      } else {
        await for (final assets in _getMarketAssets(order: _apiOrder)) {
          if (isClosed) return;
          _browseCache = assets;
          _browsePage = 1;
          _browseHasMore = assets.length >= _kPageSize;
          emit(
            MarketLoaded(
              assets,
              hasMore: _browseHasMore,
              sortColumn: _sortColumn,
              sortAscending: _sortAscending,
            ),
          );
        }
      }
    } on Object catch (e) {
      if (!isClosed) {
        if (state is MarketLoaded) return;
        emit(MarketError(e));
      }
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! MarketLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    try {
      if (current.searchQuery.isNotEmpty) {
        await _loadMoreSearch(current);
      } else {
        await _loadMoreBrowse(current);
      }
    } on Object {
      if (!isClosed) emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _loadMoreBrowse(MarketLoaded current) async {
    final nextPage = current.page + 1;
    final newAssets = await _getMarketAssets(
      page: nextPage,
      order: _apiOrder,
    ).last;
    if (!isClosed) {
      final all = [...current.assets, ...newAssets];
      _browseCache = all;
      _browsePage = nextPage;
      _browseHasMore = newAssets.length >= _kPageSize;
      emit(
        MarketLoaded(
          all,
          page: nextPage,
          hasMore: _browseHasMore,
          sortColumn: _sortColumn,
          sortAscending: _sortAscending,
        ),
      );
    }
  }

  Future<void> _loadMoreSearch(MarketLoaded current) async {
    final loaded = current.assets.length;
    final remaining = _searchIds.skip(loaded).take(_kPageSize).toList();
    if (remaining.isEmpty) {
      if (!isClosed) {
        emit(current.copyWith(hasMore: false, isLoadingMore: false));
      }
      return;
    }

    final newAssets = await _getMarketAssets(
      ids: remaining,
      order: _apiOrder,
    ).last;
    if (!isClosed) {
      final all = [...current.assets, ...newAssets];
      emit(
        MarketLoaded(
          all,
          page: current.page + 1,
          searchQuery: current.searchQuery,
          hasMore: all.length < _searchIds.length,
          sortColumn: _sortColumn,
          sortAscending: _sortAscending,
        ),
      );
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      clearSearch();
      return;
    }

    final current = state;
    if (current is MarketLoaded) {
      emit(current.copyWith(searchQuery: q, isSearching: true));
    } else {
      emit(
        MarketLoaded(
          const [],
          searchQuery: q,
          isSearching: true,
          sortColumn: _sortColumn,
          sortAscending: _sortAscending,
        ),
      );
    }

    try {
      _searchIds = await _repository.searchCoinIds(q);
      if (isClosed) return;
      final s = state;
      if (s is! MarketLoaded || s.searchQuery != q) return;

      if (_searchIds.isEmpty) {
        emit(
          MarketLoaded(
            const [],
            searchQuery: q,
            hasMore: false,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
          ),
        );
        return;
      }

      final chunk = _searchIds.take(_kPageSize).toList();
      await for (final assets in _getMarketAssets(
        ids: chunk,
        order: _apiOrder,
      )) {
        if (!isClosed) {
          final s2 = state;
          if (s2 is MarketLoaded && s2.searchQuery == q) {
            emit(
              MarketLoaded(
                assets,
                searchQuery: q,
                hasMore: _searchIds.length > chunk.length,
                sortColumn: _sortColumn,
                sortAscending: _sortAscending,
              ),
            );
          }
        }
      }
    } on Object {
      if (!isClosed) {
        final s = state;
        if (s is MarketLoaded && s.searchQuery == q) {
          emit(
            MarketLoaded(
              const [],
              searchQuery: q,
              hasMore: false,
              sortColumn: _sortColumn,
              sortAscending: _sortAscending,
            ),
          );
        }
      }
    }
  }

  void clearSearch() {
    _searchIds = const [];
    if (!isClosed) {
      emit(
        MarketLoaded(
          _browseCache,
          page: _browsePage,
          hasMore: _browseHasMore,
          sortColumn: _sortColumn,
          sortAscending: _sortAscending,
        ),
      );
    }
  }

  Future<void> setSort(
    MarketSortColumnEnum? column, {
    required bool ascending,
  }) async {
    _sortColumn = column;
    _sortAscending = ascending;
    _browseCache = const [];
    _browsePage = 1;
    _browseHasMore = true;
    await refresh();
  }
}
