import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/invite_screen.dart';
import 'package:yacht_master/src/base/settings/view/invite_earn/status_screen.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class InviteAndEarn extends StatefulWidget {
  static String route="/inviteAndEarn";
  const InviteAndEarn({Key? key}) : super(key: key);

  @override
  _InviteAndEarnState createState() => _InviteAndEarnState();
}

class _InviteAndEarnState extends State<InviteAndEarn> {
  List<String> tabsList=["invite","earnings"];
  int selectedTabIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "invite_earn")??""),
      backgroundColor: R.colors.black,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          h1,
          Container(width: Get.width*.7,
            padding: EdgeInsets.only(left: Get.width*.04),
            child: Row(children: List.generate(2, (index) {
              return tabs(tabsList[index],index);
            }),),
          ),
          if (selectedTabIndex==0) Expanded(child: InviteScreen()) else Expanded(child: StatusScreen())

        ],),
    );
  }
  Widget tabs(String title,int index)
  {
    return Expanded(
      child: GestureDetector(
        onTap: (){
          setState(() {
            selectedTabIndex=index;
          });
        },
        child: Container(color: Colors.transparent,
          child: Column(
            children: [
              Text(getTranslated(context, title)??"",style: R.textStyle.helveticaBold().copyWith(
                color: selectedTabIndex==index?
                R.colors.yellowDark:R.colors.whiteColor,
              ),),
              Divider(color:selectedTabIndex==index?
              R.colors.yellowDark:R.colors.grey.withOpacity(.40),thickness: 2,height: Get.height*.03,)
            ],
          ),
        ),
      ),
    );
  }

}
