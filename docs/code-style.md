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

- **Общее** — `lib/core/` (роутинг, тема, сеть, хранилище, локализация, ошибки, расширения).
- **Импорты** — пакетный стиль `package:crypto_informer/...`.
- **Состояние и DI** — `flutter_bloc` (Cubit), `get_it`; навигация — `go_router` с `StatefulShellRoute`.

Эти пункты дополняют, но не заменяют правила из `very_good_analysis`.

### Именование моделей данных

| Постфикс | Назначение | Пример |
|----------|------------|--------|
| `Entity` | Доменные сущности (чистая модель без зависимостей) | `CryptoAssetEntity`, `CryptoCoinDetailEntity`, `PriceChartPointEntity` |
| `Dto` | Сетевые модели (Data Transfer Object) — маппинг JSON API → домен | `CryptoAssetDto`, `CryptoCoinDetailDto`, `CoinCurrentPriceDto`, `CoinDescriptionDto`, `CoinImageDto`, `CoinMarketDataDto`, `PriceChartPointDto` |
| `Dao` | Модели локальной БД (Data Access Object) — маппинг SQLite ↔ домен | `CryptoAssetDao`, `CryptoCoinDetailDao` |
| `Enum` | Доменные перечисления (value object) в `domain/value_objects/` | файл `*_enum.dart`, тип `PascalCase` + `Enum` — например `chart_period_enum.dart` / `ChartPeriodEnum` |

### Value objects (`domain/value_objects/`)

**Value object** в этом проекте — небольшой доменный тип **без** роли «сущности с идентичностью» (как у `*Entity` из API/кэша). Он задаёт **ограниченный набор значений**, подписи, маппинг во внешние параметры (например строка `order` для CoinGecko) или иные правила, которые не хочется размазывать по кубитам и репозиториям.

| Рядом лежит | Зачем отдельно |
|-------------|----------------|
| **`entities/`** | Сущности описывают данные предметной области (монета, точка графика). Value object описывает *как мы параметризуем* запрос или UI (период графика, колонка сортировки). |
| **`constants/`** | Константы — обычно скалярные дефолты (`perPage`, `order` по умолчанию). Value objects — именованные варианты с поведением: методы вроде `toApiOrder`, поля enhanced enum. |

На практике в `value_objects/` лежат **доменные enum’ы** по соглашению из таблицы выше (`*_enum.dart`, тип `…Enum`). Другие виды value objects (например небольшие `final class` с инвариантами) допустимы, если они остаются в `domain` без зависимостей от Flutter и инфраструктуры.

### Сериализация моделей (`json_serializable`)

Для Dto и Dao используется пакет **`json_serializable`** с кодогенерацией (`build_runner`).

| Тип модели | Аннотация | `fromJson` | `toJson` |
|------------|-----------|------------|----------|
| **Dto** | `@JsonSerializable(createToJson: false)` | ✅ генерируется | ❌ подавлен — DTO используется только для десериализации ответов API |
| **Dao** | `@JsonSerializable()` | ✅ генерируется | ✅ генерируется — нужен для записи/чтения JSON в SQLite |

Модели данных — **чистые контейнеры**: они хранят данные «как есть» из JSON, без нормализации или бизнес-логики. Вся нормализация (приведение `symbol` к верхнему регистру, фильтрация пустых строк `imageUrl`, очистка HTML из `description`) выполняется в **маппер-расширениях** при переходе Dto/Dao → Entity.

Вложенные JSON-структуры API отображаются **вложенными Dto-моделями** (например, `CoinImageDto`, `CoinMarketDataDto`), а не `readValue`-хелперами — модель остаётся зеркалом структуры JSON.

Для маппинга JSON-ключей применяется `@JsonKey`:

- `name` — имя ключа в JSON, если отличается от имени поля (`current_price` → `currentPriceUsd`).
- `defaultValue` — значение по умолчанию, если ключ отсутствует или `null`.

Сгенерированные файлы `*.g.dart` находятся рядом с моделями и **не редактируются вручную**. Перегенерация:

```bash
dart run build_runner build --delete-conflicting-outputs
```

> REST-клиент (`core/network/rest/coingecko_rest_client.g.dart`) исключён из `build_runner` через `build.yaml` — его `.g.dart` поддерживается вручную.

### Маппинг между слоями (`data/mapper/`)

