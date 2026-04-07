/// Сетевая модель точки графика цены (CoinGecko `/coins/{id}/market_chart`).
///
/// API возвращает массив пар `[timestamp_ms, price]`, а не JSON-объект,
/// поэтому `json_serializable` не применяется.
class PriceChartPointDto {
  const PriceChartPointDto({
    required this.timestampMs,
    required this.priceUsd,
  });

  final int timestampMs;
  final double priceUsd;
}
