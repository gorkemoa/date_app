import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[INFO]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('[WARN]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (kDebugMode) {
      debugPrint('[ERROR]${tag != null ? '[$tag]' : ''} $message');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
    }
  }
}
