import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';

extension AppExceptionLocalizations on AppException {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      CacheReadException() => l10n.errorCache,
      CacheWriteException() => l10n.errorCache,
      EmptyResponseException() => l10n.errorEmptyResponse,
      CoinNotFoundException() => l10n.errorCoinNotFound,
      NotFoundException() => l10n.errorServer(404),
      ResponseParsingException() => l10n.errorInvalidResponse,
      NetworkTimeoutException() => l10n.errorTimeout,
      TooManyRequestsException() => l10n.errorTooManyRequests,
      UnauthorizedException() => l10n.errorUnauthorized,
      ServerErrorException(statusCode: final statusCode) =>
        l10n.errorServer(statusCode),
      NetworkUnavailableException() => l10n.errorNetwork,
    };
  }
}

/// Локализованное сообщение для любого [Object] из провайдера/ошибки.
String localizedErrorMessage(AppLocalizations l10n, Object error) {
  if (error is AppException) {
    return error.localize(l10n);
  }
  if (error is ArgumentError ||
      error is FormatException ||
      error is TypeError) {
    return l10n.errorInvalidResponse;
  }
  return l10n.errorUnexpected;
}
