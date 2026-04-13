import 'package:crypto_informer/core/widgets/centered_circular_progress.dart';
import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_grid_sliver.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_list_sliver.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Sliver composition for search/browse states and market items.
class MarketResultsSliver extends StatelessWidget {
  const MarketResultsSliver({
    required this.items,
    required this.watchlistIds,
    required this.columns,
    required this.priceFormat,
    required this.l10n,
    required this.isLoadingMore,
    required this.hasMore,
    required this.searchQuery,
    required this.isSearching,
    required this.searchNeedsRefinement,
    super.key,
  });

  final List<CoinEntity> items;
  final List<String> watchlistIds;
  final int columns;
  final NumberFormat priceFormat;
  final AppLocalizations l10n;
  final bool isLoadingMore;
  final bool hasMore;
  final String searchQuery;
  final bool isSearching;
  final bool searchNeedsRefinement;

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: CenteredCircularProgress(),
      );
    }

    if (searchNeedsRefinement) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(l10n.marketSearchNeedsRefinement),
        ),
      );
    }

    if (items.isEmpty && searchQuery.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(l10n.marketSearchNoResults)),
      );
    }

    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(l10n.marketEmpty)),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        if (columns == 1)
          MarketListSliver(
            items: items,
            watchlistIds: watchlistIds,
            priceFormat: priceFormat,
            l10n: l10n,
          )
        else
          MarketGridSliver(
            items: items,
            watchlistIds: watchlistIds,
            columns: columns,
            priceFormat: priceFormat,
            l10n: l10n,
          ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CenteredCircularProgress(),
            ),
          )
        else if (hasMore)
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
      ],
    );
  }
}
