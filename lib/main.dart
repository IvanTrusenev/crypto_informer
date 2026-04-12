import 'dart:io';

import 'package:crypto_informer/core/di/service_locator.dart';
import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/core/localization/locale_resolution.dart';
import 'package:crypto_informer/core/router/app_router.dart';
import 'package:crypto_informer/core/theme/app_theme.dart';
import 'package:crypto_informer/features/alerts/presentation/cubit/price_alert_cubit.dart';
import 'package:crypto_informer/features/market/presentation/cubit/market/export.dart';
import 'package:crypto_informer/features/market/presentation/cubit/search/export.dart';
import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:crypto_informer/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:crypto_informer/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await initServiceLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppSettingsCubit(sl())..loadSettings(),
        ),
        BlocProvider(
          create: (_) => sl<SearchBloc>(),
        ),
        BlocProvider(
          create: (context) {
            return sl<MarketBloc>(param1: context.read<SearchBloc>())
              ..add(const MarketLoadRequested());
          },
        ),
        BlocProvider(
          create: (_) => WatchlistCubit(sl())..loadIds(),
        ),
        BlocProvider(
          create: (_) => PriceAlertCubit(sl())..loadAlerts(),
        ),
      ],
      child: const CryptoInformerApp(),
    ),
  );
}

class CryptoInformerApp extends StatelessWidget {
  const CryptoInformerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, settingsState) {
        final settings = switch (settingsState) {
          AppSettingsLoaded(:final settings) => settings,
          _ => AppSettings.initial,
        };

        final platformLocale =
            WidgetsBinding.instance.platformDispatcher.locale;
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
          routerConfig: appRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
