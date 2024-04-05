import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/settings/model/app_settings_data.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';

import '../../privacy_policy/model/content_model.dart';

class PictureVM extends ChangeNotifier {
  Future<void> changePassword(String oldPass, String newPass) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
    } else {
      AuthCredential cred = EmailAuthProvider.credential(
          email: FirebaseAuth.instance.currentUser?.email ?? "",
          password: oldPass);
      UserCredential uCred =
          await user.reauthenticateWithCredential(cred).catchError((error) {
        debugPrint(error.toString());
        var er = error.toString();
        if (er.contains("wrong-password")) {
          ZBotToast.showToastError(
              message: LocalizationMap.getTranslatedValues(
                  "please_provide_valid_password"));
        }
      });
      if (uCred.user?.email != null) {
        try {
          await user.updatePassword(newPass);
          ZBotToast.showToastSuccess(
              message: LocalizationMap.getTranslatedValues(
                  "password_changed_successfully"));
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  List<ContentModel> allContent = [];

  Future<void> fetchContent() async {
    log("/////////////////////IN FETCH CONTENT");
    try {
      allContent = [];
      QuerySnapshot snapshot = await FBCollections.content.get();
      if (snapshot.docs.isNotEmpty) {
        allContent =
            snapshot.docs.map((e) => ContentModel.fromJson(e.data())).toList();
        notifyListeners();
      }
      log("____CON;${allContent.length}");
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  Future<void> updateContent(
    String id,
    String text,
  ) async {
    try {
      ZBotToast.loadingShow();
      await FBCollections.content.doc(id).update({'content': text});
      ZBotToast.loadingClose();
      Get.back();
      ZBotToast.showToastSuccess(message: "Updated successfully!");
    } on Exception catch (e) {
      debugPrintStack();
      log(e.toString());
      ZBotToast.loadingClose();
    }
  }

  Future<void> updateServiceFee(
    double referralAmount,
    double serviceFee,
    double tax,
    double tip,
  ) async {
    try {
      ZBotToast.loadingShow();
      await FBCollections.taxes.doc("QzLc3PTHtXC6RrAMiPeh").update({
        "referral_amount": referralAmount,
        "service_fee": serviceFee,
        "taxes": tax,
        "tip": tip,
      });
      ZBotToast.loadingClose();
      Get.back();
      ZBotToast.showToastSuccess(message: "Updated successfully!");
    } on Exception catch (e) {
      debugPrintStack();
      log(e.toString());
      ZBotToast.loadingClose();
    }
  }

  void update() {
    notifyListeners();
  }
}
