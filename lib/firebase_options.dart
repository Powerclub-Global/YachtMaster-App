// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAMsdps8YdyQemF6d7bDHydjY98dPpVB0I',
    appId: '1:634115072396:web:81059a7f61d6577a5536a9',
    messagingSenderId: '634115072396',
    projectId: 'yacht-masters',
    authDomain: 'yacht-masters.firebaseapp.com',
    storageBucket: 'yacht-masters.appspot.com',
    measurementId: 'G-MFSD0MFPHK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8wiHcK_W_HwT2fH72V3AgrDYt1aivmas',
    appId: '1:634115072396:android:4f3cdf3826df28515536a9',
    messagingSenderId: '634115072396',
    projectId: 'yacht-masters',
    storageBucket: 'yacht-masters.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0RnjWU-zEfUJ8dlvlWJL9PPsIvJhIozk',
    appId: '1:634115072396:ios:f497e701fa1240ff5536a9',
    messagingSenderId: '634115072396',
    projectId: 'yacht-masters',
    storageBucket: 'yacht-masters.appspot.com',
    androidClientId: '634115072396-593oj377bt8718rl21dt3v9eg7vtjidd.apps.googleusercontent.com',
    iosClientId: '634115072396-0m1ak1a04pql1126mkcq0c6j2cc2h1u5.apps.googleusercontent.com',
    iosBundleId: 'com.yachtmaster.app',
  );
}
