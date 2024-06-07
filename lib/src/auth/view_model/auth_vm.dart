import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../appwrite.dart';
import '../../../constant/constant.dart';
import '../../../constant/enums.dart';
import '../../../services/firebase_collections.dart';
import '../../../services/image_picker_services.dart';
import '../model/user_model.dart';
import '../view/create_username.dart';
import '../view/social_signup.dart';
import '../../base/base_view.dart';
import '../../base/home/home_vm/home_vm.dart';
import '../../base/inbox/view_model/inbox_vm.dart';
import '../../base/search/model/charter_model.dart';
import '../../base/search/view/bookings/model/wallet_model.dart';
import '../../base/settings/view_model/settings_vm.dart';
import '../../base/yacht/view/charter_detail.dart';
import '../../base/yacht/view_model/yacht_vm.dart';
import '../../landing_page/view/vanilla.dart';
import '../../../resources/resources.dart';
import '../../../utils/helper.dart';
import '../view/login.dart';
import '../widgets/otp_dialog.dart';
import '../../../utils/zbot_toast.dart';

class AuthVm extends ChangeNotifier {
  bool isLoading = false;
  bool usernameIsAvailable = true;
  UserModel? userModel;
  String? appleUserName;
  String? appleUserEmail;
  WalletModel? wallet;
  String? yachtId;
  StreamSubscription<DocumentSnapshot<UserModel>>? currentUserStream;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseFirestore db = FirebaseFirestore.instance;
  StreamSubscription<List<WalletModel>>? walletStream;
  startLoader() {
    isLoading = true;
    notifyListeners();
  }

  bool checkIfInvite() {
    if (yachtId != null) {
      return true;
    }
    return false;
  }

  Future<void> isUsernameAvailable(String username) async {
    if (username.length > 5) {
      await db
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then(
        (QuerySnapshot doc) {
          print(doc.docs);
          if (doc.docs.isEmpty) {
            usernameIsAvailable = true;
          } else {
            usernameIsAvailable = false;
          }
          notifyListeners();
        },
      );
    } else {
      print("Should Change to false outer ");
      usernameIsAvailable = false;
      notifyListeners();
    }
  }

  stopLoader() {
    isLoading = false;
    notifyListeners();
  }

  update() {
    notifyListeners();
  }

  onClickLoginOTP(String countryCode, String phoneNumController) async {
    bool isUserExist =
        await chechUserCollectionExists("$countryCode$phoneNumController");
    print("..................................USER EXIST:$isUserExist");
    if (isUserExist == false) {
      Helper.inSnackBar('Error', "This user does not exist", R.colors.themeMud);
      ZBotToast.loadingClose();
    } else {
      await signInWithOtp(countryCode, phoneNumController);
    }
  }

  onClickFacebookLogin() async {
    try {
      startLoader();
      await appwrite.signInFacebook();
      await Future.delayed(Duration(seconds: 2));
      await appwrite.getUser();
      bool isUserExist = false;
      isUserExist =
          await chechUserCollectionExists(appwrite.user.$id, isEmail: true);
      if (isUserExist == true) {
        await fetchUser();
        Future.delayed(Duration(seconds: 2), () async {
          if (userModel != null) {
            if (userModel?.status == UserStatus.blocked) {
              appwrite.account.deleteSession(sessionId: 'current');
              Fluttertoast.showToast(msg: "You have been blocked by admin");
            } else {
              userModel?.fcm = Constants.fcmToken;
              // userModel?.isActiveUser = true;
              await updateUser(userModel);
              ZBotToast.loadingClose();
              Get.offAllNamed(BaseView.route);
            }
          } else {
            stopLoader();
          }
        });
      } else {
        stopLoader();
        print("Here before navigating to social sign up");
        Get.toNamed(SocialSignup.route);
      }
    } on AppwriteException catch (e) {
      log("THIS IS ERRROR $e");
      Fluttertoast.showToast(msg: "$e");
      if (appwrite.user != null) {
        logoutUser();
      }
    }
  }

