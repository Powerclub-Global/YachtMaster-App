

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/model/notification_model.dart';

class InboxVm extends ChangeNotifier {

  List<NotificationModel> hostNotificationsList=[];
  StreamSubscription<List<NotificationModel>>? notificationStream;

  Future<void> fetchNotificatoins() async {
    log("/////////////////////IN FETCH Notifications");
    hostNotificationsList=[];
    var ref =  FbCollections.notifications.orderBy("created_at", descending: true)
        .snapshots()
        .asBroadcastStream();
    var res = ref.map((list) => list.docs.map((e) => NotificationModel.fromJson(e.data())).toList());
    try {
      notificationStream ??= res.listen((allnotifications) async {
        if (allnotifications.isNotEmpty) {
          hostNotificationsList = allnotifications.where((element) => element.receiver?.contains(FirebaseAuth.instance.currentUser?.uid)==true).toList();
          notifyListeners();
          log("//////////////////////////////////////////////HOST NOTIFICATIONS :${hostNotificationsList.length}");
        }
        notifyListeners();
      });
    } on Exception catch (e) {
      // TODO
      log(e.toString());
    }
    notifyListeners();
  }
  //  Create Chat Head
  Future<ChatHeadModel?> createChatHead(ChatHeadModel chatData) async {
    ChatHeadModel? chatHeadModel;
    try {
      DocumentSnapshot doc = await FbCollections.chatHeads.doc(chatData.id).get();

      if (doc.data() == null) {
        await FbCollections.chatHeads.doc(chatData.id).set(chatData.toJson());
        doc=  await FbCollections.chatHeads.doc(chatData.id).get();
      } else {

      }
      chatHeadModel = ChatHeadModel.fromJson(doc.data());
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
    notifyListeners();
    return chatHeadModel;
  }


  update()
  {
    notifyListeners();
  }
}
