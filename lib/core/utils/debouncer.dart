import 'dart:async';

/// Откладывает выполнение колбэка на заданную паузу после последнего
/// вызова `run`.
///
/// Подходит для поиска и полей ввода: каждый новый вызов `run` сбрасывает
/// таймер.
class Debouncer {
  Debouncer({required this.duration});

  /// Пауза после последнего вызова `run` до выполнения действия.
  final Duration duration;

  Timer? _timer;

  /// Запланировать колбэк. Предыдущий запланированный вызов отменяется.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Отменить ожидающее действие (например при очистке поля).
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Отменить таймер; вызывать из `dispose` состояния виджета.
  void dispose() {
    cancel();
  }
}
