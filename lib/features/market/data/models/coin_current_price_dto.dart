/// Карта цен в фиатных валютах (CoinGecko `market_data.current_price`).
class CoinCurrentPriceDto {
  const CoinCurrentPriceDto({required this.byCurrency});

  /// Код валюты (`usd`, `eur`, …) → цена.
  final Map<String, double> byCurrency;

  double? get usd => byCurrency['usd'];

  static CoinCurrentPriceDto? fromJson(Object? json) {
    if (json == null || json is! Map) return null;
    final map = <String, double>{};
    for (final e in json.entries) {
      final v = e.value;
      if (v is num) {
        map[e.key.toString()] = v.toDouble();
      }
    }
    return CoinCurrentPriceDto(byCurrency: map);
  }
}
