/// Точка временного ряда цены (USD) для графика.
class PriceChartPointEntity {
  const PriceChartPointEntity({
    required this.timestamp,
    required this.priceUsd,
  });

  final DateTime timestamp;
  final double priceUsd;
}
