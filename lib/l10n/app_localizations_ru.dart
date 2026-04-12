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
  String get marketSearchHint => 'Поиск по названию или тикеру';

  @override
  String get marketSearchNoResults => 'Ничего не найдено.';

  @override
  String get marketSortSectionTitle => 'Сортировка';

  @override
  String get marketSortId => 'ID';

  @override
  String get marketSortVolume => 'Объём';

  @override
  String get marketSortMarketCap => 'Капитализация';

  @override
  String get marketSortReset => 'Сброс';

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
  String get coinPriceChartTitle => 'График цены (USD)';

  @override
  String get coinPriceChartHint => 'История цен загружается из сети.';

  @override
  String get coinChartNoData => 'Нет данных за выбранный период.';

  @override
  String get chartPeriod1d => '1Д';

  @override
  String get chartPeriod7d => '7Д';

  @override
  String get chartPeriod30d => '30Д';

  @override
  String get chartPeriod90d => '90Д';

  @override
  String get chartPeriod1y => '1Г';

  @override
  String get chartPeriodMax => 'Всё';

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
      '• Чистая архитектура: domain / data / presentation по фичам\n• Репозитории и use case-ы в domain, реализация и API в data\n• BLoC (Cubit) для управления состоянием, get_it для DI\n• Сеть: Dio + Retrofit (REST-клиент в core/network/dio)\n• go_router, StatefulShellRoute, настройки и локализация\n• Material 3 со светлой и тёмной темой\n• Экран монеты: график цены в USD (fl_chart) с выбором периода';

  @override
  String get aboutSectionCache => 'Локальный кэш';

  @override
  String aboutCacheCoins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count монет в кэше',
      many: '$count монет в кэше',
      few: '$count монеты в кэше',
      one: '1 монета в кэше',
      zero: 'Монеты не кэшированы',
    );
    return '$_temp0';
  }

  @override
  String get aboutSectionOffline => 'Офлайн';

  @override
  String get aboutOfflineBody =>
      'Ориентация на работу без сети: после успешной загрузки список рынка и полная карточка монеты (цена, изменение за 24ч, описание) сохраняются в локальной базе SQLite. Без интернета видны эти сохранённые данные. График цены в базу не пишется — история запрашивается только при наличии сети. Над нижней навигацией показывается баннер, когда устройство сообщает об отсутствии связи.';

  @override
  String get aboutSectionData => 'Данные';

  @override
  String get aboutSectionNetworking => 'Сетевой слой';

  @override
  String get aboutNetworkingBody =>
      'HTTP-клиент Dio c Retrofit-генерируемым REST API интерфейсом (core/network/dio). REST-клиент инжектируется через абстракцию, следуя принципам чистой архитектуры.';

  @override
  String get aboutDataBody =>
      'Публичный REST API CoinGecko (есть лимиты запросов): список рынка и детали монеты (пути вида /coins/…), а также временной ряд market_chart для графика цены в USD (периоды от 1D до MAX).';

  @override
  String get errorCache => 'Ошибка локального хранилища';

  @override
  String get errorEmptyResponse => 'Пустой ответ сервера';

  @override
  String get errorCoinNotFound => 'Монета не найдена';

  @override
  String get errorInvalidResponse => 'Некорректный ответ сервера';

  @override
  String get errorTimeout => 'Превышено время ожидания. Проверьте сеть.';

  @override
  String get errorTooManyRequests =>
      'Слишком много запросов. Попробуйте позже.';

  @override
  String get errorUnauthorized => 'Требуется авторизация';

  @override
  String errorServer(int statusCode) {
    return 'Ошибка сервера ($statusCode)';
  }

  @override
  String get errorNetwork => 'Ошибка сети';

  @override
  String get errorUnexpected => 'Что-то пошло не так';

  @override
  String get alertDialogTitle => 'Уведомление о цене';

  @override
  String alertCurrentPrice(String price) {
    return 'Текущая цена: $price';
  }

  @override
  String get alertThresholdLabel => 'Целевая цена (USD)';

  @override
  String get alertDirectionAbove => 'Выше';

  @override
  String get alertDirectionBelow => 'Ниже';

  @override
  String get alertSetAction => 'Установить';

  @override
  String get alertRemoveAction => 'Удалить уведомление';

  @override
  String get alertCancelAction => 'Отмена';

  @override
  String get alertInvalidPrice => 'Введите корректную цену';

  @override
  String alertSetConfirmation(String coinName) {
    return 'Уведомление установлено для $coinName';
  }

  @override
  String get alertRemovedConfirmation => 'Уведомление удалено';

  @override
  String alertTriggeredTitle(String coinName) {
    return '$coinName';
  }

  @override
  String alertTriggeredAbove(String price) {
    return 'Цена поднялась выше $price';
  }

  @override
  String alertTriggeredBelow(String price) {
    return 'Цена опустилась ниже $price';
  }

  @override
  String get tooltipAlertSet => 'Установить уведомление';

  @override
  String get tooltipAlertActive => 'Уведомление активно';
}
