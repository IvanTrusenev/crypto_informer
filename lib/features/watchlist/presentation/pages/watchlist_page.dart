import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/providers/crypto_providers.dart';
import 'package:crypto_informer/features/market/presentation/widgets/crypto_asset_list_tile.dart';
import 'package:crypto_informer/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (missing > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        l10n.watchlistPartialMissing(missing),
                        style: context.theme.textTheme.bodySmall,
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(marketAssetsProvider.future),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns =
                              marketListCrossAxisCount(constraints.maxWidth);
                          if (columns == 1) {
                            return ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: items.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final asset = items[index];
                                return CryptoAssetListTile(
                                  asset: asset,
                                  priceText: priceFormat.format(
                                    asset.currentPriceUsd,
                                  ),
                                  inWatchlist: true,
                                  l10n: l10n,
                                  onTap: () => context.push(
                                    '/market/coin/${asset.id}',
                                  ),
                                  onToggleStar: () => ref
                                      .read(watchlistProvider.notifier)
                                      .toggle(asset.id),
                                );
                              },
                            );
                          }
                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisExtent: 96,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final asset = items[index];
                              return Card(
                                clipBehavior: Clip.antiAlias,
                                margin: EdgeInsets.zero,
                                child: CryptoAssetListTile(
                                  asset: asset,
                                  priceText: priceFormat.format(
                                    asset.currentPriceUsd,
                                  ),
                                  inWatchlist: true,
                                  l10n: l10n,
                                  onTap: () => context.push(
                                    '/market/coin/${asset.id}',
                                  ),
                                  onToggleStar: () => ref
                                      .read(watchlistProvider.notifier)
                                      .toggle(asset.id),
                                  dense: true,
                                ),
                              );
                            },
                          );
                        },
                      ),
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
