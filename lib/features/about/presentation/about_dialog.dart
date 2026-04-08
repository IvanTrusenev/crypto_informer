import 'package:crypto_informer/core/extensions/context_extensions.dart';
import 'package:crypto_informer/features/about/presentation/widgets/about_content.dart';
import 'package:flutter/material.dart';

Future<void> showAboutAppDialog(BuildContext context) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.aboutTitle),
        content: const SingleChildScrollView(
          child: AboutContent(),
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
