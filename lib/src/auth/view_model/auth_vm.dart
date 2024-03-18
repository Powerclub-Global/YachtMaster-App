import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yacht_master/constant/constant.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/image_picker_services.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view/social_signup.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/wallet_model.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';

import '../../../resources/resources.dart';
import '../../../services/apple_service.dart';
import '../../../utils/helper.dart';
import '../view/login.dart';
import '../widgets/otp_dialog.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class AuthVm extends ChangeNotifier {
  bool isLoading = false;
  UserModel? userModel;
  String? appleUserName;
  String? appleUserEmail;
  WalletModel? wallet;
  StreamSubscription<DocumentSnapshot<UserModel>>? currentUserStream;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth auth = FirebaseAuth.instance;
  StreamSubscription<List<WalletModel>>? walletStream;
  startLoader() {
    isLoading = true;
    notifyListeners();
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
        await chechUserCollectionExists("${countryCode}${phoneNumController}");
    print("..................................USER EXIST:$isUserExist");
    if (isUserExist == false) {
      Helper.inSnackBar('Error', "This user does not exist", R.colors.themeMud);
      ZBotToast.loadingClose();
    } else {
      await signInWithOtp(countryCode, phoneNumController);
    }
  }

  onClickGoogleLogin() async {
    try {
      startLoader();
      await signInWithGoogle().then((User user) async {
        bool isUserExist = false;
        isUserExist = await chechUserCollectionExists(user.uid, isEmail: true);
        if (isUserExist == true) {
          await fetchUser();
          Future.delayed(Duration(seconds: 2), () async {
            if (userModel != null) {
              if (userModel?.status == UserStatus.blocked) {
                GoogleSignIn().signOut();
                FirebaseAuth.instance.signOut();
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
              arguments: {"user": user, "isApple": false});
        }
      });
    } on FirebaseAuthException catch (e) {
      log("THIS IS ERRROR$e");
      Fluttertoast.showToast(msg: "${e}");
      if (FirebaseAuth.instance.currentUser != null) {
        logoutUser();
      }
    }
  }

  onClickAppleLogin() async {
    try {
      startLoader();
      await AuthWithApple().apple().then((User? user) async {
        if (user != null) {
          bool isUserExist = false;
          isUserExist =
              await chechUserCollectionExists(user.uid, isEmail: true);
          if (isUserExist == true) {
            await fetchUser();
            Future.delayed(Duration(seconds: 2), () async {
              if (userModel != null) {
                if (userModel?.status == UserStatus.blocked) {
                  FirebaseAuth.instance.signOut();
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
                arguments: {"user": user, "isApple": true});
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      log("THIS IS ERRROR$e");
      Fluttertoast.showToast(msg: "${e}");
      if (FirebaseAuth.instance.currentUser != null) {
        logoutUser();
      }
    }
  }

  onClickSignup(String email, String firstName, String lastName,
      String countryCode, String phoneNumController, bool isSocialLogin) async {
    log("____HERE");
    bool isUserExist =
        await chechUserCollectionExists("${countryCode}${phoneNumController}");

    if (isUserExist == true) {
      Helper.inSnackBar('Error', "User already exist", R.colors.themeMud);
      stopLoader();
      return;
    } else {
      await signupWithOtp(countryCode, phoneNumController, email, firstName,
          lastName, isSocialLogin);

      // authPro.numberController.clear();
    }
  }

  onClickSocialSignup(User? user, String countryCode, String phoneNumController,
      bool isSocialLogin,
      {bool isApple = false}) async {
    bool isUserExist =
        await chechUserCollectionExists("${countryCode}${phoneNumController}");

    if (isUserExist == true) {
      Helper.inSnackBar('Error', "User already exist", R.colors.themeMud);
      stopLoader();
    } else {
      startLoader();
      log("____USER display name:${user?.displayName}");

      await registerUserGoogle(
          user!, countryCode, phoneNumController, isSocialLogin,
          isApple: isApple);
    }
  }

  checkCurrentUser() async {
    try {
      log("////////////////in check current user");
      User? user = auth.currentUser;
      if (user?.phoneNumber?.isNotEmpty == true) {
        await fetchUser();
        Future.delayed(Duration(seconds: 2), () async {
          if (Constants.fcmToken.isEmpty) {
            print("Hi bro");

            // userModel?.fcm = await FirebaseMessaging.instance.getToken();
          } else {
            userModel?.fcm = Constants.fcmToken;
          }
          if (userModel != null) {
            if (userModel?.status == UserStatus.blocked) {
              GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(msg: "You have been blocked by admin");
            } else {
              userModel?.fcm = Constants.fcmToken;
              // userModel?.isActiveUser = true;
              await updateUser(userModel);
              ZBotToast.loadingClose();
              Get.offAllNamed(BaseView.route);
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
    print(
        "==========In FETCH USER WALLET:${FirebaseAuth.instance.currentUser!.uid}");
    var ref = await FbCollections.wallet.snapshots().asBroadcastStream();
    var res = ref.map((list) =>
        list.docs.map((e) => WalletModel.fromJson(e.data())).toList());

    try {
      walletStream ??= res.listen((event) async {
        log("____len:${event.length}");
        if (event.isNotEmpty) {
          walletModel = event.firstWhereOrNull((element) =>
              element.uid == FirebaseAuth.instance.currentUser?.uid);
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
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"amount": amount});
      await getUserWallet();
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  Future<User> signInWithGoogle() async {
    googleSignIn.signOut();
    log("__________________IN GOOGLE SIGN IN");
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential authResult = await auth.signInWithCredential(credential);

    User? user = authResult.user;

    assert(!user!.isAnonymous);

    assert(await user!.getIdToken() != null);

    User? currentUser = auth.currentUser;
    Get.forceAppUpdate();
    assert(user!.uid == currentUser!.uid);
    var p = Provider.of<AuthVm>(Get.context!, listen: false);

    p.userModel?.firstName = user?.displayName?.split(" ").first;
    p.userModel?.lastName = user?.displayName?.split(" ").first;
    log("____USER here:${user?.displayName}");

    p.update();
    return user!;
  }

  Future registerUserGoogle(
      User user, String countryCode, String number, bool isSocialLogin,
      {bool isApple = false}) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: "${countryCode} ${number}",
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential authCredential) async {
            UserCredential? userCredential =
                await linkPhoneNumber(authCredential);
            if (userCredential != null) {
              log("____USER:${user.displayName}");
              await setSignupUserData(
                      user,
                      countryCode,
                      number,
                      isApple ? appleUserEmail ?? "" : user.email!,
                      isApple
                          ? appleUserName ?? ""
                          : user.displayName?.contains(" ") == true
                              ? user.displayName?.split(" ").first ?? ""
                              : user.displayName ?? "",
                      user.displayName?.contains(" ") == true
                          ? user.displayName?.split(" ").last ?? ""
                          : "",
                      isSocialLogin)
                  .then((value) async {
                log("///////////////////////////CODE VERIFIED");

                await fetchUser();
                if (userModel?.status == UserStatus.blocked) {
                  GoogleSignIn().signOut();
                  FirebaseAuth.instance.signOut();
                  Fluttertoast.showToast(msg: "You have been blocked by admin");
                } else {
                  userModel?.fcm = Constants.fcmToken;
                  // userModel?.isActiveUser = true;
                  await updateUser(userModel);
                  ZBotToast.loadingClose();
                  Get.offAllNamed(BaseView.route);
                }
              });
            }
          },
          verificationFailed: (authException) {
            if (authException.message!.contains("17010")) {
              Fluttertoast.showToast(
                  msg:
                      "This request is missing a valid app identifier, meaning that neither SafetyNet checks nor reCAPTCHA checks succeeded. Please try again, or check the logcat for more details.");
            } else if (authException.message!
                .contains("We have blocked all requests")) {
              Fluttertoast.showToast(
                  msg:
                      "We have blocked all requests from this device due to unusual activity. Try again later.");
            } else if (authException.message!.contains(
                "The format of the phone number provided is incorrect")) {
              Fluttertoast.showToast(
                  msg: "The format of the phone number provided is incorrect.");
              log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            } else {
              Fluttertoast.showToast(msg: authException.message!);
              log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            }
            // dashPro.stopLoginLoader();

            log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            stopLoader();
          },
          codeSent: (String verificationId, [int? forceResendingToken]) {
            //show dialog to take input from the user
            log("_______________________WHEN COMP");
            stopLoader();
            Get.dialog(
                OTP("${countryCode} ${number}", true, (otpCode) async {
                  startLoader();
                  await verifySignUpOtpGoogle(
                          user, countryCode, verificationId, number, otpCode,
                          isApple: isApple)
                      .whenComplete(() {
                    stopLoader();
                  });
                }, () async {
                  startLoader();
                  await registerUserGoogle(
                      user, countryCode, number, isSocialLogin,
                      isApple: isApple);
                }),
                barrierDismissible: true,
                barrierColor: Colors.grey.withOpacity(.25));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
            log(verificationId);
            log("Timeout");
          });
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

  verifySignUpOtpGoogle(User user, String countryCode, String verificationId,
      String number, String code,
      {bool isApple = false, bool isSocialLogin = false}) async {
    startLoader();

    AuthCredential _credential;

    _credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: code);

    await linkPhoneNumber(_credential).then((cred) async {
      log("___CRED:${cred}___USER:${user}");
      if (cred != null) {
        await setSignupUserData(
                user,
                countryCode,
                number,
                isApple ? appleUserEmail ?? "" : user.email!,
                isApple
                    ? appleUserName ?? ""
                    : user.displayName?.contains(" ") == true
                        ? user.displayName?.split(" ").first ?? ""
                        : user.displayName ?? "",
                user.displayName?.contains(" ") == true
                    ? user.displayName?.split(" ").last ?? ""
                    : "",
                isSocialLogin)
            .then((value) async {
          log("///////////////////////////CODE VERIFIED");

          await fetchUser();
          if (userModel?.status == UserStatus.blocked) {
            GoogleSignIn().signOut();
            FirebaseAuth.instance.signOut();
            Fluttertoast.showToast(msg: "You have been blocked by admin");
          } else {
            userModel?.fcm = Constants.fcmToken;
            // userModel?.isActiveUser = true;
            await updateUser(userModel);
            ZBotToast.loadingClose();
            Get.offAllNamed(BaseView.route);
          }
        });
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

  Future<User?> signInWithFb() async {
    try {
      startLoader();
      final LoginResult loginResult = await FacebookAuth.instance
          .login(permissions: ['email', 'public_profile', 'user_birthday']);
      final OAuthCredential fbAuthCredentials =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);
      UserCredential? credential =
          await FirebaseAuth.instance.signInWithCredential(fbAuthCredentials);
      stopLoader();
      return credential.user;
    } catch (e) {
      stopLoader();
      Fluttertoast.showToast(msg: e.toString());
      return null;
    }
  }

  signInWithOtp(String countryCode, String number) async {
    print("+++++++++++++++++++++++++++++++MOBILE:${countryCode} ${number}");
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: "${countryCode} ${number}",
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential authCredential) async {
            print("////////////////AUTH CRED$authCredential");
            await auth
                .signInWithCredential(authCredential)
                .then((result) async {
              if (result.user != null) {
                await fetchUser();
                Future.delayed(Duration(seconds: 2), () async {
                  if (userModel?.status == UserStatus.blocked) {
                    GoogleSignIn().signOut();
                    FirebaseAuth.instance.signOut();
                    Fluttertoast.showToast(
                        msg: "You have been blocked by admin");
                  } else {
                    userModel?.fcm = Constants.fcmToken;
                    // userModel?.isActiveUser = true;
                    await updateUser(userModel);
                    ZBotToast.loadingClose();
                    Get.offAllNamed(BaseView.route);
                  }
                });
              }
            }).catchError((e) {
              log("++++++++++++++++++++++++++++++++++$e");
              if (e.toString().contains("firebase_auth/session-expired")) {
                Fluttertoast.showToast(
                    msg:
                        "The sms code has expired. Please re-send the verification code to try again.");
              } else if (e
                  .toString()
                  .contains("firebase_auth/invalid-verification-code")) {
                Helper.inSnackBar("Error", "Wrong OTP", R.colors.themeMud);
              } else {
                Fluttertoast.showToast(msg: "$e");
              }
              ZBotToast.loadingClose();

              // dashPro.stopOtpLoader();
            });
          },
          verificationFailed: (authException) {
            stopLoader();
            if (authException.message!.contains("17010")) {
              Fluttertoast.showToast(
                  msg:
                      "This request is missing a valid app identifier, meaning that neither SafetyNet checks nor reCAPTCHA checks succeeded. Please try again, or check the logcat for more details.");
            } else if (authException.message!
                .contains("We have blocked all requests")) {
              Fluttertoast.showToast(
                  msg:
                      "We have blocked all requests from this device due to unusual activity. Try again later.");
            } else if (authException.message!.contains(
                "The format of the phone number provided is incorrect")) {
              Fluttertoast.showToast(
                  msg: "The format of the phone number provided is incorrect.");
              log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            } else {
              Fluttertoast.showToast(msg: authException.message!);
              log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            }
            // dashPro.stopLoginLoader();

            log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
          },
          codeSent: (String verificationId, [int? forceResendingToken]) {
            log("___________CODE SENT:");
            Get.dialog(
                OTP("${countryCode} ${number}", false, (otpCode) async {
                  stopLoader();
                  await verifyOtp(
                      "", verificationId, countryCode, number, otpCode);
                }, () async {
                  await signInWithOtp(countryCode, number);
                }),
                barrierDismissible: true,
                barrierColor: Colors.grey.withOpacity(.25));
            // ZBotToast.loadingClose();
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
            log(verificationId);
            log("Timeout");
            Fluttertoast.showToast(msg: "Timeout");
          });
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
      String firstName, String lastName, bool isSocialLogin) async {
    try {
      await auth.verifyPhoneNumber(
          phoneNumber: "${countryCode} ${num}",
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential authCredential) async {
            print("////////////////AUTH CRED$authCredential");
            await auth
                .signInWithCredential(authCredential)
                .then((result) async {
              if (result.user != null) {
                await setSignupUserData(result.user!, countryCode, num, email,
                    firstName, lastName, isSocialLogin);

                Get.offAllNamed(BaseView.route);
              }
            });
          },
          verificationFailed: (authException) {
            if (authException.message!.contains("17010")) {
              Fluttertoast.showToast(
                  msg:
                      "This request is missing a valid app identifier, meaning that neither SafetyNet checks nor reCAPTCHA checks succeeded. Please try again, or check the logcat for more details.");
            } else if (authException.message!
                .contains("We have blocked all requests")) {
              Fluttertoast.showToast(
                  msg:
                      "We have blocked all requests from this device due to unusual activity. Try again later.");
            } else if (authException.message!.contains(
                "The format of the phone number provided is incorrect")) {
              Fluttertoast.showToast(
                  msg: "The format of the phone number provided is incorrect.");
              log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            } else {
              Fluttertoast.showToast(msg: authException.message!);
              log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            }

            log("+++++++++++++++++++++++++++++++++++++++++++++++++${authException.message}");
            stopLoader();
          },
          codeSent: (String verificationId, [int? forceResendingToken]) {
            //show dialog to take input from the user
            log("_______________________WHEN COMP");
            stopLoader();
            Get.dialog(
                OTP("${countryCode} ${num}", true, (otpCode) async {
                  startLoader();
                  await verifySignUpOtp(countryCode, verificationId, email,
                          firstName, lastName, num, otpCode, isSocialLogin)
                      .whenComplete(() {
                    stopLoader();
                  });
                }, () async {
                  startLoader();
                  await signupWithOtp(countryCode, num, email, firstName,
                          lastName, isSocialLogin)
                      .whenComplete(() {
                    stopLoader();
                  });
                }),
                barrierDismissible: true,
                barrierColor: Colors.grey.withOpacity(.25));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            verificationId = verificationId;
            log(verificationId);
            log("Timeout");
          });
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

  verifySignUpOtp(
      String countryCode,
      String verificationId,
      String email,
      String firstName,
      String lastName,
      String num,
      String code,
      bool isSocialLogin) async {
    try {
      startLoader();

      FirebaseAuth auth = FirebaseAuth.instance;
      AuthCredential _credential;
      log("////////////////////////VERIF ID${verificationId}");
      _credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      log("////////////////////////CRED${_credential}");
      await auth.signInWithCredential(_credential).then((result) async {
        if (result.user != null) {
          await setSignupUserData(result.user!, countryCode, num, email,
                  firstName, lastName, isSocialLogin)
              .then((value) async {
            log("///////////////////////////CODE VERIFIED:${FirebaseAuth.instance.currentUser!.uid}");
            Get.offAllNamed(
              BaseView.route,
            );
          });
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

  verifyOtp(String uid, String verificationId, String countryCode,
      String number, String code) async {
    try {
      startLoader();

      FirebaseAuth auth = FirebaseAuth.instance;
      AuthCredential _credential;
      log("////////////////////////VERIF ID${verificationId}");
      _credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      log("////////////////////////CRED${_credential}");

      await auth.signInWithCredential(_credential).then((result) async {
        if (result.user != null) {
          await fetchUser();
          Future.delayed(Duration(seconds: 2), () async {
            if (userModel?.status == UserStatus.blocked) {
              GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(msg: "You have been blocked by admin");
            } else {
              userModel?.fcm = Constants.fcmToken;
              // userModel?.isActiveUser = true;
              await updateUser(userModel);
              ZBotToast.loadingClose();
              Get.offAllNamed(BaseView.route);
            }
          });
        }
      }).catchError((e) {
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
    User user,
    String countryCode,
    String number,
    String email,
    String firstName,
    String lastName,
    bool isSocialLogin,
  ) async {
    try {
      bool isUserExist = false;

      isUserExist = await chechUserCollectionExists("${countryCode}${num}");
      log("/////////////////////////Current user in db:${isUserExist}................aut:${auth.currentUser}");

      if (isUserExist == false) {
        await FbCollections.user.doc(user.uid).set({
          "uid": user.uid,
          "created_at": Timestamp.now(),
          "email": email.replaceAll(' ', ''),
          "number": number,
          "dial_code": countryCode,
          "first_name": firstName,
          "last_name": lastName,
          "image_url": user.photoURL ?? R.images.dummyDp,
          "phone_number": "${countryCode}${number}",
          "fcm": Constants.fcmToken,
          "role": UserType.user.index,
          "status": UserStatus.active.index,
          "is_social_login": isSocialLogin,
          "request_status": RequestStatus.notHost.index
        });
        WalletModel walletModel = WalletModel(amount: 0.0, uid: user.uid);
        await FbCollections.wallet.doc(user.uid).set(walletModel.toJson());
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

  Future<UserCredential?> linkPhoneNumber(AuthCredential credential) async {
    try {
      UserCredential? cred = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);
      return cred;
    } catch (e) {
      log("++++++++++++++++++++++++++++++++++$e");
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
      debugPrintStack();
    }
    return null;
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

  updateProfileDataToDB(String firstName, String lastName) async {
    await FbCollections.user.doc(userModel!.uid).update({
      "first_name": firstName,
      "last_name": lastName,
    });
    update();
  }

  ///EDIT PROFILE
  onClickEditProfile(String firstName, String lastName, File? pickedImage,
      BuildContext context) async {
    startLoader();
    userModel?.firstName = firstName;
    userModel?.lastName = lastName;
    if (pickedImage != null) {
      userModel?.imageUrl = await uploadUserImage(pickedImage);
    }
    await updateProfileDataToDB(firstName, lastName);
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
      log("___HERE IN STREAM:${FirebaseAuth.instance.currentUser?.uid}");

      var ref = FbCollections.user
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots()
          .asBroadcastStream();

      currentUserStream ??
          ref.listen((event) async {
            if (event != null) {
              userModel = UserModel.fromJson(event.data());
              if (userModel?.status == UserStatus.blocked) {
                Get.offAllNamed(LoginScreen.route);
                await logoutUser(isUpdateUser: false);
                Fluttertoast.showToast(msg: "You have been blocked by admin");
              }
            }
          });
      log("User Data here:${userModel?.toJson()}");
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
      stopLoader();
      await FirebaseAuth.instance.signOut();
      await googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
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
