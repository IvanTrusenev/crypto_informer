import 'package:flutter/material.dart';

/// Подпись «Сортировка» и дочерний контрол в рамке как у поля ввода.
class MarketSortSection extends StatelessWidget {
  const MarketSortSection({
    required this.title,
    required this.fillHeight,
    required this.child,
    super.key,
  });

  final String title;
  final bool fillHeight;
  final Widget child;

  static OutlineInputBorder _resolveOutlineBorder(ThemeData theme) {
    final border =
        theme.inputDecorationTheme.enabledBorder ??
        theme.inputDecorationTheme.border;
    if (border is OutlineInputBorder) return border;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.outline),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final inputTheme = theme.inputDecorationTheme;
    final outlineBorder = _resolveOutlineBorder(theme);

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 88),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: child),
        ],
      ),
    );

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: inputTheme.fillColor ?? scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: outlineBorder.borderRadius,
          side: outlineBorder.borderSide,
        ),
      ),
      child: fillHeight ? SizedBox.expand(child: Center(child: inner)) : inner,
    );
  }
}
