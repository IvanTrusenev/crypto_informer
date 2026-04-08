import 'package:flutter/material.dart';

/// Сообщение об ошибке по центру области с отступами (полноэкранный / body).
class CenteredErrorMessage extends StatelessWidget {
  const CenteredErrorMessage({
    required this.message,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final String message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
