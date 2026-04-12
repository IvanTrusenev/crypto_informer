import 'dart:async';

import 'package:crypto_informer/core/utils/debouncer.dart';
import 'package:crypto_informer/features/market/domain/constants/market_list_query_defaults.dart';
import 'package:crypto_informer/features/market/domain/usecases/search_coin_ids_usecase.dart';
import 'package:crypto_informer/features/market/presentation/cubit/search/search_event.dart';
import 'package:crypto_informer/features/market/presentation/cubit/search/search_state.dart';
import 'package:crypto_informer/features/market/presentation/cubit/search/search_status_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(
    this._searchCoinIdsUseCase, {
    Duration searchDebounce = const Duration(milliseconds: 500),
  }) : _searchDebouncer = Debouncer(duration: searchDebounce),
       super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
    on<SearchTriggered>(_onTriggered);
  }

  final SearchCoinIdsUseCase _searchCoinIdsUseCase;
  final Debouncer _searchDebouncer;

  @override
  Future<void> close() {
    _searchDebouncer.dispose();
    return super.close();
  }

  void _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) {
    final query = event.query.trim();
    if (query.isEmpty) {
      add(const SearchCleared());
      return;
    }

    emit(
      SearchState(
        query: query,
        status: SearchStatusEnum.searching,
      ),
    );

    _searchDebouncer.run(() {
      if (isClosed) return;
      add(SearchTriggered(query));
    });
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _searchDebouncer.cancel();
    emit(const SearchState());
  }

  Future<void> _onTriggered(
    SearchTriggered event,
    Emitter<SearchState> emit,
  ) async {
    if (state.query != event.query ||
        state.status != SearchStatusEnum.searching) {
      return;
    }

    try {
      final ids = await _searchCoinIdsUseCase(event.query);
      if (isClosed || state.query != event.query) return;

      if (ids.isEmpty) {
        emit(
          SearchState(
            query: event.query,
            status: SearchStatusEnum.empty,
          ),
        );
        return;
      }

      if (ids.length > MarketListQueryDefaults.maxSearchResultsForMarketFetch) {
        emit(
          SearchState(
            query: event.query,
            status: SearchStatusEnum.tooBroad,
            ids: ids,
          ),
        );
        return;
      }

      emit(
        SearchState(
          query: event.query,
          status: SearchStatusEnum.ready,
          ids: ids,
        ),
      );
    } on Object {
      if (!isClosed && state.query == event.query) {
        emit(
          SearchState(
            query: event.query,
            status: SearchStatusEnum.empty,
          ),
        );
      }
    }
  }
}
