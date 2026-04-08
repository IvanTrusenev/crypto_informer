import 'package:flutter/material.dart';

/// Сообщение об ошибке по центру и кнопка повтора (полноэкранный / body).
class CenteredErrorWithRetry extends StatelessWidget {
  const CenteredErrorWithRetry({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
