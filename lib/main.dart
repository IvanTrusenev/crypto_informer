import 'dart:io';

import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/localization/locale_resolution.dart';
import 'package:crypto_informer/core/router/app_router.dart';
import 'package:crypto_informer/core/theme/app_theme.dart';
import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:crypto_informer/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const ProviderScope(child: CryptoInformerApp()));
}

class CryptoInformerApp extends ConsumerWidget {
  const CryptoInformerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final settings = ref.watch(appSettingsProvider).valueOrNull ??
        AppSettings.initial;
    final locale = resolveAppLocale(
      settings.localePreference,
      platformLocale,
    );

    final themeMode = switch (settings.themePreference) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };

    return MaterialApp.router(
      onGenerateTitle: (ctx) => ctx.l10n.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
