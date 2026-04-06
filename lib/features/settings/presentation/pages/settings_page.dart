import 'dart:async';

import 'package:crypto_informer/features/about/presentation/about_dialog.dart';
import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:crypto_informer/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _languageMenuLabel(AppLocalizations l10n, AppLocalePreference v) {
  return switch (v) {
    AppLocalePreference.system => l10n.settingsLanguageSystem,
    AppLocalePreference.en => l10n.settingsLanguageEnglish,
    AppLocalePreference.ru => l10n.settingsLanguageRussian,
  };
}

String _themeMenuLabel(AppLocalizations l10n, AppThemePreference v) {
  return switch (v) {
    AppThemePreference.system => l10n.settingsThemeSystem,
    AppThemePreference.light => l10n.settingsThemeLight,
    AppThemePreference.dark => l10n.settingsThemeDark,
  };
}

const _languageDropdownOrder = <AppLocalePreference>[
  AppLocalePreference.system,
  AppLocalePreference.en,
  AppLocalePreference.ru,
];

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncSettings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: asyncSettings.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.settingsLanguageSection,
                  border: const OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppLocalePreference>(
                    value: settings.localePreference,
                    isExpanded: true,
                    isDense: true,
                    items: [
                      for (final v in _languageDropdownOrder)
                        DropdownMenuItem<AppLocalePreference>(
                          value: v,
                          child: Text(_languageMenuLabel(l10n, v)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        unawaited(
                          ref
                              .read(appSettingsProvider.notifier)
                              .setLocalePreference(v),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.settingsThemeSection,
                  border: const OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AppThemePreference>(
                    value: settings.themePreference,
                    isExpanded: true,
                    isDense: true,
                    items: [
                      for (final v in AppThemePreference.values)
                        DropdownMenuItem<AppThemePreference>(
                          value: v,
                          child: Text(_themeMenuLabel(l10n, v)),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        unawaited(
                          ref
                              .read(appSettingsProvider.notifier)
                              .setThemePreference(v),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsAbout),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => unawaited(showAboutAppDialog(context)),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
