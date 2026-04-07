import 'dart:async';

import 'package:crypto_informer/core/di/service_locator.dart';
import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:crypto_informer/features/alerts/presentation/widgets/set_price_alert_dialog.dart';
import 'package:crypto_informer/features/market/domain/chart_period.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_detail_cubit.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_price_chart_cubit.dart';
import 'package:crypto_informer/features/market/presentation/widgets/coin_price_chart_section.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/features/watchlist/presentation/widgets/animated_watchlist_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CoinDetailPage extends StatefulWidget {
  const CoinDetailPage({required this.coinId, super.key});

  final String coinId;

  @override
  State<CoinDetailPage> createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  ChartPeriod _chartPeriod = ChartPeriod.days7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priceFormat = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = CoinDetailCubit(sl());
            unawaited(cubit.loadDetail(widget.coinId));
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) {
            final cubit = CoinPriceChartCubit(sl());
            unawaited(
              cubit.loadChart(widget.coinId, period: _chartPeriod),
            );
            return cubit;
          },
        ),
      ],
      child: BlocBuilder<WatchlistCubit, WatchlistState>(
        builder: (context, wlState) {
          final inList = switch (wlState) {
            WatchlistLoaded(:final ids) => ids.contains(widget.coinId),
            _ => false,
          };

          return Scaffold(
            appBar: AppBar(
              title: BlocBuilder<CoinDetailCubit, CoinDetailState>(
                builder: (context, state) => switch (state) {
                  CoinDetailLoaded(:final detail) => Text(detail.name),
                  _ => Text(l10n.coinTitleFallback),
                },
              ),
              actions: [
                BlocBuilder<PriceAlertCubit, PriceAlertState>(
                  builder: (context, alertState) {
                    final hasAlert =
                        alertState.alertFor(widget.coinId) != null;
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
                                    coinId: widget.coinId,
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
                  onPressed: () => context
                      .read<WatchlistCubit>()
                      .toggle(widget.coinId),
                ),
              ],
            ),
            body: BlocBuilder<CoinDetailCubit, CoinDetailState>(
              builder: (context, state) => switch (state) {
                CoinDetailInitial() || CoinDetailLoading() =>
                  const Center(child: CircularProgressIndicator()),
                CoinDetailLoaded(:final detail) => ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (detail.imageUrl != null)
                        Center(
                          child: Hero(
                            tag: 'coin_avatar_${detail.id}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                detail.imageUrl!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        detail.symbol,
                        textAlign: TextAlign.center,
                        style: context.theme.textTheme.titleLarge,
                      ),
                      if (detail.currentPriceUsd != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          priceFormat.format(detail.currentPriceUsd),
                          textAlign: TextAlign.center,
                          style: context.theme.textTheme.headlineSmall,
                        ),
                      ],
                      if (detail.priceChangePercent24h != null) ...[
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            final change = detail.priceChangePercent24h!;
                            final finance = context.financeColors;
                            final changeColor = change >= 0
                                ? finance.pricePositive
                                : finance.priceNegative;
                            final label = l10n.coinChange24h(
                              '${change >= 0 ? '+' : ''}'
                              '${change.toStringAsFixed(2)}',
                            );
                            return Text(
                              label,
                              textAlign: TextAlign.center,
                              style: context.theme.textTheme.labelLarge
                                  ?.copyWith(
                                color: changeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      CoinPriceChartSection(
                        coinId: widget.coinId,
                        period: _chartPeriod,
                        onPeriodChanged: (p) {
                          setState(() => _chartPeriod = p);
                          unawaited(
                            context.read<CoinPriceChartCubit>().loadChart(
                                  widget.coinId,
                                  period: p,
                                ),
                          );
                        },
                      ),
                      if (detail.description != null &&
                          detail.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.coinSectionDescription,
                          style: context.theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detail.description!,
                          style: context.theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                CoinDetailError(:final error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        localizedErrorMessage(l10n, error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              },
            ),
          );
        },
      ),
    );
  }
}