  onClickGoogleLogin() async {
    try {
      await appwrite.signInGoogle();
      ZBotToast.loadingShow();
      await Future.delayed(Duration(milliseconds: 100));
      await appwrite.getUser();
      bool isUserExist = false;
      isUserExist =
          await chechUserCollectionExists(appwrite.user.$id, isEmail: true);
      if (isUserExist == true) {
        await fetchUser();
        if (userModel != null) {
          if (userModel?.status == UserStatus.blocked) {
            appwrite.account.deleteSession(sessionId: 'current');
            Fluttertoast.showToast(msg: "You have been blocked by admin");
          } else {
            userModel?.fcm = Constants.fcmToken;
            // userModel?.isActiveUser = true;
            await updateUser(userModel);
            ZBotToast.loadingClose();
            Get.offAllNamed(BaseView.route);
          }
        } else {
          stopLoader();
        }
      } else {
        stopLoader();
        print("Here before navigating to social sign up");
        Get.toNamed(SocialSignup.route);
      }
    } on AppwriteException catch (e) {
      log("THIS IS ERRROR $e");
      Fluttertoast.showToast(msg: "$e");
      if (appwrite.user != null) {
        logoutUser();
      }
    }
  }

  onClickAppleLogin() async {
    try {
      startLoader();
      await appwrite.signInApple();
      await Future.delayed(Duration(seconds: 2));
      await appwrite.getUser();
      if (appwrite.user != null) {
        bool isUserExist = false;
        isUserExist =
            await chechUserCollectionExists(appwrite.user.$id, isEmail: true);
        if (isUserExist == true) {
          await fetchUser();
          Future.delayed(Duration(seconds: 2), () async {
            if (userModel != null) {
              if (userModel?.status == UserStatus.blocked) {
                appwrite.account.deleteSession(sessionId: 'current');
                Fluttertoast.showToast(msg: "You have been blocked by admin");
              } else {
                userModel?.fcm = Constants.fcmToken;
                // userModel?.isActiveUser = true;
                await updateUser(userModel);
                ZBotToast.loadingClose();
                Get.offAllNamed(BaseView.route);
              }
            } else {
              stopLoader();
            }
          });
        } else {
          stopLoader();
          Get.toNamed(SocialSignup.route,
              arguments: {"user": appwrite.user, "isApple": true});
        }
      }
    } on AppwriteException catch (e) {
      log("THIS IS ERRROR$e");
      Fluttertoast.showToast(msg: "$e");
      if (appwrite.user != null) {
        logoutUser();
      }
    }
  }

  onClickSignup(String email, String firstName, String lastName,
      String countryCode, String phoneNumController, String username) async {
    log("____HERE");
    bool isUserExist =
        await chechUserCollectionExists("$countryCode$phoneNumController");
    if (isUserExist == true) {
      Helper.inSnackBar('Error', "User already exist", R.colors.themeMud);
      stopLoader();
      return;
    } else {
      print("Signing up with OTP");
      await signupWithOtp(countryCode, phoneNumController, email, firstName,
          lastName, username);
    }
  }

