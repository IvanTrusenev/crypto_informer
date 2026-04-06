# Сборка и запуск на Linux

## Ошибка `Failed to find any of [ld.lld, ld] in .../llvm-.../bin`

При `flutter run -d linux` или `flutter build linux` Dart компилирует **native assets** для пакета [`sqlite3`](https://pub.dev/packages/sqlite3) (его подтягивает [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi) для десктопной SQLite).

Инструмент Flutter берёт каталог LLVM из пути к **`clang++`**: после разрешения симлинков это часто `/usr/lib/llvm-18/bin` на Ubuntu 24.04. В этом каталоге должны лежать не только `clang` / `clang++`, но и линкер — **`ld.lld`** (предпочтительно) или **`ld`**.

Пакет **`clang`** из репозитория Ubuntu не всегда ставит **`lld`** в тот же префикс, из‑за чего сборка обрывается указанной ошибкой.

### Решение (Ubuntu / Debian)

Установите LLVM LLD, совпадающий с версией clang (для LLVM 18):

```bash
sudo apt update
sudo apt install lld-18
```

При необходимости также убедитесь, что стоят базовые зависимости для Linux desktop Flutter (обычно уже стоят, если `flutter doctor` без ошибок по Linux):

```bash
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

После установки `lld-18` снова выполните:

```bash
flutter clean
flutter pub get
flutter run -d linux
```

## Почему это связано с проектом

В [`main.dart`](../lib/main.dart) для Linux (и Windows/macOS) вызывается `sqfliteFfiInit()` и задаётся `databaseFactory` из `sqflite_common_ffi`, чтобы локальная БД кэша рынка работала на десктопе. Это тянет нативную сборку `sqlite3` при компиляции приложения.

## Дополнительно

- Сообщение ищет линкер **только** рядом с используемым `clang++`, а не в произвольном `PATH` (см. исходники Flutter: `native_assets/linux/native_assets.dart`).
- Если после установки `lld-18` ошибка сохраняется, выполните `which clang++`, `readlink -f $(which clang++)` и проверьте, что в том же каталоге появились `ld.lld` или `ld`.
