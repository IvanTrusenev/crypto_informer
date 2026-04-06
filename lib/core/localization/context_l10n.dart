import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension ContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
