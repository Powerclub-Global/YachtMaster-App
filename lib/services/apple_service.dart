// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';

import '../src/auth/view_model/auth_vm.dart';
import '../utils/zbot_toast.dart';


class AuthWithApple {
  var p = Provider.of<AuthVm>(Get.context!, listen: false);
  Future<User?> apple() async {
    try {
      User? user;
      bool internet = await CheckInternetService.checkInternet();
      if (!internet) {
        ZBotToast.showToastError(message: "No Internet Connection");
      }
      else {
        final AuthorizationCredentialAppleID credential =
        await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ],
        );

        ZBotToast.loadingShow();
        UserModel userData = UserModel(
          createdAt: Timestamp.now(),
          email: credential.email ?? "",
          firstName: credential.givenName ?? "",
        );
        log("____FIRST NAME:${credential.givenName}");
        OAuthCredential oauthCredential = OAuthProvider("apple.com").credential(
          idToken: credential.identityToken,
          accessToken: credential.authorizationCode,
        );

        UserCredential? userCredential = await signInWithSocial(oauthCredential);
        user = userCredential!.user;


        p.appleUserName=credential.givenName?.contains(" ")==true?credential.givenName?.split(" ").first??"":credential.givenName;
        p.appleUserEmail=credential.email;
        p.update();
      }
      return user;
    } on Exception catch (e) {
      log("ERR:${e.toString()}");

    }
  }
  Future<UserCredential?> signInWithSocial(AuthCredential credential) async {
    try {
      var user = (await FirebaseAuth.instance.signInWithCredential(credential));
      return user;
    } catch (e) {
      ZBotToast.loadingClose();
      String error = e.toString();
      log("sign in error $e");
      if(error.contains('network-request-failed')){
        ZBotToast.showToastError(message: "No or poor internet connection");
      }else
      if (error.contains("too-many-requests")) {
        ZBotToast.showToastError(message: "This Device is blocked for some time due to unusual activity.");
      } else if (error.contains("wrong-password")) {
        ZBotToast.showToastError(message: "ENTER CORRECT PASSWORD");
      } else if (error.contains("user-not-found")) {
        ZBotToast.showToastError(message: "No User found against this email.");
      }
      return null;
    }
  }
}


class CheckInternetService {
  static Future<bool> checkInternet() async {
    // return Future.value(true);
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('connected');
        return true;
      }
    } on SocketException catch (_) {
      debugPrint('not connected');
      return false;
    }
    return false;
  }
}
