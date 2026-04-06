import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MarketPage extends ConsumerWidget {
  const MarketPage({super.key});

  static final _price = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(marketAssetsProvider);
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Рынок')),
      body: async.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Нет данных'));
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
                  priceText: _price.format(asset.currentPriceUsd),
                  inWatchlist: inList,
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
                  e.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(marketAssetsProvider),
                  child: const Text('Повторить'),
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
    required this.onTap,
    required this.onToggleStar,
  });

  final CryptoAsset asset;
  final String priceText;
  final bool inWatchlist;
  final VoidCallback onTap;
  final VoidCallback onToggleStar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = asset.priceChangePercent24h;
    final changeColor = change >= 0
        ? Colors.green.shade700
        : Colors.red.shade700;

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
        '${asset.symbol} · '
        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
        style: TextStyle(color: changeColor),
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
            tooltip: inWatchlist ? 'Убрать из избранного' : 'В избранное',
          ),
        ],
      ),
    );
  }
}
