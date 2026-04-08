import 'dart:async';

import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market_cubit.dart';
import 'package:crypto_informer/features/market/presentation/widgets/crypto_asset_list_tile.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Высота одной строки «поиск + сортировка» на широком экране.
const double _kMarketWideFilterBarHeight = 42;

/// Высота фильтр-бара (включая padding 8+8) для узкого / широкого экрана.
const double _kFilterBarNarrowHeight = 92;
const double _kFilterBarWideHeight = _kMarketWideFilterBarHeight + 16;

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleSearchUpdate(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      unawaited(context.read<MarketCubit>().search(text));
    });
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      unawaited(context.read<MarketCubit>().loadMore());
    }
  }

  void _onSortSegmentTapped(MarketSortColumnEnum column) {
    final cubit = context.read<MarketCubit>();
    final current = cubit.state;
    final prevColumn = current is MarketLoaded ? current.sortColumn : null;
    final prevAsc = current is! MarketLoaded || current.sortAscending;

    final bool ascending;
    if (prevColumn == column) {
      ascending = !prevAsc;
    } else {
      ascending = column.defaultAscending;
    }
    unawaited(cubit.setSort(column, ascending: ascending));
  }

  void _onSortReset() {
    unawaited(context.read<MarketCubit>().setSort(null, ascending: true));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketTitle)),
      body: BlocBuilder<MarketCubit, MarketState>(
        builder: (context, marketState) {
          return switch (marketState) {
            MarketInitial() ||
            MarketLoading() => const Center(child: CircularProgressIndicator()),
            MarketLoaded(
              :final assets,
              :final isLoadingMore,
              :final hasMore,
              :final searchQuery,
              :final isSearching,
              :final sortColumn,
              :final sortAscending,
            ) =>
              _buildLoaded(
                context,
                assets,
                priceFormat,
                l10n,
                isLoadingMore: isLoadingMore,
                hasMore: hasMore,
                searchQuery: searchQuery,
                isSearching: isSearching,
                sortColumn: sortColumn,
                sortAscending: sortAscending,
              ),
            MarketError(:final error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizedErrorMessage(l10n, error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.read<MarketCubit>().loadAssets(),
                      child: Text(l10n.retryAction),
                    ),
                  ],
                ),
              ),
            ),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    List<CryptoAssetEntity> items,
    NumberFormat priceFormat,
    AppLocalizations l10n, {
    required bool isLoadingMore,
    required bool hasMore,
    required String searchQuery,
    required bool isSearching,
    required MarketSortColumnEnum? sortColumn,
    required bool sortAscending,
  }) {
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

            final searchField = _buildSearchField(l10n);
            final sortSection = _MarketSortSection(
              title: l10n.marketSortSectionTitle,
              fillHeight: wide,
              child: _buildSortControls(
                context,
                l10n,
                sortColumn: sortColumn,
                sortAscending: sortAscending,
              ),
            );

            Widget filterBar;
            if (wide) {
              filterBar = SizedBox(
                height: _kMarketWideFilterBarHeight,
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
                ? _kFilterBarWideHeight
                : _kFilterBarNarrowHeight;

            return RefreshIndicator(
              onRefresh: () => context.read<MarketCubit>().refresh(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPersistentHeader(
                    floating: true,
                    delegate: _FilterBarDelegate(
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
                      child: Center(child: CircularProgressIndicator()),
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
                          return CryptoAssetListTile(
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
                              child: CryptoAssetListTile(
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
                        child: Center(child: CircularProgressIndicator()),
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

  Widget _buildSearchField(AppLocalizations l10n) {
    return ListenableBuilder(
      listenable: _searchController,
      builder: (context, _) {
        return TextField(
          controller: _searchController,
          onChanged: _scheduleSearchUpdate,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            hintText: l10n.marketSearchHint,
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchDebounce?.cancel();
                      _searchController.clear();
                      context.read<MarketCubit>().clearSearch();
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSortControls(
    BuildContext context,
    AppLocalizations l10n, {
    required MarketSortColumnEnum? sortColumn,
    required bool sortAscending,
  }) {
    final resetStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Row(
      children: [
        Expanded(
          child: _SegmentedMarketSortBar(
            selectedColumn: sortColumn,
            ascending: sortAscending,
            onSegmentTap: _onSortSegmentTapped,
            l10n: l10n,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          style: resetStyle,
          onPressed: _onSortReset,
          child: Text(
            l10n.marketSortReset,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

/// Скругление и обводка как у [InputDecoration] из темы.
OutlineInputBorder _outlineInputBorderFromTheme(
  ThemeData theme,
  ColorScheme scheme,
) {
  final inputTheme = theme.inputDecorationTheme;
  final shape = inputTheme.enabledBorder ?? inputTheme.border;
  if (shape is OutlineInputBorder) return shape;
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: scheme.outline),
  );
}

class _MarketSortSection extends StatelessWidget {
  const _MarketSortSection({
    required this.title,
    required this.fillHeight,
    required this.child,
  });

  final String title;
  final bool fillHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final inputTheme = theme.inputDecorationTheme;
    final outlineBorder = _outlineInputBorderFromTheme(theme, scheme);

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 88),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: child),
        ],
      ),
    );

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: inputTheme.fillColor ?? scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: outlineBorder.borderRadius,
          side: outlineBorder.borderSide,
        ),
      ),
      child: fillHeight ? SizedBox.expand(child: Center(child: inner)) : inner,
    );
  }
}

class _SegmentedMarketSortBar extends StatelessWidget {
  const _SegmentedMarketSortBar({
    required this.selectedColumn,
    required this.ascending,
    required this.onSegmentTap,
    required this.l10n,
  });

  final MarketSortColumnEnum? selectedColumn;
  final bool ascending;
  final ValueChanged<MarketSortColumnEnum> onSegmentTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _SortSegment(
                label: l10n.marketSortId,
                selected: selectedColumn == MarketSortColumnEnum.id,
                ascending: ascending,
                onTap: () => onSegmentTap(MarketSortColumnEnum.id),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _SortSegment(
                label: l10n.marketSortVolume,
                selected: selectedColumn == MarketSortColumnEnum.volume,
                ascending: ascending,
                onTap: () => onSegmentTap(MarketSortColumnEnum.volume),
              ),
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: scheme.outline,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _SortSegment(
                label: l10n.marketSortMarketCap,
                selected: selectedColumn == MarketSortColumnEnum.marketCap,
                ascending: ascending,
                onTap: () => onSegmentTap(MarketSortColumnEnum.marketCap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSegment extends StatelessWidget {
  const _SortSegment({
    required this.label,
    required this.selected,
    required this.ascending,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool ascending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? scheme.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      height: 1,
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurface,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 1),
                  AnimatedRotation(
                    turns: ascending ? 0 : 0.5,
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOutCubic,
                    child: Icon(
                      Icons.arrow_upward,
                      size: 13,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  _FilterBarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 2 : 0,
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _FilterBarDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}
