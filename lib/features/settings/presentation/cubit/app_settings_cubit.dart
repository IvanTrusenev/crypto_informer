import 'package:crypto_informer/core/storage/shared_pref/app_key_value_storage.dart';
import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kLocalePreference = 'app_locale_preference';
const _kThemePreference = 'app_theme_preference';
const _kLegacyUseDarkTheme = 'app_use_dark_theme';

sealed class AppSettingsState {
  const AppSettingsState();
}

class AppSettingsInitial extends AppSettingsState {
  const AppSettingsInitial();
}

class AppSettingsLoaded extends AppSettingsState {
  const AppSettingsLoaded(this.settings);
  final AppSettings settings;
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit(this._storage) : super(const AppSettingsInitial());

  final AppKeyValueStorage _storage;

  void loadSettings() {
    final settings = AppSettings(
      localePreference: _readLocale(),
      themePreference: _readTheme(),
    );
    emit(AppSettingsLoaded(settings));
  }

  AppLocalePreference _readLocale() {
    final raw = _storage.getString(_kLocalePreference);
    return switch (raw) {
      'ru' => AppLocalePreference.ru,
      'en' => AppLocalePreference.en,
      _ => AppLocalePreference.system,
    };
  }

  AppThemePreference _readTheme() {
    final raw = _storage.getString(_kThemePreference);
    if (raw != null) {
      return switch (raw) {
        'light' => AppThemePreference.light,
        'dark' => AppThemePreference.dark,
        _ => AppThemePreference.system,
      };
    }
    return switch (_storage.getBool(_kLegacyUseDarkTheme)) {
      true => AppThemePreference.dark,
      false => AppThemePreference.light,
      null => AppThemePreference.system,
    };
  }

  Future<void> setLocalePreference(AppLocalePreference value) async {
    switch (value) {
      case AppLocalePreference.system:
        await _storage.remove(_kLocalePreference);
      case AppLocalePreference.ru:
        await _storage.setString(_kLocalePreference, 'ru');
      case AppLocalePreference.en:
        await _storage.setString(_kLocalePreference, 'en');
    }
    final current = _currentSettings;
    emit(
      AppSettingsLoaded(
        AppSettings(
          localePreference: value,
          themePreference: current.themePreference,
        ),
      ),
    );
  }

  Future<void> setThemePreference(AppThemePreference value) async {
    switch (value) {
      case AppThemePreference.system:
        await _storage.remove(_kThemePreference);
      case AppThemePreference.light:
        await _storage.setString(_kThemePreference, 'light');
      case AppThemePreference.dark:
        await _storage.setString(_kThemePreference, 'dark');
    }
    await _storage.remove(_kLegacyUseDarkTheme);
    final current = _currentSettings;
    emit(
      AppSettingsLoaded(
        AppSettings(
          localePreference: current.localePreference,
          themePreference: value,
        ),
      ),
    );
  }

  AppSettings get _currentSettings {
    final s = state;
    if (s is AppSettingsLoaded) return s.settings;
    return AppSettings.initial;
  }
}
