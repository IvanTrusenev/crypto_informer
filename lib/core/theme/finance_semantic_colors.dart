import 'package:flutter/material.dart';

/// Семантика изменения цены: падение через `ColorScheme.error` из темы.
@immutable
class FinanceSemanticColors extends ThemeExtension<FinanceSemanticColors> {
  const FinanceSemanticColors({
    required this.pricePositive,
    required this.priceNegative,
  });

  factory FinanceSemanticColors.fromScheme(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    return FinanceSemanticColors(
      priceNegative: scheme.error,
      pricePositive: isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32),
    );
  }

  final Color pricePositive;
  final Color priceNegative;

  @override
  FinanceSemanticColors copyWith({
    Color? pricePositive,
    Color? priceNegative,
  }) {
    return FinanceSemanticColors(
      pricePositive: pricePositive ?? this.pricePositive,
      priceNegative: priceNegative ?? this.priceNegative,
    );
  }

  @override
  FinanceSemanticColors lerp(
    ThemeExtension<FinanceSemanticColors>? other,
    double t,
  ) {
    if (other is! FinanceSemanticColors) {
      return this;
    }
    return FinanceSemanticColors(
      pricePositive: Color.lerp(pricePositive, other.pricePositive, t)!,
      priceNegative: Color.lerp(priceNegative, other.priceNegative, t)!,
    );
  }
}

extension ThemeFinanceSemantic on ThemeData {
  FinanceSemanticColors get financeSemantic {
    return extension<FinanceSemanticColors>() ??
        FinanceSemanticColors.fromScheme(colorScheme);
  }
}
