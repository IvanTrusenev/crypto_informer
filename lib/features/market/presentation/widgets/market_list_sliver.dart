import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/presentation/widgets/market_coin_tile.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MarketListSliver extends StatelessWidget {
  const MarketListSliver({
    required this.items,
    required this.watchlistIds,
    required this.priceFormat,
    required this.l10n,
    super.key,
  });

  final List<CoinEntity> items;
  final List<String> watchlistIds;
  final NumberFormat priceFormat;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final asset = items[index];
          return MarketCoinTile(
            asset: asset,
            inWatchlist: watchlistIds.contains(asset.id),
            priceFormat: priceFormat,
            l10n: l10n,
          );
        },
      ),
    );
  }
}
