import 'package:crypto_informer/features/market/domain/value_objects/market_sort_column_enum.dart';
import 'package:crypto_informer/features/market/presentation/bloc/market/export.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketSortBar extends StatelessWidget {
  const MarketSortBar({
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
    final scheme = Theme.of(context).colorScheme;
    final resetStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    final segments = <({String label, MarketSortColumnEnum column})>[
      (label: l10n.marketSortId, column: MarketSortColumnEnum.id),
      (label: l10n.marketSortVolume, column: MarketSortColumnEnum.volume),
      (label: l10n.marketSortMarketCap, column: MarketSortColumnEnum.marketCap),
    ];

    return Row(
      children: [
        Expanded(
          child: Material(
            color: scheme.surface,
            shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 22,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < segments.length; index++) ...[
                    if (index > 0)
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: scheme.outline,
                        indent: 4,
                        endIndent: 4,
                      ),
                    Expanded(
                      child: _MarketSortSegment(
                        label: segments[index].label,
                        selected: sortColumn == segments[index].column,
                        ascending: sortAscending,
                        onTap: () => context.read<MarketBloc>().add(
                          MarketSortSegmentTapped(segments[index].column),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          style: resetStyle,
          onPressed: () => context.read<MarketBloc>().add(
            const MarketSortChanged(
              column: null,
              ascending: true,
            ),
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

class _MarketSortSegment extends StatelessWidget {
  const _MarketSortSegment({
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
