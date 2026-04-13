import 'dart:math' as math;

import 'package:crypto_informer/core/formatters/currency_formatter.dart';
import 'package:crypto_informer/features/market/domain/entities/price_chart_point_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class CoinPriceChartDataBuilder {
  const CoinPriceChartDataBuilder._();

  static LineChartData build({
    required List<PriceChartPointEntity> points,
    required ColorScheme colorScheme,
    required TextStyle? axisTextStyle,
    required NumberFormat priceFormat,
    required String localeName,
    required String currencySymbol,
    double? alertThreshold,
  }) {
    final lineColor = colorScheme.primary;
    final bounds = _buildChartBounds(
      points: points,
      alertThreshold: alertThreshold,
    );
    final maxX = (points.length - 1).toDouble();
    final bottomInterval = points.length > 4
        ? (maxX / 3).clamp(1.0, maxX)
        : 1.0;
    final yInterval = (bounds.maxY - bounds.minY) / 4;
    final dateFmt = DateFormat.Md(localeName);
    final tooltipDateFmt = DateFormat.yMMMd(localeName);
    final spots = [
      for (var index = 0; index < points.length; index++)
        FlSpot(index.toDouble(), points[index].priceUsd),
    ];

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: bounds.minY,
      maxY: bounds.maxY,
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
                labelResolver: (_) => CurrencyFormatter.formatCompact(
                  alertThreshold,
                  localeName: localeName,
                  currencySymbol: currencySymbol,
                ),
              ),
            ),
        ],
      ),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (value) => FlLine(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              if (value < bounds.minY || value > bounds.maxY) {
                return const SizedBox.shrink();
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  CurrencyFormatter.formatCompact(
                    value,
                    localeName: localeName,
                    currencySymbol: currencySymbol,
                  ),
                  style: axisTextStyle,
                ),
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
              final index = value.round().clamp(0, points.length - 1);
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  dateFmt.format(points[index].timestamp),
                  style: axisTextStyle,
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          maxContentWidth: 200,
          getTooltipColor: (_) => colorScheme.inverseSurface,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.round().clamp(0, points.length - 1);
              final point = points[index];
              final dateStr = tooltipDateFmt.format(point.timestamp);
              final priceStr = priceFormat.format(point.priceUsd);
              return LineTooltipItem(
                '$dateStr\n$priceStr',
                TextStyle(
                  color: colorScheme.onInverseSurface,
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

  static _ChartBounds _buildChartBounds({
    required List<PriceChartPointEntity> points,
    required double? alertThreshold,
  }) {
    final ys = points.map((point) => point.priceUsd).toList();
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
    return _ChartBounds(
      minY: minY - pad,
      maxY: maxY + pad,
    );
  }
}

class _ChartBounds {
  const _ChartBounds({
    required this.minY,
    required this.maxY,
  });

  final double minY;
  final double maxY;
}
