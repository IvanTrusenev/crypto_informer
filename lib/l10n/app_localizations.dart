import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Crypto Informer'**
  String get appTitle;

  /// No description provided for @offlineNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Showing saved data.'**
  String get offlineNoConnection;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get navWatchlist;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsThemeSection.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get settingsThemeSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get settingsAbout;

  /// No description provided for @dialogClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// No description provided for @marketTitle.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get marketTitle;

  /// No description provided for @marketSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or ticker'**
  String get marketSearchHint;

  /// No description provided for @marketSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search.'**
  String get marketSearchNoResults;

  /// No description provided for @marketSortSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sorting'**
  String get marketSortSectionTitle;

  /// No description provided for @marketSortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get marketSortName;

  /// No description provided for @marketSortPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get marketSortPrice;

  /// No description provided for @marketSortMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market cap'**
  String get marketSortMarketCap;

  /// No description provided for @marketSortReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get marketSortReset;

  /// No description provided for @marketEmpty.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get marketEmpty;

  /// No description provided for @marketAssetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{symbol} · {change}'**
  String marketAssetSubtitle(String symbol, String change);

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @tooltipWatchlistRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get tooltipWatchlistRemove;

  /// No description provided for @tooltipWatchlistAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get tooltipWatchlistAdd;

  /// No description provided for @coinTitleFallback.
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get coinTitleFallback;

  /// No description provided for @coinSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get coinSectionDescription;

  /// No description provided for @coinChange24h.
  ///
  /// In en, this message translates to:
  /// **'{percent}% in 24h'**
  String coinChange24h(String percent);

  /// No description provided for @coinPriceChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Price chart (USD)'**
  String get coinPriceChartTitle;

  /// No description provided for @coinPriceChartHint.
  ///
  /// In en, this message translates to:
  /// **'Historical prices are loaded from the network.'**
  String get coinPriceChartHint;

  /// No description provided for @coinChartNoData.
  ///
  /// In en, this message translates to:
  /// **'No data for this period.'**
  String get coinChartNoData;

  /// No description provided for @watchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlistTitle;

  /// No description provided for @watchlistEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add coins with the star on the Market screen.'**
  String get watchlistEmptyBody;

  /// No description provided for @watchlistPartialMissing.
  ///
  /// In en, this message translates to:
  /// **'Some favorites are not in the current market top ({missing}). Open a coin from Market or refresh the list.'**
  String watchlistPartialMissing(int missing);

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get aboutTitle;

  /// No description provided for @aboutHeadline.
  ///
  /// In en, this message translates to:
  /// **'Crypto Informer'**
  String get aboutHeadline;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'OTUS course project: cryptocurrency informer.'**
  String get aboutTagline;

  /// No description provided for @aboutSectionArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get aboutSectionArchitecture;

  /// No description provided for @aboutArchitectureBulletList.
  ///
  /// In en, this message translates to:
  /// **'• Feature-first domain / data / presentation layers\n• Repositories and use cases in domain; API in data\n• Riverpod for state and dependency injection\n• go_router, StatefulShellRoute, settings and localization\n• Material 3 with light and dark themes\n• Coin screen: USD price chart (fl_chart) with selectable period'**
  String get aboutArchitectureBulletList;

  /// No description provided for @aboutSectionOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get aboutSectionOffline;

  /// No description provided for @aboutOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Offline-first: after a successful load, the market list and full coin card (price, 24h change, description) are stored in a local SQLite database. Without a network you still see that saved data. The price chart is not cached—it is fetched only when online. A banner above the bottom navigation appears when the device reports no connection.'**
  String get aboutOfflineBody;

  /// No description provided for @aboutSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get aboutSectionData;

  /// No description provided for @aboutDataBody.
  ///
  /// In en, this message translates to:
  /// **'CoinGecko public REST API (rate limits apply): market list and per-coin details (REST paths under /coins/…), plus market_chart time series for the USD price graph (periods from 1D to MAX).'**
  String get aboutDataBody;

  /// No description provided for @errorEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'Empty server response'**
  String get errorEmptyResponse;

  /// No description provided for @errorCoinNotFound.
  ///
  /// In en, this message translates to:
  /// **'Coin not found'**
  String get errorCoinNotFound;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Check your connection.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error ({statusCode})'**
  String errorServer(int statusCode);

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnexpected;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
