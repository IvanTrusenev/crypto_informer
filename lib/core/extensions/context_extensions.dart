import 'package:crypto_informer/core/theme/finance_semantic_colors.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension ContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  FinanceSemanticColors get financeColors => theme.financeSemantic;
}

extension BuildContextCurrencyFormatX on BuildContext {
  /// Формат цены в USD под текущую локаль UI (в API проекта цены в долларах).
  NumberFormat get usdCurrencyFormat => NumberFormat.currency(
    locale: Localizations.localeOf(this).toString(),
    symbol: r'$',
    decimalDigits: 2,
  );
}
