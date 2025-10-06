import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Centralized application logger
/// Replaces print() statements with structured logging
/// Automatically sends errors to Crashlytics in production
class AppLogger {
  static final Logger _logger = Logger('YachtMaster');
  static bool _initialized = false;

  /// Initialize the logger
  static void initialize() {
    if (_initialized) return;

    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      final message = '${record.level.name}: ${record.time}: ${record.message}';

      // In debug mode, use developer.log for better IDE integration
      if (kDebugMode) {
        developer.log(
          record.message,
          time: record.time,
          level: record.level.value,
          name: record.loggerName,
          error: record.error,
          stackTrace: record.stackTrace,
        );
      }

      // In release mode, only log warnings and errors
      if (kReleaseMode && record.level >= Level.WARNING) {
        developer.log(message);
      }

      // Send errors to Crashlytics
      if (record.level >= Level.SEVERE && record.error != null) {
        FirebaseCrashlytics.instance.recordError(
          record.error,
          record.stackTrace,
          reason: record.message,
          fatal: false,
        );
      }
    });

    _initialized = true;
  }

  /// Log debug message (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_initialized) initialize();
    _logger.fine(message, error, stackTrace);
  }

  /// Log info message
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_initialized) initialize();
    _logger.info(message, error, stackTrace);
  }

  /// Log warning message
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_initialized) initialize();
    _logger.warning(message, error, stackTrace);
  }

  /// Log error message (sent to Crashlytics)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_initialized) initialize();
    _logger.severe(message, error, stackTrace);
  }

  /// Log critical error (sent to Crashlytics as fatal)
  static void fatal(String message, Object error, [StackTrace? stackTrace]) {
    if (!_initialized) initialize();
    _logger.shout(message, error, stackTrace);
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace ?? StackTrace.current,
      reason: message,
      fatal: true,
    );
  }

  /// Set custom key for Crashlytics
  static void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Set user identifier for Crashlytics
  static void setUserId(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Log breadcrumb for debugging
  static void breadcrumb(String message) {
    if (!_initialized) initialize();
    FirebaseCrashlytics.instance.log(message);
    if (kDebugMode) {
      _logger.config(message);
    }
  }
}
