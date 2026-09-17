import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) debugPrint('[ERROR] $error');
      if (stackTrace != null) debugPrint('[STACK] $stackTrace');
    }
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message — $error');
      if (stackTrace != null) debugPrint('[STACK] $stackTrace');
    } else {
      // Intégrer Crashlytics ou Sentry ici en production
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }
}
