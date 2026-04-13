import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/widgets/centered_circular_progress.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_price_chart/export.dart';
import 'package:crypto_informer/features/market/presentation/extensions/chart_period_enum_l10n.dart';
import 'package:crypto_informer/features/market/presentation/helpers/coin_price_chart_data_builder.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Блок графика цены и выбора периода на экране монеты.
class CoinPriceChartSection extends StatelessWidget {
  const CoinPriceChartSection({
    required this.coinId,
    super.key,
  });

  final String coinId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.coinPriceChartTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.coinPriceChartHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<CoinPriceChartCubit, CoinPriceChartState>(
          buildWhen: (prev, next) => prev.period != next.period,
          builder: (context, state) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in ChartPeriodEnum.values)
                  FilterChip(
                    label: Text(p.localizedShortLabel(l10n)),
                    selected: p == state.period,
                    onSelected: (_) => context
                        .read<CoinPriceChartCubit>()
                        .loadChart(coinId, period: p),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        BlocBuilder<PriceAlertCubit, PriceAlertState>(
          builder: (context, alertState) {
            final alertThreshold = alertState.alertFor(coinId)?.thresholdPrice;

            return BlocBuilder<CoinPriceChartCubit, CoinPriceChartState>(
              builder: (context, state) => switch (state) {
                CoinPriceChartInitial() ||
                CoinPriceChartLoading() => const SizedBox(
                  height: 200,
                  child: CenteredCircularProgress(),
                ),
                CoinPriceChartLoaded(:final points) =>
                  points.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            l10n.coinChartNoData,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 240,
                          child: LineChart(
                            CoinPriceChartDataBuilder.build(
                              points: points,
                              colorScheme: theme.colorScheme,
                              axisTextStyle:
                                  theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                              priceFormat: context.usdCurrencyFormat,
                              currencySymbol:
                                  context.usdCurrencyFormat.currencySymbol,
                              localeName:
                                  Localizations.localeOf(context).toString(),
                              alertThreshold: alertThreshold,
                            ),
                          ),
                        ),
                CoinPriceChartError(:final error, :final period) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        localizedErrorMessage(l10n, error),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () => context
                            .read<CoinPriceChartCubit>()
                            .loadChart(coinId, period: period),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retryAction),
                      ),
                    ],
                  ),
                ),
              },
            );
          },
        ),
      ],
    );
  }
}
