import 'dart:async';
import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/services/firebase_auth.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/model/user_data.dart';
import 'package:yacht_master_admin/src/dashboard/vm/base_vm.dart';

import '../../../constants/fb_collections.dart';
import '../../../utils/z_bot/zbot_toast.dart';
import '../../dashboard/view/base_view.dart';
import '../view/auth_view.dart';

class AuthVM extends ChangeNotifier {
  final BaseAuth _auth = Auth();
  StreamSubscription? userSubscription;
  UserModel userData = UserModel();

  Future<void> fetchUser() async {
    try {
      userData=UserModel();
      DocumentSnapshot snapshot = await FBCollections.users.doc(FirebaseAuth.instance.currentUser?.uid??"").get();
      userData = UserModel.fromJson(snapshot.data());
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }


  Future<void> signIn(String email, String pass) async {
    try {
      ZBotToast.loadingShow();
      User? user = await _auth.signInWithEmailPassword(email, pass);
      if (user != null) {
        if (email.toLowerCase() == "admin@yachtmaster.com") {
          Get.offAllNamed(DashboardView.route);
        } else {
          _auth.signOut();
          ZBotToast.showToastError(
              message: LocalizationMap.getTranslatedValues(
                  "you_are_not_allowed_to_login"));
        }
      }
      ZBotToast.loadingClose();
    } catch (e) {
      String error = e.toString().split(']').toList().last;
      ZBotToast.showToastError(message: error);
      ZBotToast.loadingClose();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      ZBotToast.loadingShow();
      await _auth.sendResetPassEmail(email).then((value) {
        Get.back();
        ZBotToast.showToastSuccess(
            message: LocalizationMap.getTranslatedValues(
                "password_reset_link_sent"));
      });
      ZBotToast.loadingClose();
    } catch (e) {
      String error = e.toString().split(']').toList().last;
      ZBotToast.showToastError(message: error);
      ZBotToast.loadingClose();
    }
  }

  Future<void> logout() async {
    try {
      ZBotToast.loadingShow();
      await _auth.signOut().then((value) {
        Get.context!.read<BaseVm>().selectedIndex = 0;
        Get.context!.read<BaseVm>().pageController.jumpToPage(0);
        return Get.offAllNamed(AuthView.route);

      });
      ZBotToast.loadingClose();
    } catch (e) {
      String error = e.toString().split(']').toList().last;
      debugPrintStack();
      ZBotToast.showToastError(message: error);
      ZBotToast.loadingClose();
    }
  }

  void update() {
    notifyListeners();
  }
}
