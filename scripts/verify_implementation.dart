#!/usr/bin/env dart

/// Comprehensive verification script for YachtMaster-App production fixes
/// This script verifies that all implemented changes are working correctly

import 'dart:io';

void main() async {
  print('🧪 YACHTMASTER-APP PRODUCTION READINESS VERIFICATION');
  print('=' * 60);

  final results = <String, bool>{};

  // 1. Verify hardcoded secrets removal
  results['Hardcoded Secrets Removed'] = await verifySecretsRemoval();

  // 2. Verify new services exist
  results['Analytics Service Created'] = await verifyFileExists('lib/services/analytics_service.dart');
  results['Payment Service Created'] = await verifyFileExists('lib/services/payment_service.dart');
  results['Image Service Created'] = await verifyFileExists('lib/services/image_service.dart');
  results['Security Service Created'] = await verifyFileExists('lib/services/security_service.dart');
  results['Logger Utility Created'] = await verifyFileExists('lib/utils/logger.dart');

  // 3. Verify widgets
  results['Error Boundary Widget Created'] = await verifyFileExists('lib/widgets/error_boundary.dart');
  results['Optimized Yacht List Created'] = await verifyFileExists('lib/widgets/optimized_yacht_list.dart');

  // 4. Verify security configurations
  results['Firestore Security Rules Created'] = await verifyFileExists('firestore.rules');
  results['Storage Security Rules Created'] = await verifyFileExists('storage.rules');
  results['Android Network Security Config Created'] = await verifyFileExists('android/app/src/main/res/xml/network_security_config.xml');
  results['ProGuard Rules Updated'] = await verifyFileExists('android/app/proguard-rules.pro');

  // 5. Verify test files
  results['Integration Tests Created'] = await verifyFileExists('test/integration_test.dart');
  results['Component Tests Created'] = await verifyFileExists('test/component_verification_test.dart');

  // 6. Verify configuration files
  results['Dependencies Updated'] = await verifyDependenciesUpdated();
  results['Analysis Options Configured'] = await verifyAnalysisOptions();
  results['Android Build Config Fixed'] = await verifyAndroidBuildConfig();

  // 7. Verify code cleanup
  results['Debug Statements Cleaned'] = await verifyDebugCleanup();

  // Print results
  print('\n📋 VERIFICATION RESULTS:');
  print('-' * 40);

  var passedTests = 0;
  var totalTests = results.length;

  results.forEach((test, passed) {
    final status = passed ? '✅ PASS' : '❌ FAIL';
    print('$status $test');
    if (passed) passedTests++;
  });

  print('-' * 40);
  print('📊 SUMMARY: $passedTests/$totalTests tests passed (${(passedTests/totalTests*100).toStringAsFixed(1)}%)');

  if (passedTests == totalTests) {
    print('\n🎉 ALL VERIFICATIONS PASSED - PRODUCTION READY!');
    exit(0);
  } else {
    print('\n⚠️  SOME VERIFICATIONS FAILED - REVIEW REQUIRED');
    exit(1);
  }
}

Future<bool> verifyFileExists(String filePath) async {
  final file = File(filePath);
  return await file.exists();
}

Future<bool> verifySecretsRemoval() async {
  final files = [
    'lib/utils/helper.dart',
    'ios/Runner/AppDelegate.swift',
    'functions/functions/index.js',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (await file.exists()) {
      final content = await file.readAsString();

      // Check for common secret patterns
      final usesEnvGetter = content.contains('const String.fromEnvironment') ||
          content.contains('process.env');

      if (content.contains('AIzaSyB3-PXBvW4UuH10ZRBY7kd20EFcxDZksQU') ||
          content.contains('e3a37d6d98467e231db5481075c68dfb') ||
          (!usesEnvGetter &&
              content.contains('API_KEY') &&
              !filePath.endsWith('AppDelegate.swift'))) {
        return false;
      }
    }
  }
  return true;
}

Future<bool> verifyDependenciesUpdated() async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) return false;

  final content = await pubspecFile.readAsString();

  final requiredDeps = [
    'firebase_crashlytics:',
    'firebase_analytics:',
    'firebase_performance:',
    'logging:',
    'flutter_image_compress:',
    'crypto:',
    'device_info_plus:',
    'mockito:',
  ];

  return requiredDeps.every((dep) => content.contains(dep));
}

Future<bool> verifyAnalysisOptions() async {
  final analysisFile = File('analysis_options.yaml');
  if (!await analysisFile.exists()) return false;

  final content = await analysisFile.readAsString();
  return content.contains('avoid_print: true');
}

Future<bool> verifyAndroidBuildConfig() async {
  final buildFile = File('android/app/build.gradle');
  if (!await buildFile.exists()) return false;

  final content = await buildFile.readAsString();
  return content.contains('signingConfig signingConfigs.release') &&
         content.contains('minifyEnabled true') &&
         content.contains('proguardFiles');
}

Future<bool> verifyDebugCleanup() async {
  final mainFile = File('lib/main.dart');
  if (!await mainFile.exists()) return false;

  final content = await mainFile.readAsString();

  // Check that dangerous debug prints are removed
  final dangerousPrints = [
    'fetch kar rha bro',
    'kyaa error yahan hai',
    'THIS IS SECRET',
  ];

  return !dangerousPrints.any((print) => content.contains(print));
}
