import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:http/http.dart' as http;

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
  late http.StreamedResponse delete_user_response;
  late http.Request delete_user_request;

  void initialiseAppwrite() {
    account = Account(client);
    print("initialised appwrite");
  }

  Future<void> getUser() async {
    print("Getting user");
    user = await account.get();
    print("User has been getted");
  }

  Future<void> sendSMS(String phone) async {
    sessionToken =
        await account.createPhoneToken(userId: appwrite.uniqueId, phone: phone);
  }

  Future<void> updateAndVerifyPhoneNumber(String phone) async {
    print("updating phone no");
    await account.updatePhone(phone: phone, password: 'passwords');
    await account.createPhoneVerification();
  }

  Future<void> updatePhoneVerification(String code) async {
    print("updating verification");
    account.updatePhoneVerification(userId: appwrite.user.$id, secret: code);
  }

  Future<void> verifySMS(String sms) async {
    session = await account.updatePhoneSession(
        userId: sessionToken.userId, secret: sms);
  }

  Future<void> signInApple() async {
    print("creating session");
    await account.createOAuth2Session(
      provider: OAuthProvider.apple,
    );
    print("session created");
  }

  Future<void> signInGoogle() async {
    print("creating session");

    await account.createOAuth2Session(
      provider: OAuthProvider.google,
    );
    print("session created");
  }

  Future<void> signInFacebook() async {
    print("creating session");

    await account.createOAuth2Session(
      provider: OAuthProvider.facebook,
    );
    print("session created");
  }

  Future<void> deleteUser() async {
    delete_user_request = http.Request(
        'GET',
        Uri.parse(
            'https://deleteuser-ribsvsftyq-uc.a.run.app?userId=${user.$id}'));
    delete_user_response = await delete_user_request.send();
  }
}
