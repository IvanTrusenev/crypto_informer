import 'dart:math' as math;

import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:crypto_informer/features/market/presentation/cubit/coin_price_chart_cubit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// Блок графика цены и выбора периода на экране монеты.
class CoinPriceChartSection extends StatelessWidget {
  const CoinPriceChartSection({
    required this.coinId,
    required this.period,
    required this.onPeriodChanged,
    super.key,
  });

  final String coinId;
  final ChartPeriodEnum period;
  final ValueChanged<ChartPeriodEnum> onPeriodChanged;

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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in ChartPeriodEnum.values)
              FilterChip(
                label: Text(p.shortLabel),
                selected: p == period,
                onSelected: (_) => onPeriodChanged(p),
              ),
          ],
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
                  child: Center(child: CircularProgressIndicator()),
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
                            _buildLineChartData(
                              context,
                              points,
                              NumberFormat.currency(
                                locale: Localizations.localeOf(
                                  context,
                                ).toString(),
                                symbol: r'$',
                                decimalDigits: 2,
                              ),
                              Localizations.localeOf(context).toString(),
                              alertThreshold: alertThreshold,
                            ),
                          ),
                        ),
                CoinPriceChartError(:final error) => Padding(
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

  LineChartData _buildLineChartData(
    BuildContext context,
    List<PriceChartPointEntity> points,
    NumberFormat priceFormat,
    String localeName, {
    double? alertThreshold,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final lineColor = scheme.primary;
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
      fontSize: 10,
    );

    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].priceUsd),
    ];

    final ys = points.map((e) => e.priceUsd).toList();
    var minY = ys.reduce(math.min);
    var maxY = ys.reduce(math.max);
    if (alertThreshold != null) {
      minY = math.min(minY, alertThreshold);
      maxY = math.max(maxY, alertThreshold);
    }
    if (minY == maxY) {
      minY = minY * 0.995;
      maxY = maxY * 1.005;
    }
    final pad = (maxY - minY) * 0.06;
    minY -= pad;
    maxY += pad;

    final maxX = (points.length - 1).toDouble();
    final bottomInterval = points.length > 4
        ? (maxX / 3).clamp(1.0, maxX)
        : 1.0;

    final dateFmt = DateFormat.Md(localeName);
    final tooltipDateFmt = DateFormat.yMMMd(localeName);

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (alertThreshold != null)
            HorizontalLine(
              y: alertThreshold,
              color: Colors.red,
              strokeWidth: 1.5,
              dashArray: [8, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                labelResolver: (_) => _compactUsd(alertThreshold),
              ),
            ),
        ],
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: scheme.outlineVariant.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        border: Border.all(color: scheme.outlineVariant),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) {
              if (value < minY || value > maxY) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(_compactUsd(value), style: textStyle),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: bottomInterval,
            getTitlesWidget: (value, meta) {
              final i = value.round().clamp(0, points.length - 1);
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  dateFmt.format(points[i].timestamp),
                  style: textStyle,
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          maxContentWidth: 200,
          getTooltipColor: (_) => scheme.inverseSurface,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final i = spot.x.round().clamp(0, points.length - 1);
              final p = points[i];
              final dateStr = tooltipDateFmt.format(p.timestamp);
              final priceStr = priceFormat.format(p.priceUsd);
              return LineTooltipItem(
                '$dateStr\n$priceStr',
                TextStyle(
                  color: scheme.onInverseSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: lineColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withValues(alpha: 0.35),
                lineColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  static String _compactUsd(double v) {
    final abs = v.abs();
    if (abs >= 1e9) return '\$${(v / 1e9).toStringAsFixed(1)}B';
    if (abs >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (abs >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}k';
    if (abs >= 1) return '\$${v.toStringAsFixed(2)}';
    return '\$${v.toStringAsFixed(4)}';
  }
}
