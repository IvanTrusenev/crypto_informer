/// Язык: [system] — правило «ru, если локаль ОС русская, иначе en».
enum AppLocalePreference {
  system,
  ru,
  en,
}

/// Цветовая схема: [system] — следует настройкам ОС.
enum AppThemePreference {
  system,
  light,
  dark,
}

class AppSettings {
  const AppSettings({
    required this.localePreference,
    required this.themePreference,
  });

  final AppLocalePreference localePreference;
  final AppThemePreference themePreference;

  static const initial = AppSettings(
    localePreference: AppLocalePreference.system,
    themePreference: AppThemePreference.system,
  );
}
