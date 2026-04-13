import 'package:intl/intl.dart';

final class CurrencyFormatter {
  const CurrencyFormatter._();

  static String formatCompact(
    double value, {
    required String localeName,
    required String currencySymbol,
    int compactDecimalDigits = 1,
    int standardDecimalDigits = 2,
    int smallValueDecimalDigits = 4,
  }) {
    final abs = value.abs();
    if (abs >= 1e3) {
      return NumberFormat.compactCurrency(
        locale: localeName,
        symbol: currencySymbol,
        decimalDigits: compactDecimalDigits,
      ).format(value);
    }

    final decimalDigits = abs >= 1
        ? standardDecimalDigits
        : smallValueDecimalDigits;
    return NumberFormat.currency(
      locale: localeName,
      symbol: currencySymbol,
      decimalDigits: decimalDigits,
    ).format(value);
  }

  static String formatCompactMetric(
    double value, {
    required String localeName,
    required String currencySymbol,
  }) {
    final abs = value.abs();
    return formatCompact(
      value,
      localeName: localeName,
      currencySymbol: currencySymbol,
      compactDecimalDigits: abs >= 1e6 ? 2 : 1,
      standardDecimalDigits: 0,
      smallValueDecimalDigits: 0,
    );
  }
}
