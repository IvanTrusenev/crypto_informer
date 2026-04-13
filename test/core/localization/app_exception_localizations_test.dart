import 'package:crypto_informer/core/error/app_exception.dart';
import 'package:crypto_informer/core/localization/app_exception_localizations.dart';
import 'package:crypto_informer/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('maps AppException to localized message', () {
    expect(
      localizedErrorMessage(l10n, const ResponseParsingException()),
      l10n.errorInvalidResponse,
    );
  });

  test('maps raw parsing-related errors to invalid response message', () {
    expect(
      localizedErrorMessage(l10n, ArgumentError('bad shape')),
      l10n.errorInvalidResponse,
    );
    expect(
      localizedErrorMessage(l10n, const FormatException('bad format')),
      l10n.errorInvalidResponse,
    );
  });

  test('keeps generic fallback for unknown objects', () {
    expect(
      localizedErrorMessage(l10n, Object()),
      l10n.errorUnexpected,
    );
  });
}
