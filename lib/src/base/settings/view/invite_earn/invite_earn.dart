import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../../resources/resources.dart';
import '../../../../../services/firebase_collections.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../auth/view_model/auth_vm.dart';
import '../../../home/home_vm/home_vm.dart';
import 'invite_screen.dart';
import 'status_screen.dart';
import 'withdraw_money.dart';
import '../../../../../utils/general_app_bar.dart';
import '../../../../../utils/heights_widths.dart';
import '../../../../../utils/zbot_toast.dart';

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


  @override
  Widget build(BuildContext context) {
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
