import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yacht_master_admin/src/dashboard/pages/chat/model/chat_model.dart';

import '../../../../../constants/fb_collections.dart';
import '../../../../../utils/z_bot/zbot_toast.dart';
import '../model/chat_head_model.dart';

class ChatVM extends ChangeNotifier {
  void startLoader() {
    ZBotToast.loadingShow();
    update();
  }

  void stopLoader() {
    ZBotToast.loadingClose();
    update();
  }
  List<ChatHeadModel> allChatHeadsList = [];

  Future<void> getAllChatHeads() async {
    try {
      QuerySnapshot q = await FBCollections.chatHeads.get();
      allChatHeadsList = q.docs
          .map<ChatHeadModel>((e) => ChatHeadModel.fromJson(e.data()))
          .toList();
      log("_____CHAT:${allChatHeadsList.length}");
    } on Exception catch (e) {
      stopLoader();
      debugPrint(e.toString());
      debugPrintStack();
    }
  }
  Future<void> setLastMessage(
      {required ChatModel lastMessage, required String id}) async {
    try {
      var ref = FBCollections.message(id).doc();
      ref
          .set(lastMessage.toJson())
          .then((value) => FBCollections.chatHeads.doc(id).update({
        'last_message': lastMessage.toJson(),
      }));

      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
  }
  void update() {
    notifyListeners();
  }
}
