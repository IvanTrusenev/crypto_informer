import 'package:crypto_informer/core/di/service_locator.dart';
import 'package:crypto_informer/core/localization/context_l10n.dart';
import 'package:crypto_informer/core/theme/context_theme.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

/// Текст «О программе» (экран настроек открывает это в диалоге).
class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  Future<int> _cachedCoinCount() async {
    final db = sl<Database>();
    final result =
        await db.rawQuery('SELECT COUNT(*) AS cnt FROM coin_detail_cache');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;

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
          l10n.aboutSectionOffline,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutOfflineBody,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.aboutSectionNetworking,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutNetworkingBody,
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
        const SizedBox(height: 24),
        Text(
          l10n.aboutSectionCache,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        FutureBuilder<int>(
          future: _cachedCoinCount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            return Text(
              l10n.aboutCacheCoins(snapshot.data ?? 0),
              style: theme.textTheme.bodyMedium,
            );
          },
        ),
      ],
    );
  }
}
