import 'package:crypto_informer/core/storage/shared_preferences_provider.dart';
import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePreference = 'app_locale_preference';
const _kThemePreference = 'app_theme_preference';
const _kLegacyUseDarkTheme = 'app_use_dark_theme';

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    return AppSettings(
      localePreference: _readLocale(prefs),
      themePreference: _readTheme(prefs),
    );
  }

  AppLocalePreference _readLocale(SharedPreferences prefs) {
    final raw = prefs.getString(_kLocalePreference);
    return switch (raw) {
      'ru' => AppLocalePreference.ru,
      'en' => AppLocalePreference.en,
      _ => AppLocalePreference.system,
    };
  }

  AppThemePreference _readTheme(SharedPreferences prefs) {
    final raw = prefs.getString(_kThemePreference);
    if (raw != null) {
      return switch (raw) {
        'light' => AppThemePreference.light,
        'dark' => AppThemePreference.dark,
        _ => AppThemePreference.system,
      };
    }
    return switch (prefs.getBool(_kLegacyUseDarkTheme)) {
      true => AppThemePreference.dark,
      false => AppThemePreference.light,
      null => AppThemePreference.system,
    };
  }

  Future<void> setLocalePreference(AppLocalePreference value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    switch (value) {
      case AppLocalePreference.system:
        await prefs.remove(_kLocalePreference);
      case AppLocalePreference.ru:
        await prefs.setString(_kLocalePreference, 'ru');
      case AppLocalePreference.en:
        await prefs.setString(_kLocalePreference, 'en');
    }
    final current = await future;
    state = AsyncData(
      AppSettings(
        localePreference: value,
        themePreference: current.themePreference,
      ),
    );
  }

  Future<void> setThemePreference(AppThemePreference value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    switch (value) {
      case AppThemePreference.system:
        await prefs.remove(_kThemePreference);
      case AppThemePreference.light:
        await prefs.setString(_kThemePreference, 'light');
      case AppThemePreference.dark:
        await prefs.setString(_kThemePreference, 'dark');
    }
    await prefs.remove(_kLegacyUseDarkTheme);
    final current = await future;
    state = AsyncData(
      AppSettings(
        localePreference: current.localePreference,
        themePreference: value,
      ),
    );
  }
}
