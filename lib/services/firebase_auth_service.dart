import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:developer';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Verification ID for phone auth
  String? _verificationId;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Check if phone is verified
  bool get isPhoneVerified => _auth.currentUser?.phoneNumber != null;

  // Get user email
  String get userEmail => _auth.currentUser?.email ?? '';

  // Get user name
  String get userName => _auth.currentUser?.displayName ?? '';

  // Get user phone number
  String get userPhoneNumber => _auth.currentUser?.phoneNumber ?? '';

  // Initialize Firebase Auth
  void initialize() {
    print("Firebase Auth initialized");
  }

  // Send OTP to phone number
  Future<void> sendOTP(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(PhoneAuthCredential)? onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          log("Auto verification completed");
          if (onAutoVerify != null) {
            onAutoVerify(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          log("Verification failed: ${e.message}");
          onError(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          log("Code sent to $phoneNumber");
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          log("Auto retrieval timeout");
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      log("sendOTP error: $e");
      onError(e.toString());
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> verifyOTP(String otp, {String? verificationId}) async {
    try {
      final vid = verificationId ?? _verificationId;
      if (vid == null) {
        throw Exception("Verification ID is null");
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      log("verifyOTP error: $e");
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out first to ensure fresh sign in
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      log("signInWithGoogle error: $e");
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final credential = FacebookAuthProvider.credential(accessToken.tokenString);
        return await _auth.signInWithCredential(credential);
      } else {
        log("Facebook login failed: ${result.status}");
        return null;
      }
    } catch (e) {
      log("signInWithFacebook error: $e");
      rethrow;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      return await _auth.signInWithCredential(oAuthCredential);
    } catch (e) {
      log("signInWithApple error: $e");
      rethrow;
    }
  }

  // Update user email
  Future<void> updateEmail(String email) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(email);
    } catch (e) {
      log("updateEmail error: $e");
      rethrow;
    }
  }

  // Update user phone number
  Future<void> updatePhoneNumber(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.currentUser?.updatePhoneNumber(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      log("updatePhoneNumber error: $e");
      onError(e.toString());
    }
  }

  // Verify phone number update with OTP
  Future<void> verifyPhoneNumberUpdate(String otp, {String? verificationId}) async {
    try {
      final vid = verificationId ?? _verificationId;
      if (vid == null) {
        throw Exception("Verification ID is null");
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: otp,
      );

      await _auth.currentUser?.updatePhoneNumber(credential);
    } catch (e) {
      log("verifyPhoneNumberUpdate error: $e");
      rethrow;
    }
  }

  // Send phone verification (for already signed in users)
  Future<void> sendPhoneVerification(
    String phoneNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    await updatePhoneNumber(
      phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      await _auth.signOut();
      _verificationId = null;
    } catch (e) {
      log("signOut error: $e");
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      log("deleteAccount error: $e");
      rethrow;
    }
  }

  // Get current session (list sessions not available in Firebase Auth like Appwrite)
  // Firebase Auth manages sessions automatically
  bool hasActiveSession() {
    return _auth.currentUser != null;
  }

  // Reauthenticate with phone credential before sensitive operations
  Future<void> reauthenticateWithPhone(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } catch (e) {
      log("reauthenticateWithPhone error: $e");
      rethrow;
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      log("reloadUser error: $e");
      rethrow;
    }
  }
}

// Global instance
final firebaseAuthService = FirebaseAuthService();
