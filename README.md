# Crypto Informer

Курсовой проект OTUS: Flutter-приложение — информер криптовалют с курсами и краткими описаниями монет.

## Возможности

- **Рынок** — список активов с ценой в USD и изменением за 24 часа; данные с публичного API CoinGecko (действуют лимиты запросов).
- **Деталь монеты** — описание, цена, изменение за 24ч; переход из списка рынка.
- **Избранное** — список отмеченных монет (хранение id в `SharedPreferences`).
- **Настройки** — язык интерфейса (системный / English / Russian), светлая / тёмная / системная тема, диалог «О программе».
- **Offline-first** — успешные ответы API кэшируются в **SQLite** (`sqflite`); без сети показываются последние сохранённые данные. Над нижней навигацией отображается баннер при отсутствии связи (`connectivity_plus`).
- **Локализация** — ARB-файлы в `lib/l10n/`, генерация через `flutter gen-l10n` (см. `l10n.yaml`).

## Стек

| Область | Технологии |
|--------|------------|
| UI | Flutter, Material 3 |
| Состояние / DI | `flutter_riverpod` |
| Навигация | `go_router`, `StatefulShellRoute` |
| HTTP | `dio` |
| Локальное хранилище | `sqflite`, `shared_preferences` |
| Desktop SQLite | `sqflite_common_ffi` (инициализация в `main.dart`) |

## Требования

- Flutter SDK, совместимый с Dart **^3.10.1** (см. `pubspec.yaml`).

### Linux desktop

На Ubuntu/Debian для `flutter run -d linux` может понадобиться пакет **LLVM LLD** в той же версии, что и `clang` (иначе при сборке native assets для SQLite часто возникает ошибка `Failed to find any of [ld.lld, ld] in .../llvm-.../bin`). Пример:

```bash
sudo apt install lld-18
```

Подробности и типичные зависимости — **[docs/linux-setup.md](docs/linux-setup.md)**.

## Запуск

```bash
cd crypto_informer
flutter pub get
flutter gen-l10n   # при изменении .arb; часто выполняется при сборке
flutter run
```

Сборка под конкретную платформу — стандартными командами Flutter (`flutter run -d linux` и т.д.).

## Структура репозитория

```
lib/
  core/           # роутер, тема, сеть, БД, локализация, оболочка с навигацией
  features/       # market, watchlist, settings, about
  l10n/           # ARB и сгенерированные локализации
  main.dart
test/
docs/             # документация проекта
```

Подробная структура слоёв внутри `features/` (market, watchlist, settings, about) — в [docs/code-style.md](docs/code-style.md), раздел **«Структура фич»**.

## Кодстайл

Правила линтера, форматирования и соглашения по коду описаны в **[docs/code-style.md](docs/code-style.md)**.

Кратко: подключён пресет **very_good_analysis**; проверка — `flutter analyze` и `dart format`.

## Лицензия и публикация

Проект помечен как непубликуемый (`publish_to: 'none'` в `pubspec.yaml`).
