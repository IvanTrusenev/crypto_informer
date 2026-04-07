import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/repositories/crypto_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int _kPageSize = 50;

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
  });

  final List<CryptoAsset> assets;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String searchQuery;
  final bool isSearching;

  MarketLoaded copyWith({
    List<CryptoAsset>? assets,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? searchQuery,
    bool? isSearching,
  }) =>
      MarketLoaded(
        assets ?? this.assets,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        searchQuery: searchQuery ?? this.searchQuery,
        isSearching: isSearching ?? this.isSearching,
      );
}

class MarketError extends MarketState {
  const MarketError(this.error);
  final Object error;
}

class MarketCubit extends Cubit<MarketState> {
  MarketCubit(this._repository) : super(const MarketInitial());

  final CryptoRepository _repository;

  List<CryptoAsset> _browseCache = const [];
  int _browsePage = 1;
  bool _browseHasMore = true;

  List<String> _searchIds = const [];

  Future<void> loadAssets() async {
    emit(const MarketLoading());
    try {
      final assets = await _repository.getMarketAssets(perPage: _kPageSize);
      _browseCache = assets;
      _browsePage = 1;
      _browseHasMore = assets.length >= _kPageSize;
      if (!isClosed) {
        emit(MarketLoaded(assets, hasMore: _browseHasMore));
      }
    } on Object catch (e) {
      if (!isClosed) emit(MarketError(e));
    }
  }

  Future<void> refresh() async {
    try {
      final current = state;
      final query =
          current is MarketLoaded ? current.searchQuery : '';

      if (query.isNotEmpty) {
        _searchIds = await _repository.searchCoinIds(query);
        final chunk = _searchIds.take(_kPageSize).toList();
        final assets = chunk.isEmpty
            ? <CryptoAsset>[]
            : await _repository.getMarketAssets(
                ids: chunk,
                perPage: _kPageSize,
              );
        if (!isClosed) {
          emit(MarketLoaded(
            assets,
            searchQuery: query,
            hasMore: _searchIds.length > _kPageSize,
          ));
        }
      } else {
        final assets = await _repository.getMarketAssets(perPage: _kPageSize);
        _browseCache = assets;
        _browsePage = 1;
        _browseHasMore = assets.length >= _kPageSize;
        if (!isClosed) {
          emit(MarketLoaded(assets, hasMore: _browseHasMore));
        }
      }
    } on Object catch (e) {
      if (!isClosed) emit(MarketError(e));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! MarketLoaded ||
        current.isLoadingMore ||
        !current.hasMore) {
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
    final newAssets = await _repository.getMarketAssets(
      page: nextPage,
      perPage: _kPageSize,
    );
    if (!isClosed) {
      final all = [...current.assets, ...newAssets];
      _browseCache = all;
      _browsePage = nextPage;
      _browseHasMore = newAssets.length >= _kPageSize;
      emit(MarketLoaded(
        all,
        page: nextPage,
        hasMore: _browseHasMore,
      ));
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

    final newAssets = await _repository.getMarketAssets(
      ids: remaining,
      perPage: _kPageSize,
    );
    if (!isClosed) {
      final all = [...current.assets, ...newAssets];
      emit(MarketLoaded(
        all,
        page: current.page + 1,
        searchQuery: current.searchQuery,
        hasMore: all.length < _searchIds.length,
      ));
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
      emit(MarketLoaded(const [], searchQuery: q, isSearching: true));
    }

    try {
      _searchIds = await _repository.searchCoinIds(q);
      if (isClosed) return;
      final s = state;
      if (s is! MarketLoaded || s.searchQuery != q) return;

      if (_searchIds.isEmpty) {
        emit(MarketLoaded(const [], searchQuery: q, hasMore: false));
        return;
      }

      final chunk = _searchIds.take(_kPageSize).toList();
      final assets = await _repository.getMarketAssets(
        ids: chunk,
        perPage: _kPageSize,
      );
      if (!isClosed) {
        final s2 = state;
        if (s2 is MarketLoaded && s2.searchQuery == q) {
          emit(MarketLoaded(
            assets,
            searchQuery: q,
            hasMore: _searchIds.length > chunk.length,
          ));
        }
      }
    } on Object {
      if (!isClosed) {
        final s = state;
        if (s is MarketLoaded && s.searchQuery == q) {
          emit(MarketLoaded(const [], searchQuery: q, hasMore: false));
        }
      }
    }
  }

  void clearSearch() {
    _searchIds = const [];
    if (!isClosed) {
      emit(MarketLoaded(
        _browseCache,
        page: _browsePage,
        hasMore: _browseHasMore,
      ));
    }
  }
}
