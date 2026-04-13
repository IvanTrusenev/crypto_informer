import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/bloc/search/search_state.dart';

sealed class MarketEvent {
  const MarketEvent();
}

class MarketLoadRequested extends MarketEvent {
  const MarketLoadRequested();
}

class MarketRefreshRequested extends MarketEvent {
  const MarketRefreshRequested();
}

class MarketLoadMoreRequested extends MarketEvent {
  const MarketLoadMoreRequested();
}

class MarketSortChanged extends MarketEvent {
  const MarketSortChanged({
    required this.column,
    required this.ascending,
  });

  final MarketSortColumnEnum? column;
  final bool ascending;
}

class MarketSortSegmentTapped extends MarketEvent {
  const MarketSortSegmentTapped(this.column);

  final MarketSortColumnEnum column;
}

class MarketSearchStateChanged extends MarketEvent {
  const MarketSearchStateChanged(this.searchState);

  final SearchState searchState;
}
