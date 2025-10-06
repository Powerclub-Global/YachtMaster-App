import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yacht_master/utils/app_logger.dart';

/// Secure storage service using platform-specific secure storage
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (KeyStore)
///
/// Use this for storing sensitive data like:
/// - Authentication tokens
/// - User credentials (if needed)
/// - Payment method tokens
/// - Encryption keys
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Store a value securely
  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      AppLogger.debug('Secure storage: wrote key $key');
    } catch (e, stack) {
      AppLogger.error('Failed to write to secure storage', e, stack);
      rethrow;
    }
  }

  /// Read a value from secure storage
  static Future<String?> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      AppLogger.debug('Secure storage: read key $key');
      return value;
    } catch (e, stack) {
      AppLogger.error('Failed to read from secure storage', e, stack);
      return null;
    }
  }

  /// Delete a value from secure storage
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      AppLogger.debug('Secure storage: deleted key $key');
    } catch (e, stack) {
      AppLogger.error('Failed to delete from secure storage', e, stack);
      rethrow;
    }
  }

  /// Check if a key exists
  static Future<bool> contains(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e, stack) {
      AppLogger.error('Failed to check secure storage', e, stack);
      return false;
    }
  }

  /// Delete all values
  static Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.warning('Secure storage: all data deleted');
    } catch (e, stack) {
      AppLogger.error('Failed to delete all from secure storage', e, stack);
      rethrow;
    }
  }

  /// Read all keys
  static Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e, stack) {
      AppLogger.error('Failed to read all from secure storage', e, stack);
      return {};
    }
  }

  // Common storage keys (to prevent typos)
  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyStripeCustomerId = 'stripe_customer_id';
  static const String keyDeviceId = 'device_id';
  static const String keyLastLoginTime = 'last_login_time';
  static const String keyBiometricEnabled = 'biometric_enabled';

  /// Helper: Store auth token
  static Future<void> saveAuthToken(String token) async {
    await write(keyAuthToken, token);
  }

  /// Helper: Get auth token
  static Future<String?> getAuthToken() async {
    return await read(keyAuthToken);
  }

  /// Helper: Clear auth token
  static Future<void> clearAuthToken() async {
    await delete(keyAuthToken);
  }

  /// Helper: Store user session
  static Future<void> saveUserSession({
    required String userId,
    required String authToken,
    String? refreshToken,
  }) async {
    await write(keyUserId, userId);
    await write(keyAuthToken, authToken);
    if (refreshToken != null) {
      await write(keyRefreshToken, refreshToken);
    }
    AppLogger.info('User session saved securely');
  }

  /// Helper: Clear user session
  static Future<void> clearUserSession() async {
    await delete(keyUserId);
    await delete(keyAuthToken);
    await delete(keyRefreshToken);
    AppLogger.info('User session cleared');
  }

  /// Helper: Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await read(keyAuthToken);
    return token != null && token.isNotEmpty;
  }
}
