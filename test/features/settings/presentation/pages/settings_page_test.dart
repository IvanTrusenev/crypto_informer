import 'package:crypto_informer/features/settings/domain/app_settings.dart';
import 'package:crypto_informer/features/settings/presentation/cubit/app_settings_cubit.dart';
import 'package:crypto_informer/features/settings/presentation/pages/settings_page.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders language and theme dropdowns', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppSettingsCubit(prefs)..loadSettings(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byType(DropdownButton<AppLocalePreference>),
      findsOneWidget,
    );
    expect(
      find.byType(DropdownButton<AppThemePreference>),
      findsOneWidget,
    );
  });
}