Преобразование между Dto/Dao и Entity выделено в **отдельные файлы-маппер** на основе `extension`.

**Нейминг:** имя extension и файла — **`<ИмяМодели>Mapper`**, где `ИмяМодели` — класс, на котором объявлен extension (`extension XMapper on X`). Постфикс всегда `Mapper`. Пример: `CryptoAssetDto` → файл `crypto_asset_dto_mapper.dart`, extension `CryptoAssetDtoMapper` on `CryptoAssetDto`.

| Файл | Extension | Направление |
|------|-----------|-------------|
| `crypto_asset_dto_mapper.dart` | `CryptoAssetDtoMapper` on `CryptoAssetDto` | Dto → Entity (`toEntity()`) |
| `crypto_coin_detail_dto_mapper.dart` | `CryptoCoinDetailDtoMapper` on `CryptoCoinDetailDto` | Dto → Entity (`toEntity()`) |
| `crypto_asset_dao_mapper.dart` | `CryptoAssetDaoMapper` on `CryptoAssetDao` | Dao → Entity |
| `crypto_asset_entity_mapper.dart` | `CryptoAssetEntityMapper` on `CryptoAssetEntity` | Entity → Dao (`toDao()`) |
| `crypto_coin_detail_dao_mapper.dart` | `CryptoCoinDetailDaoMapper` on `CryptoCoinDetailDao` | Dao → Entity |
| `crypto_coin_detail_entity_mapper.dart` | `CryptoCoinDetailEntityMapper` on `CryptoCoinDetailEntity` | Entity → Dao (`toDao()`) |
| `price_chart_point_dto_mapper.dart` | `PriceChartPointDtoMapper` on `PriceChartPointDto` | Dto → Entity |

**Один extension — один файл.** Имя файла в snake_case совпадает с именем extension (без суффикса `.dart`). Модели данных (Dto/Dao) **не содержат** методов `toEntity()`/`fromEntity()` и **не выполняют нормализацию данных** — вся логика преобразования и нормализации (например, `symbol.toUpperCase()`, фильтрация пустого `imageUrl`) сосредоточена в маппер-расширениях.

### Структура фич (`lib/features/<имя_фичи>/`)

Каждая фича — отдельный каталог. Полный набор слоёв **domain → data → presentation** используется там, где есть бизнес-правила и обмен с API/БД. Узкие фичи могут содержать только часть слоёв — это нормально, главное не тянуть инфраструктурные детали в `domain`.

| Слой | Назначение | Типичное содержимое |
|------|------------|---------------------|
| **domain** | Правила и контракты без Flutter/Dio/sqflite | сущности (`entities`), `constants/` (скалярные дефолты запросов), `value_objects/` (перечисления и мелкие типы — подраздел **Value objects**), интерфейсы репозиториев, use case-ы |
| **data** | Реализация доступа к данным | DTO (сеть, `*_dto.dart`), DAO (БД, `*_dao.dart`), datasources (remote/local), `*RepositoryImpl` |
| **presentation** | UI и привязка к состоянию | страницы (`pages/`), виджеты (`widgets/`), кубиты (`cubit/`) |

**Зависимости между слоями одной фичи:** `presentation` → `domain` (и опосредованно через интерфейсы репозитория); `data` → `domain` (реализует контракты). `domain` не импортирует `data` и `presentation`.

Ниже — как это разложено в текущем проекте.

#### `market` — рынок и деталь монеты

Центральная фича данных: CoinGecko по сети + кэш SQLite для списка и карточки монеты; на экране деталей дополнительно **график цены** (только сеть, без записи в БД).

```
lib/features/market/
  domain/
    constants/          # MarketListQueryDefaults (vsCurrency, page, perPage, order для списка рынка)
    entities/           # CryptoAssetEntity, CryptoCoinDetailEntity, PriceChartPointEntity
    value_objects/      # ChartPeriodEnum, MarketSortColumnEnum
    repositories/       # абстрактный CryptoRepository (+ getPriceChart)
    usecases/           # GetMarketAssets, GetCoinDetail (обёртки над репозиторием)
  data/
    datasources/        # remote/local (+ fetchMarketChart в remote)
    mapper/             # extension-маппер: Dto/Dao ↔ Entity (один файл — один маппер)
    models/             # *_dto.dart (сеть), *_dao.dart (БД); вложенные DTO (CoinCurrentPriceDto, CoinDescriptionDto, CoinImageDto, CoinMarketDataDto)
    utils/              # price_chart_sampling (прореживание точек для отрисовки)
    repositories/       # CryptoRepositoryImpl (offline-first для рынка/карточки)
  presentation/
    pages/              # MarketPage, CoinDetailPage
    widgets/            # coin_price_chart_section (график + чипы периода)
    cubit/              # MarketCubit, CoinDetailCubit, CoinPriceChartCubit
```

