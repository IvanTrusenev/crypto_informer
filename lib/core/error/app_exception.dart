/// Ошибка уровня приложения (данные / сеть). Слой presentation может показать [message].
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
