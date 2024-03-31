

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/auth/view/auth_view.dart';
import 'package:yacht_master_admin/src/auth/vm/auth_vm.dart';
import 'package:yacht_master_admin/src/dashboard/view/base_view.dart';

class SplashView extends StatefulWidget {
  static String route = '/splash_view';
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController animationController1;
  late AnimationController animationController2;
  late Animation<double> opacityAnimation;
  late  Animation<double> scaleLogo;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
    animationController1 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    animationController2 = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    opacityAnimation = CurvedAnimation(
      parent: animationController1,
      curve: Curves.ease,
      // Curves.fastOutSlowIn,
    );
    scaleLogo = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: animationController2,
      curve: Curves.easeIn,
    ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    animationController1.forward().whenComplete(() => animationController2.forward().whenComplete((){
      AuthVM authVM = Provider.of<AuthVM>(context, listen: false);
      Future.delayed(const Duration(milliseconds: 1000), () {
        authVM.userSubscription = FirebaseAuth.instance.authStateChanges().listen((event) {
              if (event?.email != null) {
                debugPrint(event!.email.toString());
                Get.offAllNamed(DashboardView.route);
              } else {
                Get.offAllNamed(AuthView.route);
              }
            });
      });
      Get.offAllNamed(AuthView.route);

    }));
    return Scaffold(
      backgroundColor: R.colors.primary,
      body: Center(
        child: ScaleTransition(
          scale:scaleLogo,
          child: ScaleTransition(
            scale: opacityAnimation,
            child: Image.asset(
              R.images.splashIcon,
              scale: 5,
            ),
          ),
        ),
      ),
    );
  }

}
