import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';

Appwrite appwrite = Appwrite();

class Appwrite {
  Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("66322b1f002a454ae73f");

  late Account account;
  String get uniqueId => ID.unique();
  late Token sessionToken;
  late Session session;
  late User user;

  void initialiseAppwrite() {
    account = Account(client);
    print("initialised appwrite");
  }

  Future<void> getUser() async {
    user = await appwrite.account.get();
  }

  Future<void> sendSMS(String phone) async {
    sessionToken = await appwrite.account
        .createPhoneToken(userId: appwrite.uniqueId, phone: phone);
  }

  Future<void> updateAndVerifyPhoneNumber(String phone) async {
    print("updating phone no");
    await appwrite.account.updatePhone(phone: phone, password: 'passwords');
    await appwrite.account.createPhoneVerification();
  }

  Future<void> updatePhoneVerification(String code) async {
    print("updating verification");
    appwrite.account
        .updatePhoneVerification(userId: appwrite.user.$id, secret: code);
  }

  Future<void> verifySMS(String sms) async {
    session = await account.updatePhoneSession(
        userId: sessionToken.userId, secret: sms);
  }

  Future<void> signInApple() async {
    print("creating session");
    await appwrite.account.createOAuth2Session(
      provider: OAuthProvider.apple,
    );
    print("session created");
  }

  Future<void> signInGoogle() async {
    print("creating session");

    await appwrite.account.createOAuth2Session(
      provider: OAuthProvider.google,
    );
    print("session created");
  }
}
