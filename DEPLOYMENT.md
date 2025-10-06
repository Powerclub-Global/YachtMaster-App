# YachtMaster-App Deployment Guide

## Overview
This guide covers deploying the YachtMaster application to production environments.

## Prerequisites

### Required Tools
- Flutter SDK 3.29.3+
- Node.js 20+ (for Firebase Functions)
- Firebase CLI
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

### Required Accounts
- Firebase project (with Firestore, Authentication, Storage, Functions)
- Stripe account (publishable and secret keys)
- Appwrite account
- Apple Developer account (for iOS)
- Google Play Console account (for Android)

---

## Environment Setup

### 1. Firebase Configuration

#### Firebase Remote Config
Set the following keys in Firebase Remote Config:

```
publishable_key: <your-stripe-publishable-key>
```

**IMPORTANT**: Never put `secret_key` or `connect_key` in Remote Config. These are now managed server-side.

#### Firebase Functions Environment Variables
```bash
cd functions/functions
firebase functions:config:set stripe.secret_key="sk_live_..."
firebase functions:config:set stripe.connect_key="..."
firebase functions:config:set appwrite.endpoint="https://cloud.appwrite.io/v1"
firebase functions:config:set appwrite.project_id="..."
firebase functions:config:set appwrite.api_key="..."
```

### 2. Android Configuration

#### Keystore Setup
1. Generate release keystore:
```bash
keytool -genkey -v -keystore ~/yacht-master-release.keystore \
  -alias yacht-master -keyalg RSA -keysize 2048 -validity 10000
```

2. Set environment variables or create `key.properties`:
```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=yacht-master
storeFile=<path-to-keystore>
```

#### Google Services
- Place `google-services.json` in `android/app/`

### 3. iOS Configuration

#### Certificates & Provisioning Profiles
1. Create App ID in Apple Developer Portal
2. Generate Distribution Certificate
3. Create Provisioning Profiles
4. Place `GoogleService-Info.plist` in `ios/Runner/`

---

## Deployment Process

### Deploy Firebase Functions

```bash
cd functions/functions
npm install
firebase deploy --only functions
```

### Build Android Release

```bash
# Build release APK
flutter build apk --release

# Or build App Bundle for Play Store
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build iOS Release

```bash
# Build for App Store
flutter build ipa --release

# Or build without codesigning for Firebase App Distribution
flutter build ios --release --no-codesign
```

Output: `build/ios/iphoneos/Runner.app`

---

## CI/CD with GitHub Actions

### Required Secrets

Add these secrets to your GitHub repository:

```
FIREBASE_SERVICE_ACCOUNT: <firebase-service-account-json>
FIREBASE_ANDROID_APP_ID: <android-app-id>
FIREBASE_IOS_APP_ID: <ios-app-id>
ANDROID_KEYSTORE_BASE64: <base64-encoded-keystore>
ANDROID_KEY_PROPERTIES: <key.properties-content>
```

### Automated Workflows

1. **On every push/PR**: Runs tests, linting, and builds
2. **On tag push (`v*`)**: Deploys to Firebase App Distribution
3. **Security scanning**: Runs on every push

### Create Release

```bash
git tag v1.3.7
git push origin v1.3.7
```

This triggers automated build and deployment.

---

## Environment Variables

### Firebase Functions
Managed via `firebase functions:config:set`

### Flutter App
Uses Firebase Remote Config for runtime configuration.

---

## Monitoring & Logging

### Crashlytics
- Errors automatically reported to Firebase Crashlytics
- View crash reports: Firebase Console → Crashlytics

### Analytics
- User events tracked via Firebase Analytics
- Custom events via `AppLogger.breadcrumb()`

### Performance
- Firebase Performance Monitoring enabled
- View metrics: Firebase Console → Performance

---

## Rollback Strategy

### Functions Rollback
```bash
firebase functions:rollback <function-name> <deployment-id>
```

### App Rollback
1. App Store/Play Store: Remove latest version
2. Firebase App Distribution: Distribute previous build
3. Notify users to downgrade if necessary

---

## Security Checklist

- [ ] Stripe secret keys NOT in Flutter app
- [ ] Firebase Remote Config does NOT contain secret keys
- [ ] Keystore password in environment variables (not git)
- [ ] ProGuard/R8 enabled for Android release builds
- [ ] Code obfuscation enabled (`--obfuscate`)
- [ ] Firebase Security Rules reviewed and tested
- [ ] SSL pinning considered (future enhancement)

---

## Troubleshooting

### Build Failures

**Issue**: Android build fails with keystore error
**Solution**: Verify `STORE_FILE`, `STORE_PASSWORD`, etc. are set

**Issue**: iOS build fails with provisioning profile error
**Solution**: Run `flutter clean` and rebuild

### Runtime Issues

**Issue**: Stripe payments fail
**Solution**: Verify Firebase Functions deployed and `publishable_key` in Remote Config

**Issue**: Crashlytics not receiving crashes
**Solution**: Ensure `AppLogger.initialize()` called in `main()`

---

## Support

For deployment issues, contact:
- DevOps Lead: [email]
- Firebase Admin: [email]

## Additional Resources

- [Firebase Console](https://console.firebase.google.com)
- [Stripe Dashboard](https://dashboard.stripe.com)
- [GitHub Actions](https://github.com/Powerclub-Global/YachtMaster-App/actions)
