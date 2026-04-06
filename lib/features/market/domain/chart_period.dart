/// Период агрегирования для CoinGecko `market_chart` (`days` query).
enum ChartPeriod {
  /// 1 день
  day1('1', '1D'),

  /// 7 дней
  days7('7', '7D'),

  /// 30 дней
  days30('30', '30D'),

  /// 90 дней
  days90('90', '90D'),

  /// 365 дней
  days365('365', '1Y'),

  /// Вся доступная история
  max('max', 'MAX')
  ;

  const ChartPeriod(this.apiDays, this.shortLabel);

  /// Значение параметра `days` в API.
  final String apiDays;

  /// Короткая подпись на кнопке периода.
  final String shortLabel;
}
