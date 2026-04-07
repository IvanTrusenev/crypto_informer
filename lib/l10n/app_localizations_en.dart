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
  String get offlineNoConnection => 'No connection. Showing saved data.';

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
  String get marketSearchHint => 'Search by name or ticker';

  @override
  String get marketSearchNoResults => 'Nothing matches your search.';

  @override
  String get marketSortSectionTitle => 'Sorting';

  @override
  String get marketSortName => 'Name';

  @override
  String get marketSortPrice => 'Price';

  @override
  String get marketSortMarketCap => 'Market cap';

  @override
  String get marketSortReset => 'Reset';

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
  String get coinPriceChartTitle => 'Price chart (USD)';

  @override
  String get coinPriceChartHint =>
      'Historical prices are loaded from the network.';

  @override
  String get coinChartNoData => 'No data for this period.';

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
      '• Feature-first domain / data / presentation layers\n• Repositories and use cases in domain; API in data\n• BLoC (Cubit) for state management, get_it for DI\n• go_router, StatefulShellRoute, settings and localization\n• Material 3 with light and dark themes\n• Coin screen: USD price chart (fl_chart) with selectable period';

  @override
  String get aboutSectionCache => 'Local cache';

  @override
  String aboutCacheCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coins cached',
      one: '1 coin cached',
      zero: 'No coins cached',
    );
    return '$_temp0';
  }

  @override
  String get aboutSectionOffline => 'Offline';

  @override
  String get aboutOfflineBody =>
      'Offline-first: after a successful load, the market list and full coin card (price, 24h change, description) are stored in a local SQLite database. Without a network you still see that saved data. The price chart is not cached—it is fetched only when online. A banner above the bottom navigation appears when the device reports no connection.';

  @override
  String get aboutSectionData => 'Data';

  @override
  String get aboutDataBody =>
      'CoinGecko public REST API (rate limits apply): market list and per-coin details (REST paths under /coins/…), plus market_chart time series for the USD price graph (periods from 1D to MAX).';

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

  @override
  String get alertDialogTitle => 'Price alert';

  @override
  String alertCurrentPrice(String price) {
    return 'Current price: $price';
  }

  @override
  String get alertThresholdLabel => 'Target price (USD)';

  @override
  String get alertDirectionAbove => 'Above';

  @override
  String get alertDirectionBelow => 'Below';

  @override
  String get alertSetAction => 'Set alert';

  @override
  String get alertRemoveAction => 'Remove alert';

  @override
  String get alertCancelAction => 'Cancel';

  @override
  String get alertInvalidPrice => 'Enter a valid price';

  @override
  String alertSetConfirmation(String coinName) {
    return 'Alert set for $coinName';
  }

  @override
  String get alertRemovedConfirmation => 'Alert removed';

  @override
  String alertTriggeredTitle(String coinName) {
    return '$coinName';
  }

  @override
  String alertTriggeredAbove(String price) {
    return 'Price crossed above $price';
  }

  @override
  String alertTriggeredBelow(String price) {
    return 'Price dropped below $price';
  }

  @override
  String get tooltipAlertSet => 'Set price alert';

  @override
  String get tooltipAlertActive => 'Price alert active';
}
