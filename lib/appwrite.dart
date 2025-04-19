import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:http/http.dart' as http;

Appwrite appwrite = Appwrite();

class Appwrite {
  Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("66c4eca9002516db4845");

  late Account account;
  String get uniqueId => ID.unique();
  late Token sessionToken;
  late Session session;
  late User user;
  late http.StreamedResponse deleteUserResponse;
  late http.Request deleteUserRequest;

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
    sessionToken = await account.createPhoneToken(
      userId: appwrite.uniqueId,
      phone: phone,
    );
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
    print("verifying sms");
    session = await account
        .updatePhoneSession(userId: sessionToken.userId, secret: sms)
        .then((Session sesh) {
          print("session created");
          return sesh;
        });
  }

  Future<void> signInApple() async {
    print("creating session");
    await account.createOAuth2Session(provider: OAuthProvider.apple);
    print("session created");
  }

  Future<void> signInGoogle() async {
    print("creating session");

    await account.createOAuth2Session(provider: OAuthProvider.google);
    print("session created");
  }

  Future<void> signInFacebook() async {
    print("creating session");

    await account.createOAuth2Session(provider: OAuthProvider.facebook);
    print("session created");
  }

  Future<void> deleteUser() async {
    deleteUserRequest = http.Request(
      'GET',
      Uri.parse(
        'https://deleteuser-ribsvsftyq-uc.a.run.app?userId=${user.$id}',
      ),
    );
    deleteUserResponse = await deleteUserRequest.send();
  }
}
