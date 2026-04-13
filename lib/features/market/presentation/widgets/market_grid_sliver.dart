import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_coin_tile.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarketGridSliver extends StatelessWidget {
  const MarketGridSliver({
    required this.items,
    required this.watchlistIds,
    required this.columns,
    required this.priceFormat,
    required this.l10n,
    super.key,
  });

  final List<CoinEntity> items;
  final List<String> watchlistIds;
  final int columns;
  final NumberFormat priceFormat;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final asset = items[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: MarketCoinTile(
                asset: asset,
                inWatchlist: watchlistIds.contains(asset.id),
                priceFormat: priceFormat,
                l10n: l10n,
                dense: true,
              ),
            );
          },
          childCount: items.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisExtent: 96,
          crossAxisSpacing: 10,
          mainAxisSpacing: 8,
        ),
      ),
    );
  }
}
