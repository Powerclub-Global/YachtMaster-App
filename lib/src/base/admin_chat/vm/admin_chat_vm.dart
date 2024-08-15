import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../services/firebase_collections.dart';
import '../model/admin_chat_model.dart';

import '../../../../utils/zbot_toast.dart';
import '../model/admin_chat_head_model.dart';

class AdminChatVM extends ChangeNotifier {
  void startLoader() {
    ZBotToast.loadingShow();
    update();
  }

  void stopLoader() {
    ZBotToast.loadingClose();
    update();
  }
  List<AdminChatHeadModel> allChatHeadsList = [];

  Future<void> getAllChatHeads() async {
    try {
      QuerySnapshot q = await FbCollections.adminChat.get();
      allChatHeadsList = q.docs
          .map<AdminChatHeadModel>((e) => AdminChatHeadModel.fromJson(e.data()))
          .toList();
      log("_____CHAT:${allChatHeadsList.length}");
    } on Exception catch (e) {
      stopLoader();
      debugPrint(e.toString());
      debugPrintStack();
    }
  }
  Future<void> setLastMessage(
      {required AdminChatModel lastMessage, required String id}) async {
    try {
      var ref = FbCollections.message(id).doc();
      ref
          .set(lastMessage.toJson())
          .then((value) => FbCollections.adminChat.doc(id).update({
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
