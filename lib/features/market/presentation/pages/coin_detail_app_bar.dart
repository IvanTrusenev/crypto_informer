import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:crypto_informer/features/alerts/presentation/widgets/set_price_alert_dialog.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_detail/export.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/features/watchlist/presentation/widgets/animated_watchlist_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// App bar экрана деталей монеты: заголовок, алерт, вотчлист.
class CoinDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CoinDetailAppBar({required this.coinId, super.key});

  final String coinId;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, wlState) {
        final inList = switch (wlState) {
          WatchlistLoaded(:final ids) => ids.contains(coinId),
          _ => false,
        };

        return AppBar(
          title: BlocBuilder<CoinDetailCubit, CoinDetailState>(
            builder: (context, state) => switch (state) {
              CoinDetailLoaded(:final detail) => Text(detail.name),
              _ => Text(l10n.coinTitleFallback),
            },
          ),
          actions: [
            BlocBuilder<PriceAlertCubit, PriceAlertState>(
              builder: (context, alertState) {
                final hasAlert = alertState.alertFor(coinId) != null;
                return BlocBuilder<CoinDetailCubit, CoinDetailState>(
                  builder: (context, detailState) {
                    final detail = switch (detailState) {
                      CoinDetailLoaded(:final detail) => detail,
                      _ => null,
                    };
                    return IconButton(
                      icon: Icon(
                        hasAlert
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                      ),
                      tooltip: hasAlert
                          ? l10n.tooltipAlertActive
                          : l10n.tooltipAlertSet,
                      onPressed: detail?.currentPriceUsd == null
                          ? null
                          : () => showSetPriceAlertDialog(
                              context,
                              coinId: coinId,
                              coinName: detail!.name,
                              currentPrice: detail.currentPriceUsd!,
                            ),
                    );
                  },
                );
              },
            ),
            AnimatedWatchlistIconButton(
              isInWatchlist: inList,
              tooltip: inList
                  ? l10n.tooltipWatchlistRemove
                  : l10n.tooltipWatchlistAdd,
              onPressed: () =>
                  context.read<WatchlistCubit>().toggle(coinId),
            ),
          ],
        );
      },
    );
  }
}
