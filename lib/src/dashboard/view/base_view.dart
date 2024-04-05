// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/src/auth/vm/auth_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/chat/view/chat_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/chat/vm/chat_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view/feedback_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/feedback/view_model/feedback_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/invites/view/invites_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/payment/view/payment_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/picture/view/picture_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/requests/view/request_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/service_tax/service_tax.dart';
import 'package:yacht_master_admin/src/dashboard/pages/settings/vm/settings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view/bookings_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view/user_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/terms_conditions/view/terms_conditions_view.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';
import 'package:yacht_master_admin/src/dashboard/refund_policy/view/refund_policy.dart';
import 'package:yacht_master_admin/src/landing_pages/view/splash_view.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../resources/resources.dart';
import '../cancellation_policy/view/cancellation_policy.dart';
import '../pages/dashboard/view/dashboard_home.dart';
import '../pages/privacy_policy/view/privacy_policy_view.dart';
import '../pages/settings/view/settings_view.dart';
import '../vm/base_vm.dart';
import 'widgets/side_bar_widget.dart';

class DashboardView extends StatefulWidget {
  static String route = '/DashboardView';
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var authVM = Provider.of<AuthVM>(context, listen: false);

      authVM.userSubscription =
          FirebaseAuth.instance.authStateChanges().listen((event) async {
        if (event?.email != null) {
          ZBotToast.loadingShow();
          await context.read<UserVM>().getAllUsers();
          await authVM.fetchUser();
          await context.read<SettingsVM>().fetchContent();
          await context.read<UserVM>().fetchCharters();
          await context.read<UserVM>().fetchServices();
          await context.read<UserVM>().fetchYachts();
          await context.read<BookingsVm>().fetchTaxes();
          await context.read<BookingsVm>().fetchAllBookings();
          await context.read<ChatVM>().getAllChatHeads();
          // await context.read<SettingsVM>().getAppSettingsData();
          await context.read<FeedbackVm>().getAllFeedback();
          ZBotToast.loadingClose();
        } else {
          Get.offAll(const SplashView());
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BaseVm>(builder: (context, baseVm, _) {
      return Scaffold(
        backgroundColor: R.colors.dividerColor,
        body: ResponsiveWidget(
          largeScreen: largeScreen(baseVm),
          mediumScreen: smallScreen(baseVm),
          smallScreen: smallScreen(baseVm),
        ),
      );
    });
  }

  Widget largeScreen(BaseVm baseVm) {
    return Row(
      children: [
        Expanded(flex: baseVm.isMini ? 1 : 2, child: const SideBarWidget()),
        Expanded(
          flex: baseVm.isMini ? 15 : 8,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: topBar(baseVm),
              ),
              Expanded(
                flex: 18,
                child: Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: PageView(
                    controller: baseVm.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      DashboardHome(),
                      UserView(),
                      RequestView(),
                      BookingsView(),
                      PaymentView(),
                      ReportsView(),
                      ReportsView(),
                      TermsConditionsView(),
                      PrivacyPolicyView(),
                      CancellationPolicy(),
                      RefundPolicy(),
                      ServiceTax(),
                      ChatView(),
                      SettingsView(),
                      InviteView(),
                      PictureView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget smallScreen(BaseVm baseVm) {
    return Row(
      children: [
        const Expanded(flex: 1, child: SideBarWidget()),
        Expanded(
          flex: 15,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: topBarSmall(baseVm),
              ),
              Expanded(
                flex: 18,
                child: Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: PageView(
                    controller: baseVm.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      DashboardHome(),
                      UserView(),
                      RequestView(),
                      BookingsView(),
                      PaymentView(),
                      ReportsView(),
                      ReportsView(),
                      TermsConditionsView(),
                      PrivacyPolicyView(),
                      CancellationPolicy(),
                      RefundPolicy(),
                      ServiceTax(),
                      ChatView(),
                      SettingsView(),
                      InviteView(),
                      PictureView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget topBar(BaseVm vm) {
    return Container(
      color: R.colors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 5.sp),
              InkWell(
                onTap: () {
                  vm.isMini = !vm.isMini;
                  vm.update();
                },
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Image.asset(R.images.burger, //menu icon
                        width: 4.sp,
                        color: R.colors.offWhite,
                        height: 4.sp)),
              ),
            ],
          ),
          Image.asset(
            R.images.splashIcon, //logo
            height: 8.h,
          ),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget topBarSmall(BaseVm vm) {
    return Container(
      color: R.colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            R.images.splashIcon, //logo
            height: 8.h,
          ),
        ],
      ),
    );
  }
}
