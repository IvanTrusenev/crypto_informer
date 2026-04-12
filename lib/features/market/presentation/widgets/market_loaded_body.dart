import 'package:crypto_informer/core/widgets/centered_circular_progress.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:crypto_informer/features/market/presentation/widgets/coin_list_tile.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_filter_bar_delegate.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_page_constants.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_search_field.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_segmented_sort_bar.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_sort_section.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MarketLoadedBody extends StatelessWidget {
  const MarketLoadedBody({
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

            final searchField = MarketSearchField(
              controller: searchController,
              l10n: l10n,
              onChanged: onSearchChanged,
              onClear: onClearSearch,
            );
            final sortSection = MarketSortSection(
              title: l10n.marketSortSectionTitle,
              fillHeight: wide,
              child: MarketSortControlsBar(
                l10n: l10n,
                sortColumn: sortColumn,
                sortAscending: sortAscending,
              ),
            );

            final Widget filterBar;
            if (wide) {
              filterBar = SizedBox(
                height: kMarketWideFilterBarHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: searchField,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 2, child: sortSection),
                  ],
                ),
              );
            } else {
              filterBar = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchField,
                  const SizedBox(height: 8),
                  sortSection,
                ],
              );
            }

            final filterHeight = wide
                ? kMarketFilterBarWideHeight
                : kMarketFilterBarNarrowHeight;

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
                        child: filterBar,
                      ),
                      height: filterHeight,
                    ),
                  ),
                  if (isSearching)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: CenteredCircularProgress(),
                    )
                  else if (searchNeedsRefinement)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(l10n.marketSearchNeedsRefinement),
                      ),
                    )
                  else if (items.isEmpty && searchQuery.isNotEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(l10n.marketSearchNoResults)),
                    )
                  else if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(l10n.marketEmpty)),
                    )
                  else if (columns == 1)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      sliver: SliverList.separated(
                        itemCount: display.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final asset = display[index];
                          final inList = watchlistIds.contains(asset.id);
                          return CoinListTile(
                            asset: asset,
                            priceText: priceFormat.format(
                              asset.currentPriceUsd,
                            ),
                            inWatchlist: inList,
                            l10n: l10n,
                            onTap: () =>
                                context.push('/market/coin/${asset.id}'),
                            onToggleStar: () =>
                                context.read<WatchlistCubit>().toggle(asset.id),
                          );
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(8),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final asset = display[index];
                            final inList = watchlistIds.contains(asset.id);
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              margin: EdgeInsets.zero,
                              child: CoinListTile(
                                asset: asset,
                                priceText: priceFormat.format(
                                  asset.currentPriceUsd,
                                ),
                                inWatchlist: inList,
                                l10n: l10n,
                                onTap: () =>
                                    context.push('/market/coin/${asset.id}'),
                                onToggleStar: () => context
                                    .read<WatchlistCubit>()
                                    .toggle(asset.id),
                                dense: true,
                              ),
                            );
                          },
                          childCount: display.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 96,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 8,
                        ),
                      ),
                    ),
                  if (isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CenteredCircularProgress(),
                      ),
                    )
                  else if (hasMore && display.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
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
