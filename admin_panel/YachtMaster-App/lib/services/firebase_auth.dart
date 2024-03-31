import 'package:firebase_auth/firebase_auth.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';

abstract class BaseAuth {
  Future<User?> signInWithEmailPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendResetPassEmail(String email);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      User? user = (await _firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      return user!;
    } catch (e) {
      String error = e.toString().split(']').toList().last;
      ZBotToast.showToastError(message: error);
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> sendResetPassEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
