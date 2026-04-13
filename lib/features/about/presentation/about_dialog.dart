import 'package:crypto_informer/core/di/service_locator.dart';
import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/about/presentation/widgets/about_content.dart';
import 'package:crypto_informer/features/market/domain/usecases/get_cached_coin_detail_count_usecase.dart';
import 'package:flutter/material.dart';

Future<void> showAboutAppDialog(BuildContext context) {
  final l10n = context.l10n;
  final cachedCoinCountFuture = sl<GetCachedCoinDetailCountUseCase>()();

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.aboutTitle),
        content: SingleChildScrollView(
          child: AboutContent(cachedCoinCountFuture: cachedCoinCountFuture),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.dialogClose),
          ),
        ],
      );
    },
  );
}
