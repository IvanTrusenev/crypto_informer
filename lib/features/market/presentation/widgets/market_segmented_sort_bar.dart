import 'dart:async';

import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketSortControlsBar extends StatelessWidget {
  const MarketSortControlsBar({
    required this.l10n,
    required this.sortColumn,
    required this.sortAscending,
    super.key,
  });

  final AppLocalizations l10n;
  final MarketSortColumnEnum? sortColumn;
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    final resetStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Row(
      children: [
        Expanded(
          child: SegmentedMarketSortBar(
            selectedColumn: sortColumn,
            ascending: sortAscending,
            l10n: l10n,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          style: resetStyle,
          onPressed: () => unawaited(
            context.read<MarketCubit>().setSort(null, ascending: true),
          ),
          child: Text(
            l10n.marketSortReset,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

class SegmentedMarketSortBar extends StatelessWidget {
  const SegmentedMarketSortBar({
    required this.selectedColumn,
    required this.ascending,
    required this.l10n,
    super.key,
  });

  final MarketSortColumnEnum? selectedColumn;
  final bool ascending;
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
              child: MarketSortSegment(
                label: l10n.marketSortId,
                selected: selectedColumn == MarketSortColumnEnum.id,
                ascending: ascending,
                onTap: () => unawaited(
                  context.read<MarketCubit>().tapSortSegment(
                    MarketSortColumnEnum.id,
                  ),
                ),
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
              child: MarketSortSegment(
                label: l10n.marketSortVolume,
                selected: selectedColumn == MarketSortColumnEnum.volume,
                ascending: ascending,
                onTap: () => unawaited(
                  context.read<MarketCubit>().tapSortSegment(
                    MarketSortColumnEnum.volume,
                  ),
                ),
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
              child: MarketSortSegment(
                label: l10n.marketSortMarketCap,
                selected: selectedColumn == MarketSortColumnEnum.marketCap,
                ascending: ascending,
                onTap: () => unawaited(
                  context.read<MarketCubit>().tapSortSegment(
                    MarketSortColumnEnum.marketCap,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MarketSortSegment extends StatelessWidget {
  const MarketSortSegment({
    required this.label,
    required this.selected,
    required this.ascending,
    required this.onTap,
    super.key,
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
