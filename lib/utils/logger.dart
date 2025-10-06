import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Production-safe logging utility
class AppLogger {
  static final Logger _logger = Logger('YachtMaster');

  static void init() {
    Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
      // In production, send to crashlytics or analytics
    });
  }

  static void debug(String message) {
    if (kDebugMode) {
      _logger.fine(message);
    }
  }

  static void info(String message) {
    _logger.info(message);
  }

  static void warning(String message) {
    _logger.warning(message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }
}