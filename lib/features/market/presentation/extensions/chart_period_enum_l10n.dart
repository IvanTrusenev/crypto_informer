import 'package:crypto_informer/features/market/domain/value_objects/chart_period_enum.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';

extension ChartPeriodEnumL10n on ChartPeriodEnum {
  /// Подпись для чипа периода (локализуется в ARB).
  String localizedShortLabel(AppLocalizations l10n) => switch (this) {
        ChartPeriodEnum.day1 => l10n.chartPeriod1d,
        ChartPeriodEnum.days7 => l10n.chartPeriod7d,
        ChartPeriodEnum.days30 => l10n.chartPeriod30d,
        ChartPeriodEnum.days90 => l10n.chartPeriod90d,
        ChartPeriodEnum.days365 => l10n.chartPeriod1y,
        ChartPeriodEnum.max => l10n.chartPeriodMax,
      };
}
