// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Crypto Informer';

  @override
  String get navMarket => 'Market';

  @override
  String get navWatchlist => 'Watchlist';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsThemeSection => 'Color scheme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsAbout => 'About the app';

  @override
  String get dialogClose => 'Close';

  @override
  String get marketTitle => 'Market';

  @override
  String get marketEmpty => 'No data';

  @override
  String marketAssetSubtitle(String symbol, String change) {
    return '$symbol · $change';
  }

  @override
  String get retryAction => 'Retry';

  @override
  String get tooltipWatchlistRemove => 'Remove from watchlist';

  @override
  String get tooltipWatchlistAdd => 'Add to watchlist';

  @override
  String get coinTitleFallback => 'Coin';

  @override
  String get coinSectionDescription => 'Description';

  @override
  String coinChange24h(String percent) {
    return '$percent% in 24h';
  }

  @override
  String get watchlistTitle => 'Watchlist';

  @override
  String get watchlistEmptyBody =>
      'Add coins with the star on the Market screen.';

  @override
  String watchlistPartialMissing(int missing) {
    return 'Some favorites are not in the current market top ($missing). Open a coin from Market or refresh the list.';
  }

  @override
  String get aboutTitle => 'About the app';

  @override
  String get aboutHeadline => 'Crypto Informer';

  @override
  String get aboutTagline => 'OTUS course project: cryptocurrency informer.';

  @override
  String get aboutSectionArchitecture => 'Architecture';

  @override
  String get aboutArchitectureBulletList =>
      '• Feature-first domain / data / presentation layers\n• Repositories and use cases in domain; API in data\n• Riverpod for state and dependency injection\n• go_router, StatefulShellRoute, settings and localization\n• Material 3 with light and dark themes';

  @override
  String get aboutSectionData => 'Data';

  @override
  String get aboutDataBody =>
      'Prices and descriptions: public CoinGecko API (rate limits apply).';

  @override
  String get errorEmptyResponse => 'Empty server response';

  @override
  String get errorCoinNotFound => 'Coin not found';

  @override
  String get errorTimeout => 'Request timed out. Check your connection.';

  @override
  String errorServer(int statusCode) {
    return 'Server error ($statusCode)';
  }

  @override
  String get errorNetwork => 'Network error';

  @override
  String get errorUnexpected => 'Something went wrong';
}
