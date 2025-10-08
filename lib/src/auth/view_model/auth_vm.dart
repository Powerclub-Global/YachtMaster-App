import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/utils/countryCodeConverter.dart';
import '../../../services/firebase_auth_service.dart';
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
  bool isVerifyingForHost = true;
  StreamSubscription<DocumentSnapshot<UserModel>>? currentUserStream;
  String? _usernameChangeVerificationId;

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
    if (username.length >= 4 && username.length <= 16) {
      await db
          .collection("users")
          .where("username", isEqualTo: username)
          .get()
          .then((QuerySnapshot doc) {
            print(doc.docs);
            if (doc.docs.isEmpty) {
              usernameIsAvailable = true;
            } else {
              usernameIsAvailable = false;
            }
            notifyListeners();
          });
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
    bool isUserExist = await chechUserCollectionExists(
      "$countryCode$phoneNumController",
    );
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

      final credential = await firebaseAuthService.signInWithFacebook();

      if (credential == null) {
        stopLoader();
        return;
      }

      await Future.delayed(Duration(seconds: 1));
      bool isUserExist = false;
      isUserExist = await chechUserCollectionExists(
        firebaseAuthService.currentUserId,
        isEmail: true,
      );
      if (isUserExist == true) {
        await fetchUser();
        Future.delayed(Duration(seconds: 2), () async {
          if (userModel != null) {
            if (userModel?.status == UserStatus.blocked) {
              await firebaseAuthService.signOut();
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
    } on FirebaseAuthException catch (e) {
      log("onClickFacebookLogin: THIS IS ERRROR $e");
      Fluttertoast.showToast(msg: "${e.message}");
      logoutUser();
    }
  }

  onClickGoogleLogin() async {
    try {
      final credential = await firebaseAuthService.signInWithGoogle();

      if (credential == null) {
        return;
      }

      ZBotToast.loadingShow();
      await Future.delayed(Duration(milliseconds: 100));
      bool isUserExist = false;
      isUserExist = await chechUserCollectionExists(
        firebaseAuthService.currentUserId,
        isEmail: true,
      );
      if (isUserExist == true) {
        await fetchUser();
        if (userModel != null) {
          if (userModel?.status == UserStatus.blocked) {
            await firebaseAuthService.signOut();
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
    } on FirebaseAuthException catch (e) {
      log("onClickGoogleLogin: THIS IS ERRROR $e");
      Fluttertoast.showToast(msg: "${e.message}");
      logoutUser();
    }
  }

  onClickAppleLogin() async {
    try {
      startLoader();

      final credential = await firebaseAuthService.signInWithApple();

      if (credential == null) {
        stopLoader();
        return;
      }

      await Future.delayed(Duration(seconds: 1));
      bool isUserExist = false;
      isUserExist = await chechUserCollectionExists(
        firebaseAuthService.currentUserId,
        isEmail: true,
      );
      if (isUserExist == true) {
        await fetchUser();
        Future.delayed(Duration(seconds: 2), () async {
          if (userModel != null) {
            if (userModel?.status == UserStatus.blocked) {
              await firebaseAuthService.signOut();
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
        Get.toNamed(
          SocialSignup.route,
          arguments: {"user": firebaseAuthService.currentUser, "isApple": true},
        );
      }
    } on FirebaseAuthException catch (e) {
      log("onClickAppleLogin: THIS IS ERRROR$e");
      Fluttertoast.showToast(msg: "${e.message}");
      logoutUser();
    }
  }

  onClickSignup(
    String email,
    String firstName,
    String lastName,
    String countryCode,
    String phoneNumController,
    String username,
  ) async {
    log("____HERE");
    bool isUserExist = await chechUserCollectionExists(
      "$countryCode$phoneNumController",
    );
    if (isUserExist == true) {
      Helper.inSnackBar('Error', "User already exist", R.colors.themeMud);
      stopLoader();
      return;
    } else {
      print("Signing up with OTP");
      await signupWithOtp(
        countryCode,
        phoneNumController,
        email,
        firstName,
        lastName,
        username,
      );
    }
  }

  onClickSocialSignup(String countryCode, String phoneNumController) async {
    bool isUserExist = await chechUserCollectionExists(
      "$countryCode$phoneNumController",
    );

    if (isUserExist == true) {
      Helper.inSnackBar('Error', "User already exist", R.colors.themeMud);
      stopLoader();
    } else {
      log(
        "onClickSocialSignup: ____USER display name:${firebaseAuthService.userName}",
      );
      print("Starting registration");
      await registerUserSocial(countryCode, phoneNumController);
    }
  }

  // Migrated to Firebase Auth
  checkCurrentUser(BuildContext context) async {
    try {
      print("////////////////in check current user");

      if (!firebaseAuthService.isSignedIn) {
        Get.offAllNamed(LoginScreen.route);
        return;
      }

      await firebaseAuthService.reloadUser();
      Future.delayed(Duration(seconds: 1));

      if (firebaseAuthService.isPhoneVerified ||
          firebaseAuthService.currentUser != null) {
        print("user is authenticated");
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
          log('Is this working check 1');
          if (userModel != null) {
            if (userModel?.status == UserStatus.blocked) {
              await firebaseAuthService.signOut();
              Fluttertoast.showToast(msg: "You have been blocked by admin");
            } else {
              userModel?.fcm = Constants.fcmToken;
              var yachtProvider = Provider.of<YachtVm>(
                Get.context!,
                listen: false,
              );
              // userModel?.isActiveUser = true;
              await updateUser(userModel);
              ZBotToast.loadingClose();
              yachtId = Get.parameters["yachtId"];
              if (yachtId == null) {
                /// Pasting code
                if (Get.parameters['status'] != null) {
                  handleReturnRedirectFromStripeAccountLink(
                    context,
                    Get.parameters['status']!,
                  );
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
                int index = yachtProvider.allCharters.indexWhere(
                  (element) => element.id == yachtId,
                );
                Get.toNamed(
                  CharterDetail.route,
                  arguments: {
                    "yacht": yacht,
                    "isReserve": false,
                    "index": index,
                    "isEdit":
                        yacht.createdBy == firebaseAuthService.currentUserId
                            ? true
                            : false,
                    "isLink": true,
                  },
                );
              }
              String? senderId = Get.parameters["from"];
              if (senderId != null) {
                var inviteData = {
                  'from': senderId,
                  'to': firebaseAuthService.currentUserId,
                };
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
      log("checkCurrentUser: " + e.toString());
      Get.offAllNamed(LoginScreen.route);
    }
  }

  getUserWallet() async {
    WalletModel? walletModel;
    print(
      "==========In FETCH USER WALLET:${firebaseAuthService.currentUserId}",
    );
    var ref = FbCollections.wallet.snapshots().asBroadcastStream();
    var res = ref.map(
      (list) => list.docs.map((e) => WalletModel.fromJson(e.data())).toList(),
    );

    try {
      walletStream ??= res.listen((event) async {
        log("____len:${event.length}");
        if (event.isNotEmpty) {
          walletModel = event.firstWhereOrNull(
            (element) => element.uid == firebaseAuthService.currentUserId,
          );
          wallet = walletModel;
          update();
        }
        update();
        log("WALLET:${wallet?.amount}");
      });
    } catch (e) {
      debugPrintStack();
      log("getUserWallet: " + e.toString());
    }
  }

  updateUserWallet(double amount) async {
    try {
      print("==========In UPDATE USER WALLET}");
      await FbCollections.wallet.doc(firebaseAuthService.currentUserId).update({
        "amount": amount,
      });
      await getUserWallet();
    } catch (e) {
      debugPrintStack();
      log("updateUserWallet: " + e.toString());
    }
  }

  Future registerUserSocial(String countryCode, String number) async {
    try {
      print("About to verify phone number");
      print("Updating phone and sending message");

      await firebaseAuthService.sendPhoneVerification(
        countryCode + number,
        onCodeSent: (verificationId) {
          print("sms sent");
          Get.dialog(
            OTP(
              countryCode + number,
              true,
              (otpCode) async {
                startLoader();
                await verifySignUpOtpSocial(
                  countryCode,
                  number,
                  otpCode,
                  verificationId,
                ).whenComplete(() {
                  stopLoader();
                });
              },
              () async {
                startLoader();
                await registerUserSocial(countryCode, number);
              },
            ),
            barrierDismissible: true,
            barrierColor: Colors.grey.withValues(alpha: .25),
          );
        },
        onError: (error) {
          Fluttertoast.showToast(msg: error);
          stopLoader();
        },
      );
    } catch (e) {
      debugPrintStack();
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
          msg:
              "The sms code has expired. Please re-send the verification code to try again.",
        );
      } else if (e.toString().contains(
        "firebase_auth/invalid-verification-code",
      )) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: e.toString().split("]").last);
      }
      log("registerUserSocial: " + e.toString());
      stopLoader();
    }
  }

  addUsernameFinishSignUp(
    String countryCode,
    String number,
    String username,
  ) async {
    await setSignupUserData(
      countryCode,
      number,
      firebaseAuthService.userEmail,
      firebaseAuthService.userName.contains(" ") == true
          ? firebaseAuthService.userName.split(" ").first
          : firebaseAuthService.userName,
      firebaseAuthService.userName.contains(" ") == true
          ? firebaseAuthService.userName.split(" ").last
          : "",
      username,
    ).then((value) async {
      await fetchUser();
      if (userModel?.status == UserStatus.blocked) {
        await firebaseAuthService.signOut();
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
    String verificationId,
  ) async {
    startLoader();
    try {
      await firebaseAuthService.verifyPhoneNumberUpdate(
        code,
        verificationId: verificationId,
      );
      await firebaseAuthService.reloadUser();
      Get.offNamed(
        CreateUsername.route,
        arguments: {"phoneNo": number, "countryCode": countryCode},
      );
    } catch (e) {
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
          msg:
              "The sms code has expired. Please re-send the verification code to try again.",
        );
      } else if (e.toString().contains(
        "firebase_auth/invalid-verification-code",
      )) {
        Helper.inSnackBar("Error", "Wrong OTP code", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: "$e");
      }
      stopLoader();
    }
  }

  signInWithOtp(String countryCode, String number) async {
    print("+++++++++++++++++++++++++++++++MOBILE:$countryCode $number");
    try {
      await firebaseAuthService.sendOTP(
        countryCode + number,
        onCodeSent: (verificationId) {
          log("___________CODE SENT:");
          print("I am here code is sent");
          Get.dialog(
            OTP(
              countryCode + number,
              false,
              // verification call back
              (otpCode) async {
                stopLoader();
                print("about to verify otp");
                await verifyOtp(
                  "",
                  countryCode,
                  number,
                  otpCode,
                  verificationId,
                );
              },
              // resend call back
              () async {
                await signInWithOtp(countryCode, number);
              },
            ),
            barrierDismissible: true,
            barrierColor: Colors.grey.withValues(alpha: .25),
          );
        },
        onError: (error) {
          Fluttertoast.showToast(msg: error);
          stopLoader();
        },
      );
    } catch (e) {
      debugPrintStack();
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
          msg:
              "The sms code has expired. Please re-send the verification code to try again.",
        );
      } else if (e.toString().contains(
        "firebase_auth/invalid-verification-code",
      )) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: e.toString().split("]").last);
      }
      log("signInWithOtp: " + e.toString());
      stopLoader();
    }
  }

  Future signupWithOtp(
    String countryCode,
    String num,
    String email,
    String firstName,
    String lastName,
    String username,
  ) async {
    try {
      print(countryCode + num);
      String phono = countryCode + num;
      print("Sending SMS");

      await firebaseAuthService.sendOTP(
        phono,
        onCodeSent: (verificationId) {
          print("Sent SMS");
          log("_______________________WHEN COMP");
          stopLoader();
          Get.dialog(
            OTP(
              countryCode + num,
              true,
              (otpCode) async {
                startLoader();
                print(otpCode);
                await verifySignUpOtp(
                  countryCode,
                  email,
                  firstName,
                  lastName,
                  num,
                  otpCode,
                  username,
                  verificationId,
                ).whenComplete(() {
                  stopLoader();
                });
              },
              () async {
                startLoader();
                await signupWithOtp(
                  countryCode,
                  num,
                  email,
                  firstName,
                  lastName,
                  username,
                ).whenComplete(() {
                  stopLoader();
                });
              },
            ),
            barrierDismissible: true,
            barrierColor: Colors.grey.withValues(alpha: .25),
          );
        },
        onError: (error) {
          Fluttertoast.showToast(msg: error);
          stopLoader();
        },
      );
    } catch (e) {
      debugPrintStack();
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
          msg:
              "The sms code has expired. Please re-send the verification code to try again.",
        );
      } else if (e.toString().contains(
        "firebase_auth/invalid-verification-code",
      )) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: "$e");
      }
      log("signupWithOtp: " + e.toString());
      stopLoader();
    }
  }

  verifySignUpOtp(
    String countryCode,
    String email,
    String firstName,
    String lastName,
    String num,
    String code,
    String username,
    String verificationId,
  ) async {
    try {
      startLoader();
      await firebaseAuthService.verifyOTP(code, verificationId: verificationId);
      await firebaseAuthService.reloadUser();
      print(firebaseAuthService.currentUserId);
      await Future.delayed(Duration(seconds: 1));
      await setSignupUserData(
        countryCode,
        num,
        email,
        firstName,
        lastName,
        username,
      );
      Get.offAllNamed(BaseView.route);
    } catch (e) {
      if (e.toString().contains("firebase_auth/session-expired")) {
        Fluttertoast.showToast(
          msg:
              "The sms code has expired. Please re-send the verification code to try again.",
        );
      } else if (e.toString().contains(
        "firebase_auth/invalid-verification-code",
      )) {
        Helper.inSnackBar("Error", "Wrong OTP entered", R.colors.themeMud);
      } else {
        Fluttertoast.showToast(msg: "$e");
      }
      debugPrintStack();
      log("verifySignUpOtp: " + e.toString());
      stopLoader();
    }
  }

  verifyOtp(
    String uid,
    String countryCode,
    String number,
    String code,
    String verificationId,
  ) async {
    try {
      startLoader();
      print('loader started');
      await firebaseAuthService.verifyOTP(code, verificationId: verificationId);
      print('sms verified');
      await firebaseAuthService.reloadUser();
      print('user fetched');
      Future.delayed(Duration(seconds: 2), () async {
        if (userModel?.status == UserStatus.blocked) {
          await firebaseAuthService.signOut();
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
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
      debugPrintStack();
      log("verifyOtp: " + e.toString());
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
      isUserExist = await chechUserCollectionExists("$countryCode$number");
      print("printing user id before collection creation");
      print(firebaseAuthService.currentUserId);

      if (isUserExist == false) {
        await FbCollections.user.doc(firebaseAuthService.currentUserId).set({
          "uid": firebaseAuthService.currentUserId,
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
          "invite_status": 0,
        });
        print("made collection");
        WalletModel walletModel = WalletModel(
          amount: 0.0,
          uid: firebaseAuthService.currentUserId,
        );
        await FbCollections.wallet
            .doc(firebaseAuthService.currentUserId)
            .set(walletModel.toJson());
      } else {
        Helper.inSnackBar("Error", "User already exist", R.colors.themeMud);
      }
    } catch (e) {
      debugPrintStack();
      log("setSignupUserData: " + e.toString());
      stopLoader();
    }
  }

  ///CHECK USRR COLLECTION EXIST
  Future<bool> chechUserCollectionExists(
    String docValue, {
    bool isEmail = false,
    bool skipError = false,
  }) async {
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
      if (!skipError) {
        Helper.inSnackBar(
          "Error",
          "This user does not exist",
          R.colors.themeMud,
        );
      }
      return false;
    }
  }

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
    await FbCollections.user.doc(userModel!.uid).update({
      "image_url": imageUrl,
    });
    update();
    return imageUrl;
  }

  Future<String> uploadHostDocument(File pickedImage) async {
    var imageUrl = await ImagePickerServices().uploadSingleImage(
      pickedImage,
      bucketName: "hostDocuments",
      extension: ".pdf",
    );
    await FbCollections.user.doc(userModel!.uid).update({
      "host_document_url": imageUrl,
    });
    update();
    return imageUrl;
  }

  updateUsernameDataToDB(String username) async {
    await FbCollections.user.doc(userModel!.uid).update({"username": username});
    update();
  }

  Future<bool> updateUser(
    UserModel? userModel, {
    bool? showLoading = true,
  }) async {
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
      log("updateUser: " + e.toString());
    }
    return proceed;
  }

  Future<void> fetchUser() async {
    try {
      log("___HERE IN STREAM:${firebaseAuthService.currentUserId}");
      print(firebaseAuthService.currentUserId);

      var ref =
          FbCollections.user
              .doc(firebaseAuthService.currentUserId)
              .snapshots()
              .asBroadcastStream();

      currentUserStream ??
          ref.listen((event) async {
            if (event.exists) {
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
              print("ab toh wapis jaane wale hai");
              print(userModel!.toJson());
              getUserWallet();
              notifyListeners();
            } else {
              print("User not found");
            }
          });
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log("fetchUser: " + e.toString());
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
      await firebaseAuthService.signOut();
      stopLoader();
    } catch (e) {
      stopLoader();
      debugPrintStack();
      log("logoutUser: " + e.toString());
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
      log("cancleStreams: " + e.toString());
    }
  }

  Future<void> updateEmailAndPhoneNumber(
    String email,
    String phoneNumber,
    String counntryCode,
  ) async {
    try {
      startLoader();
      String dialCode =
          counntryCode.startsWith('+')
              ? counntryCode
              : CountryCodeConverter.getDialCode(counntryCode);
      userModel?.email = email;
      userModel?.number = phoneNumber;
      userModel?.dialCode = dialCode;
      userModel?.phoneNumber = "$dialCode$phoneNumber";
      final userId = userModel?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update({
              "email": email,
              "number": phoneNumber,
              "dial_code": dialCode,
              "phone_number": "$dialCode$phoneNumber",
            });
        await firebaseAuthService.updateEmail(email);
        // Phone update needs verification, handle separately
        notifyListeners();
      } else {
        throw Exception("User ID is null, cannot update user data");
      }
      stopLoader();
    } catch (e) {
      stopLoader();
      print("Error updating email and phone number: $e");
      rethrow;
    }
  }

  void setUsernameAvailable(bool isAvailable) {
    usernameIsAvailable = isAvailable;
    notifyListeners();
  }

  Future<void> verifyOtpForUsernameChange(
    String countryCode,
    String number,
    String code,
    String newUsername,
  ) async {
    try {
      startLoader();
      print('loader started');

      if (_usernameChangeVerificationId == null) {
        throw Exception("Verification ID not found. Please request OTP again.");
      }

      await firebaseAuthService.verifyOTP(code, verificationId: _usernameChangeVerificationId);
      print('sms verified');
      await firebaseAuthService.reloadUser();
      print('user fetched');
      print("Otp verified and username updated successfully");
      ZBotToast.loadingClose();
      await updateUsernameDataToDB(newUsername);
      _usernameChangeVerificationId = null; // Clear after use
    } catch (e) {
      Fluttertoast.showToast(msg: "$e");
      debugPrintStack();
      log("verifyOtpForUsernameChange: ${e.toString()}");
      stopLoader();
    }
  }

  Future<void> sendOtpForUsernameChange(
    String countryCode,
    String number,
  ) async {
    try {
      startLoader();
      String dialCode = CountryCodeConverter.getDialCode(countryCode);
      String formattedPhone = "$dialCode$number";
      print("Formatted Phone: $formattedPhone");

      await firebaseAuthService.sendOTP(
        formattedPhone,
        onCodeSent: (verificationId) {
          _usernameChangeVerificationId = verificationId;
          print("OTP sent successfully");
          stopLoader();
        },
        onError: (error) {
          Fluttertoast.showToast(msg: "Failed to send OTP: $error");
          stopLoader();
        },
      );
    } catch (e) {
      debugPrintStack();
      log("sendOtpForUsernameChange: Error sending OTP: $e");
      stopLoader();
      Fluttertoast.showToast(msg: "Failed to send OTP: $e");
    }
  }
}