**Данные и кэш**

| Данные | Источник | Локальный кэш |
|--------|----------|----------------|
| Список рынка, карточка монеты (описание, цена, 24ч) | CoinGecko (`/coins/markets`, `/coins/{id}`) | SQLite через `CryptoLocalDataSource` |
| История цен для графика | CoinGecko `/coins/{id}/market_chart` | нет (каждый раз с сети; при ошибке — сообщение и «Повторить») |

Кубиты получают зависимости через `get_it`. `CoinPriceChartCubit` зависит от `CryptoRepository` и запрашивает данные по паре (id монеты + `ChartPeriodEnum`). Отрисовка — пакет **`fl_chart`** (`LineChart`).

#### `watchlist` — избранное

Список id монет хранится в `SharedPreferences`; для подписей и цен фича **читает** уже загруженный рынок через `marketAssetsProvider`, не дублируя сетевой слой.

```
lib/features/watchlist/
  presentation/
    pages/              # WatchlistPage
    cubit/              # WatchlistCubit (список id + синхронизация с prefs)
```

Отдельного `domain`/`data` нет: предметная область минимальна, доступ к хранилищу сосредоточен в кубите.

#### `settings` — настройки приложения

Язык, тема, входная точка в «О программе».

```
lib/features/settings/
  domain/
    app_settings.dart   # модель настроек + enum-ы предпочтений
  presentation/
    pages/              # SettingsPage
    cubit/              # AppSettingsCubit (чтение/запись SharedPreferences)
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

### Хранилище (`lib/core/storage/`)

Хранилище разделено на две подсистемы, каждая инкапсулирована через абстракцию:

| Подсистема | Абстракция | Реализация | Назначение |
|------------|-----------|------------|------------|
| `storage/sql/` | `AppDatabase` | `AppDatabaseImpl` (sqflite) | Открытие БД, версия, `onCreate` (схема таблиц) |
| `storage/sql/tables/` | `MarketAssetsCacheSql` | `MarketAssetsCacheSqlImpl` | Таблица `market_assets_cache` (один файл — одна таблица; новые таблицы — новые пары файлов в этой папке) |
| `storage/sql/tables/` | `CoinDetailCacheSql` | `CoinDetailCacheSqlImpl` | Таблица `coin_detail_cache` |
| `storage/shared_pref/` | `AppKeyValueStorage` | `AppKeyValueStorageImpl` (SharedPreferences) | Key-value хранилище (настройки, watchlist, алерты) |

Потребители зависят от **абстракций**, а не от конкретных реализаций (`SharedPreferences`, `Database`). `features/market` `CryptoLocalDataSourceImpl` получает `MarketAssetsCacheSql` и `CoinDetailCacheSql`, работает с DAO/JSON, **без** импорта `sqflite`. Реализации регистрируются в `service_locator.dart`. Контракты и реализации по таблицам лежат в `storage/sql/tables/`, чтобы не смешивать их с `app_database*.dart` в корне `sql/`.

### Расширения (`lib/core/extensions/`)

Общие extension-методы, переиспользуемые несколькими фичами:

- `NullableStringX` on `String?` — `.nonEmpty` (фильтрация пустых строк), `.cleanHtml()` (очистка HTML-тегов).

### Граница с `lib/core`

В `core` лежит то, что **переиспользуется несколькими фичами** или относится к «каркасу» приложения: `app_router`, `scaffold_with_nav_bar`, `network/rest`, `storage/sql`, `storage/shared_pref`, тема, расширения, общие ошибки. Фича `market` использует `core` для сети и хранилища, но **смысловые** модели рынка и репозиторий объявлены внутри `features/market`, чтобы не раздувать `core` предметной логикой.

## Ссылки

- [very_good_analysis на pub.dev](https://pub.dev/packages/very_good_analysis)
- [Настройка анализатора Dart](https://dart.dev/tools/analysis)
- [dart format](https://dart.dev/tools/dart-format)
