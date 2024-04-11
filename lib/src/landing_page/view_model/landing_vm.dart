import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/src/landing_page/view/splash_view.dart';

class LandingVm extends ChangeNotifier {
  goToLogin(BuildContext context) {
    Future.delayed(Duration(seconds: 4), () async {
      var yachtProvider = Provider.of<YachtVm>(Get.context!, listen: false);
      await yachtProvider.fetchCharters();
      await Provider.of<AuthVm>(context, listen: false).checkCurrentUser();
    });
  }

  goToSecondSplash() {
    Future.delayed(Duration(seconds: 1), () {
      log("________________________LOGIN");
      Get.to(Splash());
    });
  }
}
