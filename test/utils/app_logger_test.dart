import 'package:flutter_test/flutter_test.dart';
import 'package:yacht_master/utils/app_logger.dart';

void main() {
  group('AppLogger', () {
    setUp(() {
      AppLogger.initialize();
    });

    test('initialize should set up logger without errors', () {
      expect(() => AppLogger.initialize(), returnsNormally);
    });

    test('debug should log without errors', () {
      expect(() => AppLogger.debug('Test debug message'), returnsNormally);
    });

    test('info should log without errors', () {
      expect(() => AppLogger.info('Test info message'), returnsNormally);
    });

    test('warning should log without errors', () {
      expect(() => AppLogger.warning('Test warning message'), returnsNormally);
    });

    test('error should log without errors', () {
      expect(
        () => AppLogger.error('Test error message', Exception('Test exception')),
        returnsNormally,
      );
    });

    test('setCustomKey should work without errors', () {
      expect(() => AppLogger.setCustomKey('test_key', 'test_value'), returnsNormally);
    });

    test('breadcrumb should log without errors', () {
      expect(() => AppLogger.breadcrumb('Test breadcrumb'), returnsNormally);
    });
  });
}
