import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/stripe/stripe_service.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/invite_screen.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/status_screen.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/withdraw_money.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

class InviteAndEarn extends StatefulWidget {
  static String route = "/inviteAndEarn";
  const InviteAndEarn({Key? key}) : super(key: key);

  @override
  _InviteAndEarnState createState() => _InviteAndEarnState();
}

class _InviteAndEarnState extends State<InviteAndEarn> {
  List<String> tabsList = ["invite", "earnings"];
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ZBotToast.loadingShow();
      var homeVm = Provider.of<HomeVm>(Get.context!, listen: false);
      await homeVm.fetchWalletHistory(context);
      homeVm.update();
      ZBotToast.loadingClose();
    });
  }

  Future<void> checkOnboardingStatus() async {
    StripeService stripe = StripeService();
    var authVm = Provider.of<AuthVm>(context, listen: false);
    var connectedAccount = await FbCollections.connected_accounts
        .where('uid', isEqualTo: authVm.userModel!.uid)
        .get();
    Map<String, dynamic> connected_account_id_data =
        connectedAccount.docs.first.data() as Map<String, dynamic>;
    String connectedAccountId = connected_account_id_data['account_id'];
    stripe.checkDetailsSubmitted(context, true, connectedAccountId);
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    String? status = args['status'];
    if (status != null) {
      if (status == "refresh") {
        Get.dialog(Text(getTranslated(context, "onboarding_refresh")!));
      } else {
        Get.dialog(Text(getTranslated(context, "onboarding_return")!));
        Future.delayed(Duration(seconds: 2), () {
          ZBotToast.loadingShow();
        });
        checkOnboardingStatus();
      }
    }
    return Scaffold(
      appBar: GeneralAppBar.simpleAppBar(
          context, getTranslated(context, "invite_earn") ?? ""),
      backgroundColor: R.colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          h1,
          Container(
            padding:
                EdgeInsets.only(left: Get.width * .04, right: Get.width * .04),
            child: Row(
              children: List.generate(2, (index) {
                return tabs(tabsList[index], index);
              }),
            ),
          ),
          if (selectedTabIndex == 0)
            Expanded(child: InviteScreen())
          else
            Expanded(child: StatusScreen())
        ],
      ),
    );
  }

  Widget tabs(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: [
              Text(
                getTranslated(context, title) ?? "",
                style: R.textStyle.helveticaBold().copyWith(
                      color: selectedTabIndex == index
                          ? R.colors.yellowDark
                          : R.colors.whiteColor,
                    ),
              ),
              Divider(
                color: selectedTabIndex == index
                    ? R.colors.yellowDark
                    : R.colors.grey.withOpacity(.40),
                thickness: 2,
                height: Get.height * .03,
              )
            ],
          ),
        ),
      ),
    );
  }
}
