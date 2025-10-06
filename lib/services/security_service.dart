import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Security service for runtime security checks
class SecurityService {
  static bool _initialized = false;
  static bool _isSecure = true;

  /// Initialize security checks
  static Future<void> initialize() async {
    if (_initialized) return;

    await _performSecurityChecks();
    _initialized = true;
  }

  /// Perform runtime security checks
  static Future<void> _performSecurityChecks() async {
    final checks = await Future.wait([
      _checkDebugMode(),
      _checkRootedDevice(),
      _checkEmulator(),
      _checkTampered(),
    ]);

    _isSecure = checks.every((check) => check);

    if (!_isSecure && kReleaseMode) {
      // In production, we might want to limit functionality
      // or show security warnings
    }
  }

  /// Check if app is running in debug mode
  static Future<bool> _checkDebugMode() async {
    return !kDebugMode;
  }

  /// Check if device is rooted/jailbroken
  static Future<bool> _checkRootedDevice() async {
    if (Platform.isAndroid) {
      return await _checkAndroidRoot();
    } else if (Platform.isIOS) {
      return await _checkIOSJailbreak();
    }
    return true;
  }

  /// Check Android root status
  static Future<bool> _checkAndroidRoot() async {
    try {
      // Check for common root files
      final rootPaths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
      ];

      for (final path in rootPaths) {
        if (await File(path).exists()) {
          return false; // Device is rooted
        }
      }

      return true; // Not rooted
    } catch (e) {
      return true; // Assume not rooted if check fails
    }
  }

  /// Check iOS jailbreak status
  static Future<bool> _checkIOSJailbreak() async {
    try {
      // Check for common jailbreak files
      final jailbreakPaths = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
      ];

      for (final path in jailbreakPaths) {
        if (await File(path).exists()) {
          return false; // Device is jailbroken
        }
      }

      return true; // Not jailbroken
    } catch (e) {
      return true; // Assume not jailbroken if check fails
    }
  }

  /// Check if running on emulator
  static Future<bool> _checkEmulator() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return !_isAndroidEmulator(androidInfo);
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice == true;
      }

      return true;
    } catch (e) {
      return true; // Assume physical device if check fails
    }
  }

  /// Check if Android device is emulator
  static bool _isAndroidEmulator(AndroidDeviceInfo androidInfo) {
    return androidInfo.isPhysicalDevice == false ||
        androidInfo.fingerprint.startsWith('generic') ||
        androidInfo.fingerprint.toLowerCase().contains('vbox') ||
        androidInfo.fingerprint.toLowerCase().contains('test-keys') ||
        androidInfo.model.contains('google_sdk') ||
        androidInfo.model.contains('Emulator') ||
        androidInfo.model.contains('Android SDK built for x86') ||
        androidInfo.manufacturer.contains('Genymotion') ||
        androidInfo.brand.startsWith('generic') && androidInfo.device.startsWith('generic') ||
        'google_sdk' == androidInfo.product;
  }

  /// Check if app has been tampered with
  static Future<bool> _checkTampered() async {
    // In a real implementation, you would check app signature
    // This is a simplified version
    return true;
  }

  /// Generate secure request signature
  static String generateRequestSignature(String data, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(data);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  /// Validate request signature
  static bool validateRequestSignature(String data, String signature, String secret) {
    final expectedSignature = generateRequestSignature(data, secret);
    return signature == expectedSignature;
  }

  /// Get security status
  static bool get isSecure => _isSecure;

  /// Get device fingerprint for fraud detection
  static Future<String> getDeviceFingerprint() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String fingerprint = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        fingerprint = '${androidInfo.id}_${androidInfo.model}_${androidInfo.brand}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        fingerprint = '${iosInfo.identifierForVendor}_${iosInfo.model}_${iosInfo.systemVersion}';
      }

      // Hash the fingerprint for privacy
      final bytes = utf8.encode(fingerprint);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      return 'unknown';
    }
  }

  /// Sign sensitive data for storage (NOT encryption - use for integrity checking)
  /// For true encryption, use flutter_secure_storage or encrypt package
  /// This method only provides data integrity, not confidentiality
  static String signData(String data, String key) {
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final hmacSha256 = Hmac(sha256, keyBytes);
    final digest = hmacSha256.convert(bytes);
    return base64Encode(bytes) + '.' + digest.toString();
  }

  /// Verify and decode signed data
  /// Returns null if signature is invalid
  static String? verifySignedData(String signedData, String key) {
    try {
      final parts = signedData.split('.');
      if (parts.length != 2) return null;

      final data = base64Decode(parts[0]);
      final signature = parts[1];

      // Verify signature
      final keyBytes = utf8.encode(key);
      final hmacSha256 = Hmac(sha256, keyBytes);
      final expectedSignature = hmacSha256.convert(data).toString();

      if (signature != expectedSignature) return null;

      return utf8.decode(data);
    } catch (e) {
      return null;
    }
  }

  /// DEPRECATED: Use signData instead
  @Deprecated('This is not encryption. Use signData() for integrity or flutter_secure_storage for encryption')
  static String encryptData(String data, String key) => signData(data, key);

  /// DEPRECATED: Use verifySignedData instead
  @Deprecated('This is not decryption. Use verifySignedData() for verification or flutter_secure_storage for decryption')
  static String? decryptData(String encryptedData, String key) => verifySignedData(encryptedData, key);
}
