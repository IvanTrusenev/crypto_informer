import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';

/// Эффективная локаль приложения с учётом [preference] и локали платформы.
Locale resolveAppLocale(
  AppLocalePreference preference,
  Locale platformLocale,
) {
  switch (preference) {
    case AppLocalePreference.system:
      if (platformLocale.languageCode == 'ru') {
        return const Locale('ru');
      }
      return const Locale('en');
    case AppLocalePreference.ru:
      return const Locale('ru');
    case AppLocalePreference.en:
      return const Locale('en');
  }
}
