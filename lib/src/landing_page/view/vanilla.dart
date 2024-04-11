import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';

class Vanilla extends StatelessWidget {
  const Vanilla({super.key});
  static String route = "/";
  routeToYacht() async {
    String yachtId = Get.parameters['yachtId']!;
    var yachtProvider = Provider.of<YachtVm>(Get.context!, listen: false);
    List<CharterModel> test = yachtProvider.allCharters.where((element) {
      return element.id == yachtId;
    }).toList();
    print("Printing Test");
    CharterModel yacht = test[0];
    int index = yachtProvider.allCharters
        .indexWhere((element) => element.id == yachtId);
    Get.offNamed(CharterDetail.route, arguments: {
      "yacht": yacht,
      "isReserve": false,
      "index": index,
      "isEdit": yacht.createdBy == FirebaseAuth.instance.currentUser?.uid
          ? true
          : false,
      "isLink": true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: routeToYacht(),
        builder: ((context, snapshot) {
          return SizedBox();
        }));
  }
}
