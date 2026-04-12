import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/widgets/centered_circular_progress.dart';
import 'package:crypto_informer/core/widgets/centered_error_with_retry.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_loaded_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Содержимое [Scaffold.body] экрана рынка.
class MarketPageBody extends StatelessWidget {
  const MarketPageBody({
    required this.scrollController,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onRetry,
    super.key,
  });

  final ScrollController scrollController;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = context.usdCurrencyFormat;

    return BlocBuilder<MarketBloc, MarketState>(
      builder: (context, marketState) {
        return switch (marketState) {
          MarketInitial() ||
          MarketLoading() => const CenteredCircularProgress(),
          MarketLoaded(
            :final assets,
            :final isLoadingMore,
            :final hasMore,
            :final searchQuery,
            :final isSearching,
            :final searchNeedsRefinement,
            :final sortColumn,
            :final sortAscending,
          ) =>
            MarketLoadedBody(
              scrollController: scrollController,
              searchController: searchController,
              items: assets,
              priceFormat: priceFormat,
              l10n: l10n,
              isLoadingMore: isLoadingMore,
              hasMore: hasMore,
              searchQuery: searchQuery,
              isSearching: isSearching,
              searchNeedsRefinement: searchNeedsRefinement,
              sortColumn: sortColumn,
              sortAscending: sortAscending,
              onSearchChanged: onSearchChanged,
              onClearSearch: onClearSearch,
            ),
          MarketError(:final error) => CenteredErrorWithRetry(
            message: localizedErrorMessage(l10n, error),
            retryLabel: l10n.retryAction,
            onRetry: onRetry,
          ),
        };
      },
    );
  }
}
