import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Centralized analytics and monitoring service
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Initialize analytics service
  static Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
    await _performance.setPerformanceCollectionEnabled(!kDebugMode);
  }

  /// Set user properties
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  /// Log user events
  static Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Log business events
  static Future<void> logBookingCreated(String bookingId, double amount) async {
    await logEvent('booking_created', parameters: {
      'booking_id': bookingId,
      'amount': amount,
      'currency': 'USD',
    });
  }

  static Future<void> logPaymentCompleted(String paymentId, String method, double amount) async {
    await logEvent('payment_completed', parameters: {
      'payment_id': paymentId,
      'payment_method': method,
      'amount': amount,
    });
  }

  static Future<void> logUserRegistration(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Error logging
  static Future<void> logError(String message, {Object? error, StackTrace? stackTrace}) async {
    await _crashlytics.log(message);
    if (error != null) {
      await _crashlytics.recordError(error, stackTrace);
    }
  }

  static Future<void> logCustomError(String reason, {Map<String, dynamic>? customData}) async {
    if (customData != null) {
      customData.forEach((key, value) {
        _crashlytics.setCustomKey(key, value);
      });
    }
    await _crashlytics.recordError(Exception(reason), null);
  }

  /// Performance monitoring
  static Trace startTrace(String name) {
    return _performance.newTrace(name);
  }

  static Future<void> logNetworkRequest(String url, String method, int statusCode, int responseSize) async {
    final httpMetric = _performance.newHttpMetric(url, HttpMethod.values.firstWhere(
      (m) => m.name.toUpperCase() == method.toUpperCase(),
      orElse: () => HttpMethod.Get,
    ));

    httpMetric.responseContentType = 'application/json';
    httpMetric.httpResponseCode = statusCode;
    httpMetric.responsePayloadSize = responseSize;

    await httpMetric.start();
    await httpMetric.stop();
  }

  /// Set custom crash keys for debugging
  static void setCustomKey(String key, dynamic value) {
    _crashlytics.setCustomKey(key, value);
  }

  /// Log breadcrumb for crash investigation
  static void addBreadcrumb(String message, {String? category}) {
    _crashlytics.log('${category ?? 'INFO'}: $message');
  }
}