import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:http/http.dart' as http;
import 'package:yacht_master/utils/logger.dart';

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
    AppLogger.debug('Appwrite client initialised');
  }

  Future<void> getUser() async {
    user = await account.get();
    AppLogger.debug('Fetched Appwrite user ${user.$id}');
  }

  Future<void> sendSMS(String phone) async {
    sessionToken = await account.createPhoneToken(
      userId: appwrite.uniqueId,
      phone: phone,
    );
  }

  Future<void> updateAndVerifyPhoneNumber(String phone) async {
    await account.updatePhone(phone: phone, password: 'passwords');
    await account.createPhoneVerification();
    AppLogger.debug('Initiated phone update for $phone');
  }

  Future<void> updatePhoneVerification(String code) async {
    account.updatePhoneVerification(userId: appwrite.user.$id, secret: code);
    AppLogger.debug('Requested phone verification update');
  }

  Future<void> verifySMS(String sms) async {
    AppLogger.debug('Verifying SMS code');
    session = await account.updatePhoneSession(
      userId: sessionToken.userId,
      secret: sms,
    );
    AppLogger.debug('Appwrite session created');
  }

  Future<void> signInApple() async {
    await account.createOAuth2Session(provider: OAuthProvider.apple);
    AppLogger.debug('Created Apple OAuth session');
  }

  Future<void> signInGoogle() async {
    await account.createOAuth2Session(provider: OAuthProvider.google);
    AppLogger.debug('Created Google OAuth session');
  }

  Future<void> signInFacebook() async {
    await account.createOAuth2Session(provider: OAuthProvider.facebook);
    AppLogger.debug('Created Facebook OAuth session');
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
