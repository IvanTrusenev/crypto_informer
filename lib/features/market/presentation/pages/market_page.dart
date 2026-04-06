import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MarketPage extends ConsumerWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          if (items.isEmpty) {
            return Center(child: Text(l10n.marketEmpty));
          }
          final watchlistIds = watchlistAsync.valueOrNull ?? [];
          return RefreshIndicator(
            onRefresh: () => ref.refresh(marketAssetsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final asset = items[index];
                final inList = watchlistIds.contains(asset.id);
                return _MarketTile(
                  asset: asset,
                  priceText: priceFormat.format(asset.currentPriceUsd),
                  inWatchlist: inList,
                  l10n: l10n,
                  onTap: () => context.push('/market/coin/${asset.id}'),
                  onToggleStar: () => ref
                      .read(watchlistProvider.notifier)
                      .toggle(asset.id),
                );
              },
            ),
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

class _MarketTile extends StatelessWidget {
  const _MarketTile({
    required this.asset,
    required this.priceText,
    required this.inWatchlist,
    required this.l10n,
    required this.onTap,
    required this.onToggleStar,
  });

  final CryptoAsset asset;
  final String priceText;
  final bool inWatchlist;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onToggleStar;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final finance = context.financeColors;
    final change = asset.priceChangePercent24h;
    final changeColor =
        change >= 0 ? finance.pricePositive : finance.priceNegative;
    final changeStr =
        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage:
            asset.imageUrl != null ? NetworkImage(asset.imageUrl!) : null,
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