  onClickSocialSignup(
    String countryCode,
    String phoneNumController,
  ) async {
    bool isUserExist =
        await chechUserCollectionExists("$countryCode$phoneNumController");

    if (isUserExist == true) {
      Helper.inSnackBar('Error', "User already exist", R.colors.themeMud);
      stopLoader();
    } else {
      log("____USER display name:${appwrite.user.name}");
      print("Starting registration");
      await registerUserSocial(countryCode, phoneNumController);
    }
  }

// Migrated to Appwrite
  checkCurrentUser(BuildContext context) async {
    try {
      print("////////////////in check current user");
      await appwrite.getUser();
      Future.delayed(Duration(seconds: 1));
      if (appwrite.user.phoneVerification) {
        print("phone verification has been done");
        await fetchUser();
        var yachtProvider = Provider.of<YachtVm>(Get.context!, listen: false);
        await yachtProvider.fetchCharters();
        print("Fetched YATCHS PRINTING LENGTH");
        print(yachtProvider.allCharters.length);
        Future.delayed(Duration(seconds: 2), () async {
          if (Constants.fcmToken.isEmpty) {
            print("Fetched YATCHS PRINTING LENGTH");
            // userModel?.fcm = await FirebaseMessaging.instance.getToken();
          } else {
            userModel?.fcm = Constants.fcmToken;
          }
          if (userModel != null) {
            if (userModel?.status == UserStatus.blocked) {
              appwrite.account.deleteSession(sessionId: 'current');
              Fluttertoast.showToast(msg: "You have been blocked by admin");
            } else {
              userModel?.fcm = Constants.fcmToken;
              var yachtProvider =
                  Provider.of<YachtVm>(Get.context!, listen: false);
              // userModel?.isActiveUser = true;
              await updateUser(userModel);
              ZBotToast.loadingClose();
              yachtId = Get.parameters["yachtId"];
              if (yachtId == null) {
                /// Pasting code
                if (Get.parameters['status'] != null) {
                  handleReturnRedirectFromStripeAccountLink(
                      context, Get.parameters['status']!);
                } else {
                  print("Now navigating to base view");
                  print("Fetched YATCHS PRINTING LENGTH");
                  print(yachtProvider.allCharters.length);
                  Get.offAllNamed(BaseView.route);
                }

                /// end of code pasted
              } else {
                print("Here");
                List<CharterModel> test =
                    yachtProvider.allCharters.where((element) {
                  return element.id == yachtId;
                }).toList();
                print("Printing Test");
                CharterModel yacht = test[0];
                int index = yachtProvider.allCharters
                    .indexWhere((element) => element.id == yachtId);
                Get.toNamed(CharterDetail.route, arguments: {
                  "yacht": yacht,
                  "isReserve": false,
                  "index": index,
                  "isEdit": yacht.createdBy == appwrite.user.$id ? true : false,
                  "isLink": true
                });
              }
              String? senderId = Get.parameters["from"];
              if (senderId != null) {
                var inviteData = {'from': senderId, 'to': appwrite.user.$id};
                await FbCollections.invites.add(inviteData);
              }
            }
          } else {
            Get.offAllNamed(LoginScreen.route);
          }
        });
      } else {
        Get.offAllNamed(LoginScreen.route);
      }
    } catch (e) {
      debugPrintStack();
      log("///////////NOT ANY CURRENT USER");
      Get.offAllNamed(LoginScreen.route);
    }
  }

  getUserWallet() async {
    WalletModel? walletModel;
    print("==========In FETCH USER WALLET:${appwrite.user.$id}");
    var ref = await FbCollections.wallet.snapshots().asBroadcastStream();
    var res = ref.map((list) =>
        list.docs.map((e) => WalletModel.fromJson(e.data())).toList());

    try {
      walletStream ??= res.listen((event) async {
        log("____len:${event.length}");
        if (event.isNotEmpty) {
          walletModel = event
              .firstWhereOrNull((element) => element.uid == appwrite.user.$id);
          wallet = walletModel;
          update();
        }
        update();
        log("WALLET:${wallet?.amount}");
      });
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  updateUserWallet(double amount) async {
    try {
      print("==========In UPDATE USER WALLET}");
      await FbCollections.wallet
          .doc(appwrite.user.$id)
          .update({"amount": amount});
      await getUserWallet();
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  Future registerUserSocial(String countryCode, String number) async {
    try {
      print("About to verify phone number");
      // Different Stuff needs to be used here
      print("Updating phone and sending message");
      await appwrite.updateAndVerifyPhoneNumber(countryCode + number);
      print("sms sent");
      Get.dialog(
          OTP(countryCode + number, true, (otpCode) async {
            startLoader();
            await verifySignUpOtpSocial(countryCode, number, otpCode)
                .whenComplete(() {
              stopLoader();
            });
          }, () async {
            startLoader();
            await registerUserSocial(countryCode, number);
          }),
          barrierDismissible: true,
          barrierColor: Colors.grey.withOpacity(.25));
    } catch (e) {
      debugPrintStack();
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
            msg:
                "The sms code has expired. Please re-send the verification code to try again.");
      } else if (e
          .toString()
          .contains("firebase_auth/invalid-verification-code")) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: e.toString().split("]").last);
      }
      log(e.toString());
      stopLoader();
    }
  }

