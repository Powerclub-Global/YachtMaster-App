import 'package:flutter_test/flutter_test.dart';
import 'package:yacht_master/services/security_service.dart';

void main() {
  group('SecurityService', () {
    group('Request Signature', () {
      test('generateRequestSignature should create consistent signature', () {
        const data = 'test data';
        const secret = 'test secret';

        final signature1 = SecurityService.generateRequestSignature(data, secret);
        final signature2 = SecurityService.generateRequestSignature(data, secret);

        expect(signature1, equals(signature2));
      });

      test('generateRequestSignature should create different signatures for different data', () {
        const secret = 'test secret';

        final signature1 = SecurityService.generateRequestSignature('data1', secret);
        final signature2 = SecurityService.generateRequestSignature('data2', secret);

        expect(signature1, isNot(equals(signature2)));
      });

      test('validateRequestSignature should validate correct signature', () {
        const data = 'test data';
        const secret = 'test secret';

        final signature = SecurityService.generateRequestSignature(data, secret);
        final isValid = SecurityService.validateRequestSignature(data, signature, secret);

        expect(isValid, isTrue);
      });

      test('validateRequestSignature should reject invalid signature', () {
        const data = 'test data';
        const secret = 'test secret';
        const fakeSignature = 'fake signature';

        final isValid = SecurityService.validateRequestSignature(data, fakeSignature, secret);

        expect(isValid, isFalse);
      });
    });

    group('Data Signing', () {
      test('signData should create signed data with signature', () {
        const data = 'test data';
        const key = 'test key';

        final signed = SecurityService.signData(data, key);

        expect(signed, contains('.'));
        final parts = signed.split('.');
        expect(parts.length, equals(2));
      });

      test('verifySignedData should verify valid signed data', () {
        const data = 'test data';
        const key = 'test key';

        final signed = SecurityService.signData(data, key);
        final verified = SecurityService.verifySignedData(signed, key);

        expect(verified, equals(data));
      });

      test('verifySignedData should reject tampered data', () {
        const data = 'test data';
        const key = 'test key';

        final signed = SecurityService.signData(data, key);
        final tampered = signed.replaceFirst('test', 'fake');
        final verified = SecurityService.verifySignedData(tampered, key);

        expect(verified, isNull);
      });

      test('verifySignedData should reject data with wrong key', () {
        const data = 'test data';
        const key1 = 'test key 1';
        const key2 = 'test key 2';

        final signed = SecurityService.signData(data, key1);
        final verified = SecurityService.verifySignedData(signed, key2);

        expect(verified, isNull);
      });
    });

    group('Device Fingerprint', () {
      test('getDeviceFingerprint should return non-empty string', () async {
        final fingerprint = await SecurityService.getDeviceFingerprint();

        expect(fingerprint, isNotEmpty);
      });

      test('getDeviceFingerprint should be consistent', () async {
        final fingerprint1 = await SecurityService.getDeviceFingerprint();
        final fingerprint2 = await SecurityService.getDeviceFingerprint();

        expect(fingerprint1, equals(fingerprint2));
      });
    });
  });
}
