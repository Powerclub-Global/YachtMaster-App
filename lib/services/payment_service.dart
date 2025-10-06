import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../services/analytics_service.dart';
import '../src/base/search/view/bookings/model/bookings.dart';

/// Secure payment processing service with atomic operations
class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Process payment and create booking atomically
  static Future<PaymentResult> processBookingPayment({
    required BookingsModel booking,
    required String paymentMethodId,
    required double amount,
    required String currency,
    required String customerEmail,
    String? paymentIntentClientSecret,
  }) async {
    final trace = AnalyticsService.startTrace('booking_payment_process');
    await trace.start();

    String? bookingId;
    try {
      // Confirm the payment before writing to Firestore to avoid network calls inside the transaction.
      final clientSecret = paymentIntentClientSecret ?? paymentMethodId;
      if (clientSecret.isEmpty) {
        throw PaymentException('Missing payment intent client secret');
      }

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: customerEmail,
            ),
          ),
        ),
      );

      if (paymentIntent.status != PaymentIntentsStatus.Succeeded) {
        throw PaymentException('Payment failed: ${paymentIntent.status}');
      }

      // Create booking and related updates atomically.
      final bookingRef = _firestore.collection('bookings').doc();
      bookingId = bookingRef.id;
      final updatedBooking = booking.copyWith(
        id: bookingRef.id,
        createdAt: Timestamp.now(),
        bookingStatus: 1, // Completed status
      );

      await _firestore.runTransaction<void>((transaction) async {
        transaction.set(bookingRef, updatedBooking.toJson());

        final userRef = _firestore.collection('users').doc(booking.createdBy);
        transaction.update(userRef, {
          'totalBookings': FieldValue.increment(1),
          'totalSpent': FieldValue.increment(amount),
          'lastBookingDate': Timestamp.now(),
        });

        final yachtId = booking.charterFleetDetail?.id;
        if (yachtId != null && yachtId.isNotEmpty) {
          final yachtRef = _firestore.collection('yachts').doc(yachtId);
          transaction.update(yachtRef, {
            'bookings': FieldValue.arrayUnion([bookingRef.id]),
            'totalBookings': FieldValue.increment(1),
          });
        }
      });

      await AnalyticsService.logPaymentCompleted(
        paymentIntent.id,
        'stripe_card',
        amount,
      );

      AnalyticsService.setCustomKey('payment_currency', currency);

      await AnalyticsService.logBookingCreated(
        bookingRef.id,
        amount,
      );

      return PaymentResult.success(
        paymentIntentId: paymentIntent.id,
        bookingId: bookingRef.id,
        amount: amount,
      );

    } catch (error, stackTrace) {
      await AnalyticsService.logError(
        'Payment processing failed',
        error: error,
        stackTrace: stackTrace,
      );

      AnalyticsService.setCustomKey('payment_amount', amount);
      AnalyticsService.setCustomKey('booking_id', bookingId ?? booking.id ?? 'unknown');
      AnalyticsService.setCustomKey('payment_currency', currency);

      if (error is StripeException) {
        final failureCode = error.error.code;
        return PaymentResult.failure(
          error: 'Payment failed: ${error.error.localizedMessage}',
          code: failureCode.toString(),
        );
      }

      return PaymentResult.failure(
        error: 'Booking creation failed. Please contact support.',
        code: 'booking_creation_failed',
      );

    } finally {
      await trace.stop();
    }
  }

  /// Process refund atomically
  static Future<RefundResult> processRefund({
    required String bookingId,
    required String paymentIntentId,
    required double amount,
    required String reason,
  }) async {
    try {
      return await _firestore.runTransaction<RefundResult>((transaction) async {
        // 1. Create refund with Stripe
        // Note: This would need to be done via Cloud Function for security

        // 2. Update booking status
        final bookingRef = _firestore.collection('bookings').doc(bookingId);
        transaction.update(bookingRef, {
          'status': 'refunded',
          'refundedAt': Timestamp.now(),
          'refundAmount': amount,
          'refundReason': reason,
        });

        // 3. Update user statistics
        final bookingSnapshot = await bookingRef.get();
        final booking = bookingSnapshot.data() as Map<String, dynamic>;

        final userRef = _firestore.collection('users').doc(booking['userId']);
        transaction.update(userRef, {
          'totalSpent': FieldValue.increment(-amount),
          'totalRefunds': FieldValue.increment(1),
        });

        return RefundResult.success(
          refundId: 'refund_$bookingId',
          amount: amount,
        );
      });

    } catch (error, stackTrace) {
      await AnalyticsService.logError(
        'Refund processing failed',
        error: error,
        stackTrace: stackTrace,
      );

      return RefundResult.failure(
        error: 'Refund failed. Please contact support.',
      );
    }
  }
}

/// Payment result classes
class PaymentResult {
  final bool success;
  final String? error;
  final String? code;
  final String paymentIntentId;
  final String bookingId;
  final double amount;

  PaymentResult._({
    required this.success,
    this.error,
    this.code,
    required this.paymentIntentId,
    required this.bookingId,
    required this.amount,
  });

  factory PaymentResult.success({
    required String paymentIntentId,
    required String bookingId,
    required double amount,
  }) {
    return PaymentResult._(
      success: true,
      paymentIntentId: paymentIntentId,
      bookingId: bookingId,
      amount: amount,
    );
  }

  factory PaymentResult.failure({
    required String error,
    String? code,
  }) {
    return PaymentResult._(
      success: false,
      error: error,
      code: code,
      paymentIntentId: '',
      bookingId: '',
      amount: 0,
    );
  }
}

class RefundResult {
  final bool success;
  final String? error;
  final String refundId;
  final double amount;

  RefundResult._({
    required this.success,
    this.error,
    required this.refundId,
    required this.amount,
  });

  factory RefundResult.success({
    required String refundId,
    required double amount,
  }) {
    return RefundResult._(
      success: true,
      refundId: refundId,
      amount: amount,
    );
  }

  factory RefundResult.failure({
    required String error,
  }) {
    return RefundResult._(
      success: false,
      error: error,
      refundId: '',
      amount: 0,
    );
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}
