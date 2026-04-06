# Кодстайл

Проект следует строгим правилам статического анализа и форматирования Dart / Flutter. Настройки заданы в корневом файле [`analysis_options.yaml`](../analysis_options.yaml).

## Линтер и анализатор

- Подключён пресет [**very_good_analysis**](https://pub.dev/packages/very_good_analysis) (версия указана в `pubspec.yaml` как `dev_dependency`).
- В `analysis_options.yaml` используется `include: package:very_good_analysis/analysis_options.yaml`, поэтому действует большой набор правил (в духе строгого режима для пакетов и приложений Very Good Ventures).

### Дополнительные настройки в этом репозитории

| Область | Настройка | Смысл |
|--------|-----------|--------|
| **Analyzer** | `exclude`: `build/**`, `.dart_tool/**` | Исключены сгенерированные каталоги из анализа. |
| **Errors** | `deprecated_member_use: warning` | Устаревший API помечается предупреждением, а не ошибкой (удобнее поэтапно обновлять зависимости). |
| **Formatter** | `trailing_commas: preserve` | Сохранение завершающих запятых как в исходном коде при форматировании. |
| **Linter** | `public_member_api_docs: false` | Не требовать `dartdoc` для каждого публичного члена приложения (в курсовом приложении это часто избыточно). При желании максимальной строгости правило можно включить и документировать публичный API. |

## Форматирование

- Используется встроенный форматтер Dart: **`dart format .`** (или форматирование из IDE на основе тех же правил).
- Длинные строки: в пресете есть ограничение длины строки (в т.ч. правило `lines_longer_than_80_chars`); переносите длинные сигнатуры и цепочки вызовов.

## Проверка перед коммитом

Рекомендуемые команды из корня проекта:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

`flutter analyze` должен завершаться без ошибок и предупреждений, если код соответствует текущему `analysis_options.yaml`.

## Архитектура кода (соглашения проекта)

Помимо линтера, в репозитории приняты такие ориентиры:

- **Общее** — `lib/core/` (роутинг, тема, сеть, БД, локализация, ошибки).
- **Импорты** — пакетный стиль `package:crypto_informer/...`.
- **Состояние и DI** — `flutter_riverpod`; навигация — `go_router` с `StatefulShellRoute`.

Эти пункты дополняют, но не заменяют правила из `very_good_analysis`.

### Структура фич (`lib/features/<имя_фичи>/`)

Каждая фича — отдельный каталог. Полный набор слоёв **domain → data → presentation** используется там, где есть бизнес-правила и обмен с API/БД. Узкие фичи могут содержать только часть слоёв — это нормально, главное не тянуть инфраструктурные детали в `domain`.

| Слой | Назначение | Типичное содержимое |
|------|------------|---------------------|
| **domain** | Правила и контракты без Flutter/Dio/sqflite | сущности (`entities`), интерфейсы репозиториев, use case-ы |
| **data** | Реализация доступа к данным | модели (JSON ↔ domain), datasources (remote/local), `*RepositoryImpl` |
| **presentation** | UI и привязка к состоянию | страницы (`pages/`), виджеты (`widgets/`), провайдеры Riverpod (`providers/`) |

**Зависимости между слоями одной фичи:** `presentation` → `domain` (и опосредованно через интерфейсы репозитория); `data` → `domain` (реализует контракты). `domain` не импортирует `data` и `presentation`.

Ниже — как это разложено в текущем проекте.

#### `market` — рынок и деталь монеты

Центральная фича данных: CoinGecko по сети + кэш SQLite, экраны списка и деталей.

```
lib/features/market/
  domain/
    entities/           # CryptoAsset, CryptoCoinDetail
    repositories/       # абстрактный CryptoRepository
    usecases/           # GetMarketAssets, GetCoinDetail (обёртки над репозиторием)
  data/
    datasources/        # CryptoRemoteDataSource, CryptoLocalDataSource (+ реализации)
    models/             # маппинг JSON API → entity
    repositories/       # CryptoRepositoryImpl (remote + local, offline-first)
  presentation/
    pages/              # MarketPage, CoinDetailPage
    providers/          # databaseProvider, cryptoRepositoryProvider, marketAssetsProvider, coinDetailProvider
```

Провайдеры здесь собирают зависимости из `core` (Dio, открытие БД) и фичи `data`; страницы только читают `FutureProvider` / `family` и отображают состояние.

#### `watchlist` — избранное

Список id монет хранится в `SharedPreferences`; для подписей и цен фича **читает** уже загруженный рынок через `marketAssetsProvider`, не дублируя сетевой слой.

```
lib/features/watchlist/
  presentation/
    pages/              # WatchlistPage
    providers/          # watchlist_provider (список id + синхронизация с prefs)
```

Отдельного `domain`/`data` нет: предметная область минимальна, доступ к хранилищу сосредоточен в провайдере.

#### `settings` — настройки приложения

Язык, тема, входная точка в «О программе».

```
lib/features/settings/
  domain/
    app_settings.dart   # модель настроек + enum-ы предпочтений
  presentation/
    pages/              # SettingsPage
    providers/          # app_settings_provider (чтение/запись SharedPreferences)
```

#### `about` — текст «О программе»

Только UI для диалога из настроек.

```
lib/features/about/
  presentation/
    about_dialog.dart
    widgets/
      about_content.dart
```

Строки — из `lib/l10n` через `context.l10n`; дублировать текст в коде не нужно.

### Граница с `lib/core`

В `core` лежит то, что **переиспользуется несколькими фичами** или относится к «каркасу» приложения: `app_router`, `scaffold_with_nav_bar`, `dio_provider`, `openAppDatabase`, тема, расширения `BuildContext`, общие ошибки. Фича `market` использует `core` для сети и файла БД, но **смысловые** модели рынка и репозиторий объявлены внутри `features/market`, чтобы не раздувать `core` предметной логикой.

## Ссылки

- [very_good_analysis на pub.dev](https://pub.dev/packages/very_good_analysis)
- [Настройка анализатора Dart](https://dart.dev/tools/analysis)
- [dart format](https://dart.dev/tools/dart-format)
