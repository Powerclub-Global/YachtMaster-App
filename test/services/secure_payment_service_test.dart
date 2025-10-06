import 'package:flutter_test/flutter_test.dart';
import 'package:yacht_master/services/secure_payment_service.dart';

void main() {
  group('SecurePaymentService', () {
    test('createPaymentIntent should require positive amount', () async {
      expect(
        () => SecurePaymentService.createPaymentIntent(
          amount: -10.0,
          currency: 'usd',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createPaymentIntent should require valid currency', () async {
      expect(
        () => SecurePaymentService.createPaymentIntent(
          amount: 100.0,
          currency: '',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createStripeCustomer should require email', () async {
      expect(
        () => SecurePaymentService.createStripeCustomer(
          email: '',
          name: 'Test User',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('createStripeCustomer should require name', () async {
      expect(
        () => SecurePaymentService.createStripeCustomer(
          email: 'test@example.com',
          name: '',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
