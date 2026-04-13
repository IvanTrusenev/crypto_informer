import 'package:flutter/foundation.dart';

/// Отладочные логи с единым префиксом для фильтрации в debug console.
final class AppDebugLog {
  const AppDebugLog._();

  static void info(
    String signature, {
    String? message,
    Map<String, Object?> context = const {},
  }) {
    if (!kDebugMode) return;
    debugPrint(_formatLine(signature, message: message, context: context));
  }

  static void error(
    String signature, {
    required Object error,
    StackTrace? stackTrace,
    String? message,
    Map<String, Object?> context = const {},
  }) {
    if (!kDebugMode) return;

    final errorContext = <String, Object?>{
      ...context,
      'errorType': error.runtimeType,
      'error': error.toString(),
    };

    debugPrint(_formatLine(signature, message: message, context: errorContext));
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static String _formatLine(
    String signature, {
    required Map<String, Object?> context,
    String? message,
  }) {
    final buffer = StringBuffer()..write('[CI-DIAG][$signature]');
    if (message != null && message.isNotEmpty) {
      buffer.write(' $message');
    }
    if (context.isNotEmpty) {
      buffer
        ..write(' | ')
        ..write(
        context.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join(', '),
      );
    }
    return buffer.toString();
  }
}
