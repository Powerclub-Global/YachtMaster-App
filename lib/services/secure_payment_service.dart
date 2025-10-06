import 'dart:developer';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Secure payment service that calls backend Cloud Functions
/// Never exposes secret keys to the client
class SecurePaymentService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Create a payment intent via secure backend
  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call({
        'amount': amount,
        'currency': currency,
        'customerId': customerId,
        'metadata': metadata,
      });

      return {
        'clientSecret': result.data['clientSecret'],
        'paymentIntentId': result.data['paymentIntentId'],
      };
    } catch (e, stack) {
      log('Failed to create payment intent', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Create Stripe customer via secure backend
  static Future<String> createStripeCustomer({
    required String email,
    required String name,
  }) async {
    try {
      final callable = _functions.httpsCallable('createStripeCustomer');
      final result = await callable.call({
        'email': email,
        'name': name,
      });

      return result.data['customerId'] as String;
    } catch (e, stack) {
      log('Failed to create Stripe customer', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Create setup intent for saving payment methods
  static Future<Map<String, dynamic>> createSetupIntent({
    required String customerId,
  }) async {
    try {
      final callable = _functions.httpsCallable('createSetupIntent');
      final result = await callable.call({
        'customerId': customerId,
      });

      return {
        'clientSecret': result.data['clientSecret'],
        'setupIntentId': result.data['setupIntentId'],
      };
    } catch (e, stack) {
      log('Failed to create setup intent', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Attach payment method to customer
  static Future<String> attachPaymentMethod({
    required String paymentMethodId,
    required String customerId,
  }) async {
    try {
      final callable = _functions.httpsCallable('attachPaymentMethod');
      final result = await callable.call({
        'paymentMethodId': paymentMethodId,
        'customerId': customerId,
      });

      return result.data['paymentMethodId'] as String;
    } catch (e, stack) {
      log('Failed to attach payment method', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Create transfer to connected account (for host payouts)
  static Future<String> createConnectTransfer({
    required double amount,
    required String connectedAccountId,
    String? transferGroup,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final callable = _functions.httpsCallable('createConnectTransfer');
      final result = await callable.call({
        'amount': amount,
        'connectedAccountId': connectedAccountId,
        'transferGroup': transferGroup,
        'metadata': metadata,
      });

      return result.data['transferId'] as String;
    } catch (e, stack) {
      log('Failed to create connect transfer', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Confirm payment intent
  static Future<String> confirmPaymentIntent({
    required String paymentIntentId,
  }) async {
    try {
      final callable = _functions.httpsCallable('confirmPaymentIntent');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
      });

      return result.data['status'] as String;
    } catch (e, stack) {
      log('Failed to confirm payment intent', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Get payment intent status
  static Future<Map<String, dynamic>> getPaymentIntent({
    required String paymentIntentId,
  }) async {
    try {
      final callable = _functions.httpsCallable('getPaymentIntent');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
      });

      return {
        'status': result.data['status'],
        'amount': result.data['amount'],
        'currency': result.data['currency'],
      };
    } catch (e, stack) {
      log('Failed to get payment intent', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }

  /// Create refund
  static Future<Map<String, dynamic>> createRefund({
    required String paymentIntentId,
    double? amount,
    String? reason,
  }) async {
    try {
      final callable = _functions.httpsCallable('createRefund');
      final result = await callable.call({
        'paymentIntentId': paymentIntentId,
        'amount': amount,
        'reason': reason,
      });

      return {
        'refundId': result.data['refundId'],
        'status': result.data['status'],
      };
    } catch (e, stack) {
      log('Failed to create refund', error: e, stackTrace: stack);
      await FirebaseCrashlytics.instance.recordError(e, stack, fatal: false);
      rethrow;
    }
  }
}
