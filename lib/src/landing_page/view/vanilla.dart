import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/stripe/stripe_service.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class Vanilla extends StatefulWidget {
  const Vanilla({super.key});
  static String route = "/";

  @override
  State<Vanilla> createState() => _VanillaState();
}

Future<void> handleReturnRedirectFromStripeAccountLink(
    BuildContext context, String status) async {
  if (status == "refresh") {
    Get.dialog(AlertDialog(
        content: Text(getTranslated(context, "onboarding_refresh")!)));
  } else {
    Get.dialog(AlertDialog(
        content: Text(getTranslated(context, "onboarding_return")!)));
    await Future.delayed(Duration(seconds: 2), () {
      ZBotToast.loadingShow();
    });
    StripeService stripe = StripeService();
    var authVm = Provider.of<AuthVm>(context, listen: false);
    var connectedAccount = await FbCollections.connected_accounts
        .where('uid', isEqualTo: authVm.userModel!.uid)
        .get();
    if (connectedAccount.docs.isNotEmpty) {
      Map<String, dynamic> connected_account_id_data =
          connectedAccount.docs.first.data() as Map<String, dynamic>;
      String connectedAccountId = connected_account_id_data['account_id'];
      stripe.checkDetailsSubmitted(context, true, connectedAccountId);
    } else {
      ZBotToast.loadingClose();
      Get.dialog(AlertDialog(
          content:
              Text(getTranslated(context, "return_non_exsistant_account")!)));
    }
  }
}

class _VanillaState extends State<Vanilla> {
  routeToYacht() async {
    print("here recieved the url");
    if (Get.parameters['yachtId'] != null) {
      String yachtId = Get.parameters['yachtId']!;
      var yachtProvider = Provider.of<YachtVm>(Get.context!, listen: false);
      List<CharterModel> test = yachtProvider.allCharters.where((element) {
        return element.id == yachtId;
      }).toList();
      print("Printing Test");
      CharterModel yacht = test[0];
      int index = yachtProvider.allCharters
          .indexWhere((element) => element.id == yachtId);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Get.toNamed(CharterDetail.route, arguments: {
          "yacht": yacht,
          "isReserve": false,
          "index": index,
          "isEdit": yacht.createdBy == FirebaseAuth.instance.currentUser?.uid
              ? true
              : false,
          "isLink": true,
        });
      });
      String? senderId = Get.parameters["from"];
      var inviteData = {
        'from': senderId,
        'to': FirebaseAuth.instance.currentUser?.uid
      };
      await FbCollections.invites.add(inviteData);
    }
    if (Get.parameters['status'] != null) {
      await handleReturnRedirectFromStripeAccountLink(
          context, Get.parameters['status']!);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      routeToYacht();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.black,
      body: Center(
          child: Text(
        getTranslated(context, "routing")!,
        style: TextStyle(color: Colors.white),
      )),
    );
  }
}
