import 'package:flutter/material.dart';

extension ContextTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
}
