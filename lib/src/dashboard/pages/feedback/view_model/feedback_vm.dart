// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/model/reports_data.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';

import '../../users/view_model/user_vm.dart';

class FeedbackVm extends ChangeNotifier {
  int selectedIndex = 0;
  int reportTypeIndex = 0;
  TextEditingController searchController = TextEditingController();
  TextEditingController reportTypeController = TextEditingController();
  List<AppFeedbackModel> feedbacList = [];
  void update() {
    notifyListeners();
  }

  List<AppFeedbackModel> reportTypeData = [];

  // Future<void> getReportsTypes() async {
  //   try {
  //     reportTypeData.clear();
  //     var querySnapshot = await FBCollections.appSettings.doc('report_types').get();
  //     ReportTypeResponseModel reportTypeResponseModel = ReportTypeResponseModel.fromJson(querySnapshot.data());
  //     for (var element in reportTypeResponseModel.list ?? []) {
  //       reportTypeData.add(element);
  //     }
  //     notifyListeners();
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }
  //
  // Future<void> updateReportTypes() async {
  //   try {
  //     ReportTypeResponseModel reportTypeResponseModel = ReportTypeResponseModel(list: reportTypeData);
  //     await FBCollections.appSettings.doc('report_types').update(reportTypeResponseModel.toJson());
  //     notifyListeners();
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  Future<void> getAllFeedback() async {
    try {
      log("___users:${Get.context!.read<UserVM>().userList.length}");
      QuerySnapshot q = await FBCollections.feedback.get();
      feedbacList = q.docs.map<AppFeedbackModel>((e) => AppFeedbackModel.fromJson(e.data())).toList();
      for (var element in feedbacList) {
        element.pricture =
            Get.context!.read<UserVM>().userList.firstWhereOrNull((e) => e.uid == element.userId)?.imageUrl;
        element.userName =
            Get.context!.read<UserVM>().userList.firstWhereOrNull((e) => e.uid == element.userId)?.firstName;
        element.phoneNumber =
            Get.context!.read<UserVM>().userList.firstWhereOrNull((e) => e.uid == element.userId)?.phoneNumber;
      }

      notifyListeners();
    } catch (e) {
      ZBotToast.loadingClose();
      log("ERROR $e");
    }
  }

  Future<bool> updateReport(AppFeedbackModel feedbackModel) async {
    bool proceed = false;

    try {
      await FBCollections.feedback.doc(feedbackModel.id).set(feedbackModel.toJson());
      proceed = true;
      notifyListeners();
    } catch (e) {
      log(e.toString());
    }
    return proceed;
  }
}
