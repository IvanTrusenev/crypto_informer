import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/layout/market_layout_constants.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_search_field.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_sort_bar.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_sort_section.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Responsive header with search and sort controls.
class MarketFilterBarContent extends StatelessWidget {
  const MarketFilterBarContent({
    required this.wide,
    required this.searchController,
    required this.l10n,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSearchChanged,
    required this.onClearSearch,
    super.key,
  });

  final bool wide;
  final TextEditingController searchController;
  final AppLocalizations l10n;
  final MarketSortColumnEnum? sortColumn;
  final bool sortAscending;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final searchField = MarketSearchField(
      controller: searchController,
      l10n: l10n,
      onChanged: onSearchChanged,
      onClear: onClearSearch,
    );
    final sortSection = MarketSortSection(
      title: l10n.marketSortSectionTitle,
      fillHeight: wide,
      child: MarketSortBar(
        l10n: l10n,
        sortColumn: sortColumn,
        sortAscending: sortAscending,
      ),
    );

    return wide
        ? _WideMarketFilterBar(
            searchField: searchField,
            sortSection: sortSection,
          )
        : _NarrowMarketFilterBar(
            searchField: searchField,
            sortSection: sortSection,
          );
  }
}

class _WideMarketFilterBar extends StatelessWidget {
  const _WideMarketFilterBar({
    required this.searchField,
    required this.sortSection,
  });

  final Widget searchField;
  final Widget sortSection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MarketLayoutConstants.wideFilterBarHeight,
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
}

class _NarrowMarketFilterBar extends StatelessWidget {
  const _NarrowMarketFilterBar({
    required this.searchField,
    required this.sortSection,
  });

  final Widget searchField;
  final Widget sortSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchField,
        const SizedBox(height: 8),
        sortSection,
      ],
    );
  }
}
