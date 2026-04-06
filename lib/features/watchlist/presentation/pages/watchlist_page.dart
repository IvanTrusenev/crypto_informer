import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final priceFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );
    final watchlistAsync = ref.watch(watchlistProvider);
    final marketAsync = ref.watch(marketAssetsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.watchlistTitle)),
      body: watchlistAsync.when(
        data: (ids) {
          if (ids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.watchlistEmptyBody,
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
                        l10n.watchlistPartialMissing(missing),
                        style: context.theme.textTheme.bodySmall,
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
                      trailing: Text(
                        priceFormat.format(asset.currentPriceUsd),
                      ),
                      onTap: () => context.push('/market/coin/${asset.id}'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(localizedErrorMessage(l10n, e)),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(localizedErrorMessage(l10n, e)),
        ),
      ),
    );
  }
}
