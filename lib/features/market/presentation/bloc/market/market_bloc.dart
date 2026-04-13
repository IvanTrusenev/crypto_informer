import 'dart:async';

import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_market_assets_usecase.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/market_browse_snapshot.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/market_event.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/market_state.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/export.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kPageSize = MarketListQueryDefaults.perPage;
const String _kDefaultOrder = MarketListQueryDefaults.order;

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc(
    this._getMarketAssetsUseCase,
    this._searchBloc,
  ) : _searchState = _searchBloc.state,
      super(const MarketInitial()) {
    on<MarketLoadRequested>(_onLoadRequested);
    on<MarketRefreshRequested>(_onRefreshRequested);
    on<MarketLoadMoreRequested>(_onLoadMoreRequested);
    on<MarketSortChanged>(_onSortChanged);
    on<MarketSortSegmentTapped>(_onSortSegmentTapped);
    on<MarketSearchStateChanged>(_onSearchStateChanged);

    _searchSubscription = _searchBloc.stream.listen(
      (searchState) => add(MarketSearchStateChanged(searchState)),
    );
  }

  final GetMarketAssetsUseCase _getMarketAssetsUseCase;
  final SearchBloc _searchBloc;

  final MarketBrowseSnapshot _browse = MarketBrowseSnapshot();
  late final StreamSubscription<SearchState> _searchSubscription;

  SearchState _searchState;
  List<CoinEntity> _searchAssets = const [];
  MarketSortColumnEnum? _sortColumn;
  bool _sortAscending = true;
  int _requestToken = 0;

  @override
  Future<void> close() async {
    await _searchSubscription.cancel();
    return super.close();
  }

  Future<void> _onLoadRequested(
    MarketLoadRequested event,
    Emitter<MarketState> emit,
  ) async {
    emit(const MarketLoading());
    final requestToken = ++_requestToken;
    try {
      await _listenBrowseFirstPageStream(
        emit,
        requestToken: requestToken,
        emitCachedFirst: true,
      );
    } on Object catch (error) {
      _emitMarketErrorIfNotLoaded(error, emit);
    }
  }

  Future<void> _onRefreshRequested(
    MarketRefreshRequested event,
    Emitter<MarketState> emit,
  ) async {
    final requestToken = ++_requestToken;
    try {
      await _refreshCurrentMode(
        emit,
        requestToken: requestToken,
      );
    } on Object catch (error) {
      _emitMarketErrorIfNotLoaded(error, emit);
    }
  }

  Future<void> _onLoadMoreRequested(
    MarketLoadMoreRequested event,
    Emitter<MarketState> emit,
  ) async {
    final current = state;
    if (current is! MarketLoaded || current.isLoadingMore || !current.hasMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));

    try {
      if (current.searchQuery.isNotEmpty) {
        _loadMoreSearch(current, emit);
      } else {
        final requestToken = ++_requestToken;
        await _loadMoreBrowse(
          current,
          emit,
          requestToken: requestToken,
        );
      }
    } on Object {
      if (!isClosed) emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onSortChanged(
    MarketSortChanged event,
    Emitter<MarketState> emit,
  ) async {
    _sortColumn = event.column;
    _sortAscending = event.ascending;
    _browse.reset();
    add(const MarketRefreshRequested());
  }

  void _onSortSegmentTapped(
    MarketSortSegmentTapped event,
    Emitter<MarketState> emit,
  ) {
    final current = state;
    final prevColumn = current is MarketLoaded ? current.sortColumn : null;
    final prevAsc = current is! MarketLoaded || current.sortAscending;

    final bool ascending;
    if (prevColumn == event.column) {
      ascending = !prevAsc;
    } else {
      ascending = event.column.defaultAscending;
    }

    add(
      MarketSortChanged(
        column: event.column,
        ascending: ascending,
      ),
    );
  }

  Future<void> _onSearchStateChanged(
    MarketSearchStateChanged event,
    Emitter<MarketState> emit,
  ) async {
    _searchState = event.searchState;
    final requestToken = ++_requestToken;

    switch (event.searchState.status) {
      case SearchStatusEnum.idle:
        _searchAssets = const [];
        if (state is MarketLoaded || _browse.cache.isNotEmpty) {
          emit(
            _buildLoaded(
              _browse.cache,
              page: _browse.page,
              hasMore: _browse.hasMore,
            ),
          );
        }
        return;
      case SearchStatusEnum.searching:
        final current = state;
        if (current is MarketLoaded) {
          emit(
            current.copyWith(
              searchQuery: event.searchState.query,
              isSearching: true,
              searchNeedsRefinement: false,
              hasMore: false,
              isLoadingMore: false,
            ),
          );
        } else {
          emit(
            _buildLoaded(
              const [],
              searchQuery: event.searchState.query,
              isSearching: true,
              hasMore: false,
            ),
          );
        }
        return;
      case SearchStatusEnum.empty:
        _searchAssets = const [];
        emit(
          _buildLoaded(
            const [],
            searchQuery: event.searchState.query,
            hasMore: false,
          ),
        );
        return;
      case SearchStatusEnum.tooBroad:
        _searchAssets = const [];
        emit(
          _buildLoaded(
            const [],
            searchQuery: event.searchState.query,
            hasMore: false,
            searchNeedsRefinement: true,
          ),
        );
        return;
      case SearchStatusEnum.ready:
        emit(
          _buildLoaded(
            const [],
            searchQuery: event.searchState.query,
            isSearching: true,
            hasMore: false,
          ),
        );
        await _listenSearchAssetsStream(
          event.searchState.query,
          event.searchState.ids,
          emit,
          requestToken: requestToken,
        );
    }
  }

  Future<void> _refreshCurrentMode(
    Emitter<MarketState> emit, {
    required int requestToken,
  }) async {
    if (_searchState.hasActiveQuery) {
      switch (_searchState.status) {
        case SearchStatusEnum.idle:
          await _listenBrowseFirstPageStream(
            emit,
            requestToken: requestToken,
            emitCachedFirst: false,
          );
        case SearchStatusEnum.searching:
          final current = state;
          if (current is MarketLoaded) {
            emit(
              current.copyWith(
                searchQuery: _searchState.query,
                isSearching: true,
                searchNeedsRefinement: false,
                hasMore: false,
                isLoadingMore: false,
              ),
            );
          } else {
            emit(
              _buildLoaded(
                const [],
                searchQuery: _searchState.query,
                isSearching: true,
                hasMore: false,
              ),
            );
          }
        case SearchStatusEnum.empty:
          _searchAssets = const [];
          emit(
            _buildLoaded(
              const [],
              searchQuery: _searchState.query,
              hasMore: false,
            ),
          );
        case SearchStatusEnum.tooBroad:
          _searchAssets = const [];
          emit(
            _buildLoaded(
              const [],
              searchQuery: _searchState.query,
              hasMore: false,
              searchNeedsRefinement: true,
            ),
          );
        case SearchStatusEnum.ready:
          emit(
            _buildLoaded(
              const [],
              searchQuery: _searchState.query,
              isSearching: true,
              hasMore: false,
            ),
          );
          await _listenSearchAssetsStream(
            _searchState.query,
            _searchState.ids,
            emit,
            requestToken: requestToken,
          );
      }
      return;
    }

    await _listenBrowseFirstPageStream(
      emit,
      requestToken: requestToken,
      emitCachedFirst: false,
    );
  }

  String _apiOrder() =>
      _sortColumn?.toApiOrder(ascending: _sortAscending) ?? _kDefaultOrder;

  MarketLoaded _buildLoaded(
    List<CoinEntity> assets, {
    int page = 1,
    bool hasMore = true,
    bool isLoadingMore = false,
    String searchQuery = '',
    bool isSearching = false,
    bool searchNeedsRefinement = false,
  }) {
    return MarketLoaded(
      assets,
      page: page,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      searchQuery: searchQuery,
      isSearching: isSearching,
      searchNeedsRefinement: searchNeedsRefinement,
      sortColumn: _sortColumn,
      sortAscending: _sortAscending,
    );
  }

  void _emitMarketErrorIfNotLoaded(
    Object error,
    Emitter<MarketState> emit,
  ) {
    if (state is MarketLoaded) return;
    if (!isClosed) emit(MarketError(error));
  }

  Future<void> _listenBrowseFirstPageStream(
    Emitter<MarketState> emit, {
    required int requestToken,
    required bool emitCachedFirst,
  }) async {
    await for (final assets in _getMarketAssetsUseCase(
      order: _apiOrder(),
      emitCachedFirst: emitCachedFirst,
    )) {
      if (!_isCurrentRequest(requestToken) ||
          isClosed ||
          _searchState.hasActiveQuery) {
        return;
      }
      _browse.applyFirstPage(assets, _kPageSize);
      emit(
        _buildLoaded(
          assets,
          hasMore: _browse.hasMore,
        ),
      );
    }
  }

  Future<void> _listenSearchAssetsStream(
    String query,
    List<String> ids,
    Emitter<MarketState> emit, {
    required int requestToken,
  }) async {
    await for (final assets in _getMarketAssetsUseCase(
      ids: ids,
      order: _apiOrder(),
      emitCachedFirst: false,
    )) {
      if (!_isCurrentRequest(requestToken) || isClosed) return;
      if (_searchState.query != query ||
          _searchState.status != SearchStatusEnum.ready) {
        return;
      }
      _searchAssets = assets;
      final visible = assets.take(_kPageSize).toList();
      emit(
        _buildLoaded(
          visible,
          searchQuery: query,
          hasMore: assets.length > _kPageSize,
        ),
      );
    }
  }

  void _loadMoreSearch(
    MarketLoaded current,
    Emitter<MarketState> emit,
  ) {
    final nextPage = current.page + 1;
    final visibleCount = nextPage * _kPageSize;
    final visible = _searchAssets.take(visibleCount).toList();
    if (!isClosed) {
      emit(
        _buildLoaded(
          visible,
          page: nextPage,
          searchQuery: current.searchQuery,
          hasMore: visible.length < _searchAssets.length,
        ),
      );
    }
  }

  Future<void> _loadMoreBrowse(
    MarketLoaded current,
    Emitter<MarketState> emit, {
    required int requestToken,
  }) async {
    final nextPage = current.page + 1;
    final newAssets = await _getMarketAssetsUseCase(
      page: nextPage,
      order: _apiOrder(),
    ).last;
    if (!_isCurrentRequest(requestToken) ||
        isClosed ||
        _searchState.hasActiveQuery) {
      return;
    }
    final all = [...current.assets, ...newAssets];
    _browse.applyLoadMore(
      mergedAssets: all,
      nextPage: nextPage,
      newChunkLength: newAssets.length,
      pageSize: _kPageSize,
    );
    emit(
      _buildLoaded(
        all,
        page: nextPage,
        hasMore: _browse.hasMore,
      ),
    );
  }

  bool _isCurrentRequest(int requestToken) => requestToken == _requestToken;
}
