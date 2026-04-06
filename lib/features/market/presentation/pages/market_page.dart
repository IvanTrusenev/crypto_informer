import 'dart:async';

import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/domain/market_sort_column.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Число колонок списка монет по ширине области контента (десктоп / широкое окно).
int _marketListCrossAxisCount(double width) {
  if (width >= 1200) {
    return 4;
  }
  if (width >= 900) {
    return 3;
  }
  if (width >= 600) {
    return 2;
  }
  return 1;
}

/// Высота одной строки «поиск + сортировка» на широком экране (без IntrinsicHeight / LayoutBuilder).
const double _kMarketWideFilterBarHeight = 42;

int _compareMarketCapPair(CryptoAsset a, CryptoAsset b, bool ascending) {
  final ca = a.marketCapUsd;
  final cb = b.marketCapUsd;
  if (ca == null && cb == null) {
    return 0;
  }
  if (ca == null) {
    return 1;
  }
  if (cb == null) {
    return -1;
  }
  final c = ca.compareTo(cb);
  return ascending ? c : -c;
}

List<CryptoAsset> _filterAndSortMarket(
  List<CryptoAsset> source,
  String query,
  MarketSortColumn? sortColumn,
  bool sortAscending,
) {
  final q = query.trim().toLowerCase();
  final list = q.isEmpty
      ? List<CryptoAsset>.from(source)
      : source
            .where(
              (a) =>
                  a.name.toLowerCase().contains(q) ||
                  a.symbol.toLowerCase().contains(q),
            )
            .toList();

  if (sortColumn == null) {
    return list;
  }

  switch (sortColumn) {
    case MarketSortColumn.name:
      list.sort((a, b) {
        final c =
            a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return sortAscending ? c : -c;
      });
    case MarketSortColumn.price:
      list.sort((a, b) {
        final c = a.currentPriceUsd.compareTo(b.currentPriceUsd);
        return sortAscending ? c : -c;
      });
    case MarketSortColumn.marketCap:
      list.sort((a, b) => _compareMarketCapPair(a, b, sortAscending));
  }
  return list;
}

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  MarketSortColumn? _sortColumn;
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleSearchUpdate(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }
      setState(() => _searchQuery = text.trim());
    });
  }

  void _onSortSegmentTapped(MarketSortColumn column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = marketSortDefaultAscending(column);
      }
    });
  }

  void _onSortReset() {
    setState(() {
      _sortColumn = null;
      _sortAscending = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );
    final async = ref.watch(marketAssetsProvider);
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.marketTitle)),
      body: async.when(
        data: (items) {
          final watchlistIds = watchlistAsync.valueOrNull ?? [];
          final display = _filterAndSortMarket(
            items,
            _searchQuery,
            _sortColumn,
            _sortAscending,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 560;
                    final searchField = ListenableBuilder(
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
                                      setState(() => _searchQuery = '');
                                    },
                                  ),
                          ),
                        );
                      },
                    );

                    final resetStyle = TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );

                    final sortControls = Row(
                      children: [
                        Expanded(
                          child: _SegmentedMarketSortBar(
                            selectedColumn: _sortColumn,
                            ascending: _sortAscending,
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

                    final sortSection = _MarketSortSection(
                      title: l10n.marketSortSectionTitle,
                      fillHeight: wide,
                      child: sortControls,
                    );

                    if (wide) {
                      return SizedBox(
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
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        searchField,
                        const SizedBox(height: 8),
                        sortSection,
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: _MarketListBody(
                  items: items,
                  displayItems: display,
                  watchlistIds: watchlistIds,
                  priceFormat: priceFormat,
                  l10n: l10n,
                  onRefresh: () => ref.refresh(marketAssetsProvider.future),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizedErrorMessage(l10n, e),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(marketAssetsProvider),
                  child: Text(l10n.retryAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Скругление и обводка как у [InputDecoration] из темы (поле поиска на рынке).
OutlineInputBorder _outlineInputBorderFromTheme(
  ThemeData theme,
  ColorScheme scheme,
) {
  final inputTheme = theme.inputDecorationTheme;
  final shape = inputTheme.enabledBorder ?? inputTheme.border;
  if (shape is OutlineInputBorder) {
    return shape;
  }
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: scheme.outline),
  );
}

/// Рамка с подписью: одна строка по высоте с полем поиска (в широкой вёрстке).
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
      child: fillHeight
          ? SizedBox.expand(
              child: Center(child: inner),
            )
          : inner,
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

  final MarketSortColumn? selectedColumn;
  final bool ascending;
  final ValueChanged<MarketSortColumn> onSegmentTap;
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
          children: [
            Expanded(
              child: _SortSegment(
                label: l10n.marketSortName,
                selected: selectedColumn == MarketSortColumn.name,
                ascending: ascending,
                onTap: () => onSegmentTap(MarketSortColumn.name),
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
                label: l10n.marketSortPrice,
                selected: selectedColumn == MarketSortColumn.price,
                ascending: ascending,
                onTap: () => onSegmentTap(MarketSortColumn.price),
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
                selected: selectedColumn == MarketSortColumn.marketCap,
                ascending: ascending,
                onTap: () => onSegmentTap(MarketSortColumn.marketCap),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Row(
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
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 1),
                Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: scheme.onSecondaryContainer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketListBody extends ConsumerWidget {
  const _MarketListBody({
    required this.items,
    required this.displayItems,
    required this.watchlistIds,
    required this.priceFormat,
    required this.l10n,
    required this.onRefresh,
  });

  final List<CryptoAsset> items;
  final List<CryptoAsset> displayItems;
  final List<String> watchlistIds;
  final NumberFormat priceFormat;
  final AppLocalizations l10n;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(child: Text(l10n.marketEmpty));
    }
    if (displayItems.isEmpty) {
      return Center(child: Text(l10n.marketSearchNoResults));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _marketListCrossAxisCount(constraints.maxWidth);
        if (columns == 1) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final asset = displayItems[index];
                final inList = watchlistIds.contains(asset.id);
                return _MarketTile(
                  asset: asset,
                  priceText: priceFormat.format(asset.currentPriceUsd),
                  inWatchlist: inList,
                  l10n: l10n,
                  onTap: () => context.push('/market/coin/${asset.id}'),
                  onToggleStar: () =>
                      ref.read(watchlistProvider.notifier).toggle(asset.id),
                );
              },
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 96,
              crossAxisSpacing: 10,
              mainAxisSpacing: 8,
            ),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final asset = displayItems[index];
              final inList = watchlistIds.contains(asset.id);
              return Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                child: _MarketTile(
                  asset: asset,
                  priceText: priceFormat.format(asset.currentPriceUsd),
                  inWatchlist: inList,
                  l10n: l10n,
                  onTap: () => context.push('/market/coin/${asset.id}'),
                  onToggleStar: () =>
                      ref.read(watchlistProvider.notifier).toggle(asset.id),
                  dense: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MarketTile extends StatelessWidget {
  const _MarketTile({
    required this.asset,
    required this.priceText,
    required this.inWatchlist,
    required this.l10n,
    required this.onTap,
    required this.onToggleStar,
    this.dense = false,
  });

  final CryptoAsset asset;
  final String priceText;
  final bool inWatchlist;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onToggleStar;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finance = context.financeColors;
    final change = asset.priceChangePercent24h;
    final changeColor = change >= 0
        ? finance.pricePositive
        : finance.priceNegative;
    final changeStr = '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';

    return ListTile(
      dense: dense,
      visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: asset.imageUrl != null
            ? NetworkImage(asset.imageUrl!)
            : null,
        child: asset.imageUrl == null
            ? Text(
                asset.symbol.length >= 2
                    ? asset.symbol.substring(0, 2)
                    : asset.symbol,
              )
            : null,
      ),
      title: Text(asset.name),
      subtitle: Text(
        l10n.marketAssetSubtitle(asset.symbol, changeStr),
        style: theme.textTheme.bodySmall?.copyWith(color: changeColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(priceText, style: theme.textTheme.titleMedium),
          IconButton(
            icon: Icon(
              inWatchlist ? Icons.star : Icons.star_border,
              color: inWatchlist ? theme.colorScheme.primary : null,
            ),
            onPressed: onToggleStar,
            tooltip: inWatchlist
                ? l10n.tooltipWatchlistRemove
                : l10n.tooltipWatchlistAdd,
          ),
        ],
      ),
    );
  }
}
