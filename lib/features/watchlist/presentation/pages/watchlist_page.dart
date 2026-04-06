import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  static final _price = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final marketAsync = ref.watch(marketAssetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: watchlistAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Добавьте монеты звёздочкой на экране «Рынок».',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return marketAsync.when(
            data: (all) {
              final byId = {for (final a in all) a.id: a};
              final items = <CryptoAsset>[];
              for (final id in ids) {
                final a = byId[id];
                if (a != null) items.add(a);
              }
              final missing = ids.length - items.length;

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (missing > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        'Часть избранного не в топ-списке рынка ($missing). '
                        'Откройте монету с «Рынка» или обновите список.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ...items.map(
                    (asset) => ListTile(
                      leading: CircleAvatar(
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
                      subtitle: Text(asset.symbol),
                      trailing: Text(_price.format(asset.currentPriceUsd)),
                      onTap: () => context.push('/market/coin/${asset.id}'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