  addUsernameFinishSignUp(
      String countryCode, String number, String username) async {
    await setSignupUserData(
            countryCode,
            number,
            appwrite.user.email,
            appwrite.user.name.contains(" ") == true
                ? appwrite.user.name.split(" ").first
                : appwrite.user.name,
            appwrite.user.name.contains(" ") == true
                ? appwrite.user.name.split(" ").last
                : "",
            username)
        .then((value) async {
      await fetchUser();
      if (userModel?.status == UserStatus.blocked) {
        appwrite.account.deleteSession(sessionId: 'current');
        Fluttertoast.showToast(msg: "You have been blocked by admin");
      } else {
        userModel?.fcm = Constants.fcmToken;
        print(userModel!.toJson());
        await updateUser(userModel);
        ZBotToast.loadingClose();

        Get.offAllNamed(BaseView.route);
      }
    });
  }

  verifySignUpOtpSocial(
    String countryCode,
    String number,
    String code,
  ) async {
    startLoader();
    // start work here
    await appwrite.updatePhoneVerification(code).then((cred) async {
      await appwrite.getUser();
      if (appwrite.user != null) {
        Get.offNamed(CreateUsername.route,
            arguments: {"phoneNo": number, "countryCode": countryCode});
      }
    }).catchError((e) {
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
            msg:
                "The sms code has expired. Please re-send the verification code to try again.");
      } else if (e
          .toString()
          .contains("firebase_auth/invalid-verification-code")) {
        Helper.inSnackBar("Error", "Wrong OTP code", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: "$e");
      }
      stopLoader();
    });
  }

  signInWithOtp(String countryCode, String number) async {
    print("+++++++++++++++++++++++++++++++MOBILE:$countryCode $number");
    try {
      appwrite.sendSMS(countryCode + number);
      log("___________CODE SENT:");
      print("I am here code is sent");
      Get.dialog(
          OTP(countryCode + number, false,
              // verification call back
              (otpCode) async {
            stopLoader();
            print("about to verify otp");
            await verifyOtp("", countryCode, number, otpCode);
          },
              // resend call back
              () async {
            await signInWithOtp(countryCode, number);
          }),
          barrierDismissible: true,
          barrierColor: Colors.grey.withOpacity(.25));
    } catch (e) {
      debugPrintStack();
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
            msg:
                "The sms code has expired. Please re-send the verification code to try again.");
      } else if (e
          .toString()
          .contains("firebase_auth/invalid-verification-code")) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: "${e.toString().split("]").last}");
      }
      log(e.toString());
      stopLoader();
    }
  }

  Future signupWithOtp(String countryCode, String num, String email,
      String firstName, String lastName, String username) async {
    try {
      print(countryCode + num);
      String phono = countryCode + num;
      print("Sending SMS");
      await appwrite.sendSMS(phono);
      print("Sent SMS");
      log("_______________________WHEN COMP");
      stopLoader();
      Get.dialog(
          OTP(countryCode + num, true, (otpCode) async {
            startLoader();
            print(otpCode);
            await verifySignUpOtp(countryCode, email, firstName, lastName, num,
                    otpCode, username)
                .whenComplete(() {
              stopLoader();
            });
          }, () async {
            startLoader();
            await signupWithOtp(
                    countryCode, num, email, firstName, lastName, username)
                .whenComplete(() {
              stopLoader();
            });
          }),
          barrierDismissible: true,
          barrierColor: Colors.grey.withOpacity(.25));
    } catch (e) {
      debugPrintStack();
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
            msg:
                "The sms code has expired. Please re-send the verification code to try again.");
      } else if (e
          .toString()
          .contains("firebase_auth/invalid-verification-code")) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: "$e");
      }
      log(e.toString());
      stopLoader();
    }
  }

  verifySignUpOtp(String countryCode, String email, String firstName,
      String lastName, String num, String code, String username) async {
    try {
      startLoader();
      await appwrite.verifySMS(code).then((result) async {
        await appwrite.getUser();
        print(appwrite.user.$id);
        await Future.delayed(Duration(seconds: 1));
        if (appwrite.user != null) {
          await setSignupUserData(
              countryCode, num, email, firstName, lastName, username);
          Get.offAllNamed(
            BaseView.route,
          );
        }
        // Get.offAll(DashboardPage());
      }).catchError((e) {
        if (e.toString().contains("firebase_auth/session-expired")) {
          Fluttertoast.showToast(
              msg:
                  "The sms code has expired. Please re-send the verification code to try again.");
        } else if (e
            .toString()
            .contains("firebase_auth/invalid-verification-code")) {
          Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
        } else {
          Fluttertoast.showToast(msg: "$e");
        }
        stopLoader();
      });
    } catch (e) {
      debugPrintStack();
      log(e.toString());
      stopLoader();
    }
  }

  verifyOtp(String uid, String countryCode, String number, String code) async {
    try {
      startLoader();
      await appwrite.verifySMS(code).then((result) async {
        await appwrite.getUser();
        if (appwrite.user != null) {
          Future.delayed(Duration(seconds: 2), () async {
            if (userModel?.status == UserStatus.blocked) {
              appwrite.account.deleteSession(sessionId: 'current');
              Fluttertoast.showToast(msg: "You have been blocked by admin");
            } else {
              userModel?.fcm = Constants.fcmToken;
              // userModel?.isActiveUser = true;
              await updateUser(userModel);
              print("Otp verified now fetching user after updating user modal");

              await fetchUser();
              ZBotToast.loadingClose();
              Get.offAllNamed(BaseView.route);
            }
          });
        }
      }).catchError((e) {
        // yet to configure appwrite error message
        if (e.toString().contains("firebase_auth/session-expired")) {
          Fluttertoast.showToast(
              msg:
                  "The sms code has expired. Please re-send the verification code to try again.");
        } else if (e
            .toString()
            .contains("firebase_auth/invalid-verification-code")) {
          Helper.inSnackBar("Error", "Wrong OTP error", R.colors.themeMud);
        } else {
          Fluttertoast.showToast(msg: "$e");
        }
        stopLoader();
      });
    } catch (e) {
      debugPrintStack();
      log(e.toString());
      stopLoader();
    }
  }

  setSignupUserData(
    String countryCode,
    String number,
    String email,
    String firstName,
    String lastName,
    String username,
  ) async {
    try {
      bool isUserExist = false;
      isUserExist = await chechUserCollectionExists("$countryCode$num");
      print("printing user id before collection creation");
      print(appwrite.user.$id);

      if (isUserExist == false) {
        await FbCollections.user.doc(appwrite.user.$id).set({
          "uid": appwrite.user.$id,
          "username": username,
          "created_at": Timestamp.now(),
          "email": email.replaceAll(' ', ''),
          "number": number,
          "dial_code": countryCode,
          "first_name": firstName,
          "last_name": lastName,
          "image_url": R.images.dummyDp,
          "phone_number": "$countryCode$number",
          "fcm": Constants.fcmToken,
          "role": UserType.user.index,
          "status": UserStatus.active.index,
          "request_status": RequestStatus.notHost.index,
          "invite_status": 0
        });
        print("made collection");
        WalletModel walletModel =
            WalletModel(amount: 0.0, uid: appwrite.user.$id);
        await FbCollections.wallet
            .doc(appwrite.user.$id)
            .set(walletModel.toJson());
      } else {
        Helper.inSnackBar("Error", "User already exist", R.colors.themeMud);
      }
    } catch (e) {
      debugPrintStack();
      log(e.toString());
      stopLoader();
    }
  }

  ///CHECK USRR COLLECTION EXIST

  Future<bool> chechUserCollectionExists(String docValue,
      {bool isEmail = false}) async {
    try {
      bool userExists = false;
      await FbCollections.user
          .where(isEmail ? "uid" : "phone_number", isEqualTo: docValue)
          .get()
          .then((value) {
        if (value.docs.isEmpty) {
          userExists = false;
        } else {
          userExists = true;
        }
      });
      return userExists;
    } catch (e) {
      debugPrintStack();
      log(e.toString());
      stopLoader();
      return false;
    }
  }

  // Future<UserCredential?> linkPhoneNumber(AuthCredential credential) async {
  //   try {
  //     UserCredential? cred = await FirebaseAuth.instance.currentUser
  //         ?.linkWithCredential(credential);
  //     return cred;
  //   } catch (e) {
  //     log("++++++++++++++++++++++++++++++++++$e");
  //     if (e.toString().contains("firebase_auth/session-expired")) {
  //       Fluttertoast.showToast(
  //           msg:
  //               "The sms code has expired. Please re-send the verification code to try again.");
  //     } else if (e
  //         .toString()
  //         .contains("firebase_auth/invalid-verification-code")) {
  //       Helper.inSnackBar("Error", "Wrong OTP code", R.colors.themeMud);
  //     } else {
  //       Fluttertoast.showToast(msg: "$e");
  //     }
  //     stopLoader();
  //     debugPrintStack();
  //   }
  //   return null;
  // }

  Future<String> uploadUserImage(File pickedImage) async {
    var imageUrl = await ImagePickerServices().uploadSingleImage(pickedImage);
    log("_______________USERMODE IMAGE URL:${userModel?.imageUrl}");
    if (userModel?.imageUrl !=
            "https://firebasestorage.googleapis.com/v0/b/blogit-2cb31.appspot.com/o/dummyDp.jpeg?alt=media&token=ff065402-236c-4ee9-8e85-29f53617a4d3" &&
        userModel?.imageUrl != null &&
        userModel?.imageUrl?.isNotEmpty == true &&
        userModel?.imageUrl?.contains("googleusercontent") != true &&
        userModel?.imageUrl?.contains("graph.facebook.com") != true) {
      await FirebaseStorage.instance
          .refFromURL(userModel?.imageUrl ?? "")
          .delete();
    }
    await FbCollections.user
        .doc(userModel!.uid)
        .update({"image_url": imageUrl});
    update();
    return imageUrl;
  }

  Future<String> uploadHostDocument(File pickedImage) async {
    var imageUrl = await ImagePickerServices()
        .uploadSingleImage(pickedImage, bucketName: "hostDocuments");
    await FbCollections.user
        .doc(userModel!.uid)
        .update({"host_document_url": imageUrl});
    update();
    return imageUrl;
  }

  updateProfileDataToDB(
      String firstName, String lastName, String username) async {
    await FbCollections.user.doc(userModel!.uid).update(
        {"first_name": firstName, "last_name": lastName, "username": username});
    update();
  }

  ///EDIT PROFILE
  onClickEditProfile(String firstName, String lastName, String username,
      File? pickedImage, BuildContext context) async {
    startLoader();
    userModel?.firstName = firstName;
    userModel?.lastName = lastName;
    userModel?.username = username;
    if (pickedImage != null) {
      userModel?.imageUrl = await uploadUserImage(pickedImage);
    }
    await updateProfileDataToDB(firstName, lastName, username);
    update();
    stopLoader();
    Navigator.pop(context);
    Helper.inSnackBar(
        "Success", "Profile Updated Successfully", R.colors.themeMud);
  }

  Future<bool> updateUser(UserModel? userModel,
      {bool? showLoading = true}) async {
    bool proceed = false;
    log("CALLED");
    if (showLoading!) {
      ZBotToast.loadingShow();
    }
    try {
      await FbCollections.user.doc(userModel?.uid).set(userModel?.toJson());
      ZBotToast.loadingClose();
      proceed = true;
      Get.forceAppUpdate();
    } catch (e) {
      ZBotToast.loadingClose();
      log(e.toString());
    }
    return proceed;
  }

  Future<void> fetchUser() async {
    try {
      log("___HERE IN STREAM:${appwrite.user.$id}");
      print(appwrite.user.$id);

      var ref = FbCollections.user
          .doc(appwrite.user.$id)
          .snapshots()
          .asBroadcastStream();

      currentUserStream ??
          ref.listen((event) async {
            if (event != null) {
              print("Putting values fetched into usermodel structure");
              print(event.data());

              userModel = UserModel.fromJson(event.data());
              print("values put hogyi hai nothing to worry");
              print(userModel!.toJson());
              if (userModel?.status == UserStatus.blocked) {
                Get.offAllNamed(LoginScreen.route);
                await logoutUser(isUpdateUser: false);
                Fluttertoast.showToast(msg: "You have been blocked by admin");
              }
            }
          });
      print("ab toh wapis jaane wale hai");
      print(userModel!.toJson());
      getUserWallet();
      notifyListeners();
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
  }

  ///SIGNOUT
  logoutUser({bool isUpdateUser = true}) async {
    try {
      log("____IN LOGOUT");
      if (isUpdateUser == true) {
        userModel?.fcm = "";
        // userModel?.isActiveUser = false;
        updateUser(userModel);
      }
      Provider.of<YachtVm>(Get.context!, listen: false)
        ..hostServicesList = []
        ..allServicesList = []
        ..userFavouritesList = []
        ..allCharters = []
        ..hostCharters = []
        ..allYachts = []
        ..hostYachts = []
        ..servicesStream?.cancel()
        ..servicesStream = null
        ..charterStream?.cancel()
        ..charterStream = null
        ..userFavouritesStream?.cancel()
        ..userFavouritesStream = null
        ..yachtStream?.cancel()
        ..yachtStream = null
        ..update();
      Provider.of<SettingsVm>(Get.context!, listen: false)
        ..allReviews = []
        ..reviewStream?.cancel()
        ..reviewStream = null;
      Provider.of<HomeVm>(Get.context!, listen: false)
        ..allBookings = []
        ..bookingsStream?.cancel()
        ..bookingsStream = null;
      Provider.of<InboxVm>(Get.context!, listen: false)
        ..hostNotificationsList = []
        ..notificationStream?.cancel()
        ..notificationStream = null;
      Provider.of<AuthVm>(Get.context!, listen: false)
        ..walletStream?.cancel()
        ..walletStream = null;
      appwrite.account.deleteSession(sessionId: 'current');
      stopLoader();
    } catch (e) {
      stopLoader();
      debugPrintStack();
      log(e.toString());
    }
  }

  cancleStreams() async {
    try {
      Provider.of<YachtVm>(Get.context!, listen: false)
        ..hostServicesList = []
        ..allServicesList = []
        ..userFavouritesList = []
        ..allCharters = []
        ..hostCharters = []
        ..allYachts = []
        ..hostYachts = []
        ..servicesStream?.cancel()
        ..servicesStream = null
        ..charterStream?.cancel()
        ..charterStream = null
        ..userFavouritesStream?.cancel()
        ..userFavouritesStream = null
        ..yachtStream?.cancel()
        ..yachtStream = null
        ..update();
      Provider.of<HomeVm>(Get.context!, listen: false)
        ..allBookings = []
        ..bookingsStream?.cancel()
        ..bookingsStream = null;
      Provider.of<InboxVm>(Get.context!, listen: false)
        ..hostNotificationsList = []
        ..notificationStream?.cancel()
        ..notificationStream = null;
      currentUserStream?.cancel();
      currentUserStream = null;
      stopLoader();
    } catch (e) {
      stopLoader();
      debugPrintStack();
      log(e.toString());
    }
  }
}
