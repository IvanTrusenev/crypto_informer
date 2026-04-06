// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Crypto Informer';

  @override
  String get offlineNoConnection => 'Нет связи. Показаны сохранённые данные.';

  @override
  String get navMarket => 'Рынок';

  @override
  String get navWatchlist => 'Избранное';

  @override
  String get navSettings => 'Настройки';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguageSection => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsThemeSection => 'Цветовая схема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsAbout => 'О программе';

  @override
  String get dialogClose => 'Закрыть';

  @override
  String get marketTitle => 'Рынок';

  @override
  String get marketEmpty => 'Нет данных';

  @override
  String marketAssetSubtitle(String symbol, String change) {
    return '$symbol · $change';
  }

  @override
  String get retryAction => 'Повторить';

  @override
  String get tooltipWatchlistRemove => 'Убрать из избранного';

  @override
  String get tooltipWatchlistAdd => 'В избранное';

  @override
  String get coinTitleFallback => 'Монета';

  @override
  String get coinSectionDescription => 'Описание';

  @override
  String coinChange24h(String percent) {
    return '$percent% за 24ч';
  }

  @override
  String get watchlistTitle => 'Избранное';

  @override
  String get watchlistEmptyBody =>
      'Добавьте монеты звёздочкой на экране «Рынок».';

  @override
  String watchlistPartialMissing(int missing) {
    return 'Часть избранного не в топ-списке рынка ($missing). Откройте монету с «Рынка» или обновите список.';
  }

  @override
  String get aboutTitle => 'О программе';

  @override
  String get aboutHeadline => 'Crypto Informer';

  @override
  String get aboutTagline => 'Курсовой проект OTUS: информер криптовалют.';

  @override
  String get aboutSectionArchitecture => 'Архитектура';

  @override
  String get aboutArchitectureBulletList =>
      '• Слои domain / data / presentation по фичам\n• Репозитории и use case-ы в domain, реализация и API в data\n• Riverpod для состояния и DI\n• go_router, StatefulShellRoute, настройки и локализация\n• Material 3 со светлой и тёмной темой';

  @override
  String get aboutSectionOffline => 'Офлайн';

  @override
  String get aboutOfflineBody =>
      'Ориентация на работу без сети: после успешной загрузки список рынка и детали монет сохраняются в локальной базе SQLite. Без интернета отображаются последние сохранённые данные. Над нижней навигацией показывается баннер, когда устройство сообщает об отсутствии связи.';

  @override
  String get aboutSectionData => 'Данные';

  @override
  String get aboutDataBody =>
      'Курсы и описания: публичный API CoinGecko (есть лимиты запросов).';

  @override
  String get errorEmptyResponse => 'Пустой ответ сервера';

  @override
  String get errorCoinNotFound => 'Монета не найдена';

  @override
  String get errorTimeout => 'Превышено время ожидания. Проверьте сеть.';

  @override
  String errorServer(int statusCode) {
    return 'Ошибка сервера ($statusCode)';
  }

  @override
  String get errorNetwork => 'Ошибка сети';

  @override
  String get errorUnexpected => 'Что-то пошло не так';
}
