import 'dart:async';

import 'package:crypto_informer/core/utils/debouncer.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/market_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kPageSize = MarketListQueryDefaults.perPage;
const String _kDefaultOrder = MarketListQueryDefaults.order;

class MarketCubit extends Cubit<MarketState> {
  MarketCubit(
    this._getMarketAssetsUseCase,
    this._repository, {
    Duration searchDebounce = const Duration(milliseconds: 500),
  }) : _searchDebouncer = Debouncer(duration: searchDebounce),
       super(const MarketInitial());

  final GetMarketAssetsUseCase _getMarketAssetsUseCase;
  final CryptoRepository _repository;
  final Debouncer _searchDebouncer;

  List<CoinEntity> _browseCache = const [];
  int _browsePage = 1;
  bool _browseHasMore = true;

  List<String> _searchIds = const [];

  MarketSortColumnEnum? _sortColumn;
  bool _sortAscending = true;

  @override
  Future<void> close() {
    _searchDebouncer.dispose();
    return super.close();
  }

  void clearSearch() {
    _searchDebouncer.cancel();
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

  Future<void> loadAssets() async {
    emit(const MarketLoading());
    try {
      await _listenBrowseFirstPageStream(emitCachedFirst: true);
    } on Object catch (e) {
      _emitMarketErrorIfNotLoaded(e);
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

  Future<void> refresh() async {
    try {
      final current = state;
      final query = current is MarketLoaded ? current.searchQuery : '';

      if (query.isNotEmpty) {
        _searchIds = await _repository.searchCoinIds(query);
        await _listenSearchFirstChunkStream(query);
      } else {
        await _listenBrowseFirstPageStream(emitCachedFirst: false);
      }
    } on Object catch (e) {
      _emitMarketErrorIfNotLoaded(e);
    }
  }

  /// Отложенный поиск при вводе в поле (debounce настраивается в конструкторе).
  void scheduleSearch(String query) {
    _searchDebouncer.run(() {
      if (isClosed) return;
      unawaited(search(query));
    });
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

      await _listenSearchFirstChunkStream(
        q,
        emitOnlyIf: () {
          final s2 = state;
          return s2 is MarketLoaded && s2.searchQuery == q;
        },
      );
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

  /// Выбор сегмента сортировки: та же колонка — смена направления,
  /// иначе — [MarketSortColumnEnum.defaultAscending].
  Future<void> tapSortSegment(MarketSortColumnEnum column) async {
    final current = state;
    final prevColumn = current is MarketLoaded ? current.sortColumn : null;
    final prevAsc = current is! MarketLoaded || current.sortAscending;

    final bool ascending;
    if (prevColumn == column) {
      ascending = !prevAsc;
    } else {
      ascending = column.defaultAscending;
    }
    await setSort(column, ascending: ascending);
  }

  String get _apiOrder =>
      _sortColumn?.toApiOrder(ascending: _sortAscending) ?? _kDefaultOrder;

  void _applyBrowseFirstPage(List<CoinEntity> assets) {
    _browseCache = assets;
    _browsePage = 1;
    _browseHasMore = assets.length >= _kPageSize;
  }

  void _emitMarketErrorIfNotLoaded(Object e) {
    if (state is MarketLoaded) return;
    if (!isClosed) emit(MarketError(e));
  }

  /// Первая страница списка рынка (без поиска).
  Future<void> _listenBrowseFirstPageStream({
    required bool emitCachedFirst,
  }) async {
    await for (final assets in _getMarketAssetsUseCase(
      order: _apiOrder,
      emitCachedFirst: emitCachedFirst,
    )) {
      if (isClosed) return;
      _applyBrowseFirstPage(assets);
      emit(_marketLoadedBrowse(assets));
    }
  }

  /// Первая страница по уже заполненному [_searchIds].
  Future<void> _listenSearchFirstChunkStream(
    String query, {
    bool Function()? emitOnlyIf,
  }) async {
    final chunk = _searchIds.take(_kPageSize).toList();
    if (chunk.isEmpty) {
      if (!isClosed) {
        emit(
          MarketLoaded(
            const [],
            searchQuery: query,
            hasMore: false,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
          ),
        );
      }
      return;
    }
    final hasMore = _searchIds.length > chunk.length;
    await for (final assets in _getMarketAssetsUseCase(
      ids: chunk,
      order: _apiOrder,
    )) {
      if (!isClosed) {
        if (emitOnlyIf != null && !emitOnlyIf()) return;
        emit(
          MarketLoaded(
            assets,
            searchQuery: query,
            hasMore: hasMore,
            sortColumn: _sortColumn,
            sortAscending: _sortAscending,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreBrowse(MarketLoaded current) async {
    final nextPage = current.page + 1;
    final newAssets = await _getMarketAssetsUseCase(
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

    final newAssets = await _getMarketAssetsUseCase(
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

  MarketLoaded _marketLoadedBrowse(List<CoinEntity> assets) =>
      MarketLoaded(
        assets,
        hasMore: _browseHasMore,
        sortColumn: _sortColumn,
        sortAscending: _sortAscending,
      );
}
