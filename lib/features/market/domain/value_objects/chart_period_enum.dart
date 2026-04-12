/// Период агрегирования для CoinGecko `market_chart` (`days` query).
enum ChartPeriodEnum {
  /// 1 день
  day1('1'),

  /// 7 дней
  days7('7'),

  /// 30 дней
  days30('30'),

  /// 90 дней
  days90('90'),

  /// 365 дней
  days365('365'),

  /// Вся доступная история
  max('max')
  ;

  const ChartPeriodEnum(this.apiDays);

  /// Значение параметра `days` в API.
  final String apiDays;
}
