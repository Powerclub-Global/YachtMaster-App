import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/model/notifications_data.dart';
import 'package:yacht_master_admin/utils/push_notifications.dart';

class BaseVm extends ChangeNotifier {
  int selectedIndex = 0;
  int filterIndex = 0;
  bool isMini = false;
  PageController pageController = PageController(initialPage: 0);

  void update() {
    notifyListeners();
  }

  //  SEND NOTIFICATION
  Future<bool> sendNotification(
      {required NotificationsData notificationData,
      required String userFCM,
      bool? isSendPush = true,
      bool? isSendInApp = true}) async {
    bool proceed = false;
    try {
      if (isSendInApp!) {
        DocumentReference ref = FBCollections.notifications.doc();
        notificationData.id = ref.id;
        await ref.set(notificationData.toJson());
      }
      if (isSendPush!) {
        PushNotification.sendNotification(
            fcmToken: userFCM, title: "Yacht Master APP", body: notificationData.notification ?? "");
      }
      proceed = true;
    } catch (e) {
      log(e.toString());
    }
    notifyListeners();
    return proceed;
  }
}
