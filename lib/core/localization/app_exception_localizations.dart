import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';

extension AppExceptionLocalizations on AppException {
  String localize(AppLocalizations l10n) {
    return switch (code) {
      AppErrorCode.emptyResponse => l10n.errorEmptyResponse,
      AppErrorCode.coinNotFound => l10n.errorCoinNotFound,
      AppErrorCode.timeout => l10n.errorTimeout,
      AppErrorCode.serverError => l10n.errorServer(statusCode ?? 0),
      AppErrorCode.network => l10n.errorNetwork,
    };
  }
}

/// Локализованное сообщение для любого [Object] из провайдера/ошибки.
String localizedErrorMessage(AppLocalizations l10n, Object error) {
  if (error is AppException) {
    return error.localize(l10n);
  }
  return l10n.errorUnexpected;
}
