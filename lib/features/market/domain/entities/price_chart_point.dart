/// Точка временного ряда цены (USD) для графика.
class PriceChartPoint {
  const PriceChartPoint({
    required this.timestamp,
    required this.priceUsd,
  });

  final DateTime timestamp;
  final double priceUsd;
}
