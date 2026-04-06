/// Код ошибки данных/сети; текст для UI строится в `app_exception_localizations.dart`.
enum AppErrorCode {
  emptyResponse,
  coinNotFound,
  timeout,
  serverError,
  network,
}

/// Ошибка уровня приложения без привязки к языку UI.
class AppException implements Exception {
  const AppException(this.code, {this.statusCode});

  final AppErrorCode code;
  final int? statusCode;

  @override
  String toString() => 'AppException($code, statusCode: $statusCode)';
}
