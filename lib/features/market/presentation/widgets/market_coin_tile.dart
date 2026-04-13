import 'package:crypto_informer/features/market/domain/entities/coin_entity.dart';
import 'package:crypto_informer/features/market/presentation/widgets/coin_list_tile.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MarketCoinTile extends StatelessWidget {
  const MarketCoinTile({
    required this.asset,
    required this.inWatchlist,
    required this.priceFormat,
    required this.l10n,
    this.dense = false,
    super.key,
  });

  final CoinEntity asset;
  final bool inWatchlist;
  final NumberFormat priceFormat;
  final AppLocalizations l10n;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return CoinListTile(
      asset: asset,
      priceText: priceFormat.format(asset.currentPriceUsd),
      inWatchlist: inWatchlist,
      l10n: l10n,
      onTap: () => context.push('/market/coin/${asset.id}'),
      onToggleStar: () => context.read<WatchlistCubit>().toggle(asset.id),
      dense: dense,
    );
  }
}
