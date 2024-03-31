import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master_admin/constants/enums.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/src/auth/vm/auth_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/model/user_data.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';

import '../model/charter_model.dart';
import '../model/service_model.dart';
import '../model/yacht_model.dart';

class UserVM extends ChangeNotifier {
  int selectedIndex = 0;
  TextEditingController searchController = TextEditingController();

  List<UserModel> userList = [];

  Future<void> getAllUsers() async {
    try {
      QuerySnapshot q = await FBCollections.users
          .where("role", isEqualTo: UserType.user.index)
          .get();
      userList = q.docs.map<UserModel>((e) => UserModel.fromJson(e.data())).toList();

      notifyListeners();
    } catch (e) {
      ZBotToast.loadingClose();
      log("ERROR $e");
    }
  }

  List<CharterModel> allCharters=[];

  Future<void> fetchCharters() async {

    try {
      allCharters=[];
      QuerySnapshot ref =await FBCollections.charterFleet.get();
      if (ref!=null && ref.docs.isNotEmpty) {
        allCharters=ref.docs.map((e) =>  CharterModel.fromJson(e.data())).toList();
        allCharters = allCharters.where((element) =>  element.status==CharterStatus.active.index).toList();
        notifyListeners();
        log("//////////////////////All Charters :${allCharters.length}____");
      }
      notifyListeners();
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
  }
  List<YachtsModel> allYachts = [];

  Future<void> fetchYachts() async {
    try {
      log("/////////////////////IN FETCH Yachts");
      allYachts=[];
      QuerySnapshot ref =await FBCollections.yachtForSale.get();
      if (ref!=null && ref.docs.isNotEmpty) {
        allYachts=ref.docs.map((e) =>  YachtsModel.fromJson(e.data())).toList();
        allYachts=allYachts.where((element) => element.status==0).toList();
        notifyListeners();
        log("//////////////////////////////////////////////All YACHT :${allYachts.length}/////");
      }

      notifyListeners();
    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
  }
  List<ServiceModel> allServicesList=[];

  Future<void> fetchServices() async {
    log("/////////////////////IN FETCH Services");
    allServicesList=[];
    QuerySnapshot ref = await  FBCollections.services.get();
    try {
      allServicesList=ref.docs.map((e) =>  ServiceModel.fromJson(e.data())).toList();
      allServicesList=allServicesList.where((element) => element.status==0).toList();

    } on Exception catch (e) {
      // TODO
      debugPrintStack();
      log(e.toString());
    }
    notifyListeners();
  }


  void resetUser() {
    selectedIndex = 0;
    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}
