import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/market/domain/entities/crypto_asset.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market_cubit.dart';
import 'package:crypto_informer/features/market/presentation/widgets/crypto_asset_list_tile.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.watchlistTitle)),
      body: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, wlState) {
          final ids = switch (wlState) {
            WatchlistLoaded(:final ids) => ids,
            _ => <String>[],
          };
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
          return BlocBuilder<MarketCubit, MarketState>(
            builder: (context, marketState) => switch (marketState) {
              MarketInitial() || MarketLoading() =>
                const Center(child: CircularProgressIndicator()),
              MarketLoaded(:final assets) => _buildList(
                  context,
                  ids,
                  assets,
                  priceFormat,
                  l10n,
                ),
              MarketError(:final error) => Center(
                  child: Text(localizedErrorMessage(l10n, error)),
                ),
            },
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<String> ids,
    List<CryptoAsset> allAssets,
    NumberFormat priceFormat,
    AppLocalizations l10n,
  ) {
    final byId = {for (final a in allAssets) a.id: a};
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
            onRefresh: () => context.read<MarketCubit>().refresh(),
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
                        onToggleStar: () => context
                            .read<WatchlistCubit>()
                            .toggle(asset.id),
                      );
                    },
                  );
                }
                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        onToggleStar: () => context
                            .read<WatchlistCubit>()
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
  }
}
