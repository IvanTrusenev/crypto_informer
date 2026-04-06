import 'package:crypto_informer/core/theme/finance_semantic_colors.dart';
import 'package:flutter/material.dart';

extension ContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);

  FinanceSemanticColors get financeColors => theme.financeSemantic;
}
