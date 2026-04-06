import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:crypto_informer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Текст «О программе» (экран настроек открывает это в диалоге).
class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.aboutHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutTagline,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.aboutSectionArchitecture,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutArchitectureBulletList,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.aboutSectionData,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutDataBody,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
