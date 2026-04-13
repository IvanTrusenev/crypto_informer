import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/features/market/presentation/layout/market_grid_layout.dart';
import 'package:crypto_informer/features/market/presentation/layout/market_layout_constants.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_filter_bar_content.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_filter_bar_delegate.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_results_sliver.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Контент списка рынка при успешной загрузке.
class MarketContent extends StatelessWidget {
  const MarketContent({
    required this.scrollController,
    required this.searchController,
    required this.items,
    required this.priceFormat,
    required this.l10n,
    required this.isLoadingMore,
    required this.hasMore,
    required this.searchQuery,
    required this.isSearching,
    required this.searchNeedsRefinement,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSearchChanged,
    required this.onClearSearch,
    super.key,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;
  final List<CoinEntity> items;
  final NumberFormat priceFormat;
  final AppLocalizations l10n;
  final bool isLoadingMore;
  final bool hasMore;
  final String searchQuery;
  final bool isSearching;
  final bool searchNeedsRefinement;
  final MarketSortColumnEnum? sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, wlState) {
        final watchlistIds = switch (wlState) {
          WatchlistLoaded(:final ids) => ids,
          _ => <String>[],
        };
        final display = items;

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 560;
            final columns = marketListCrossAxisCount(constraints.maxWidth);

            return RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                context.read<MarketBloc>().add(const MarketRefreshRequested());
              },
              child: CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    floating: true,
                    delegate: MarketFilterBarDelegate(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: MarketFilterBarContent(
                          wide: wide,
                          searchController: searchController,
                          l10n: l10n,
                          sortColumn: sortColumn,
                          sortAscending: sortAscending,
                          onSearchChanged: onSearchChanged,
                          onClearSearch: onClearSearch,
                        ),
                      ),
                      height: wide
                          ? MarketLayoutConstants.filterBarWideHeight
                          : MarketLayoutConstants.narrowFilterBarHeight,
                    ),
                  ),
                  MarketResultsSliver(
                    items: display,
                    watchlistIds: watchlistIds,
                    columns: columns,
                    priceFormat: priceFormat,
                    l10n: l10n,
                    isLoadingMore: isLoadingMore,
                    hasMore: hasMore,
                    searchQuery: searchQuery,
                    isSearching: isSearching,
                    searchNeedsRefinement: searchNeedsRefinement,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
