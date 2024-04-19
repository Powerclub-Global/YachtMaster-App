import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/inbox/view/messages.dart';
import 'package:yacht_master/src/base/inbox/view/notifications.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class InboxView extends StatefulWidget {
  static String route="/inboxView";
  const InboxView({Key? key}) : super(key: key);

  @override
  _InboxViewState createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  List<String> tabsList=["messages","notifications"];
  int selectedTabIndex=0;
  dynamic args;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      args = ModalRoute.of(context)?.settings.arguments;
      if(args != null){
        selectedTabIndex = args["selectedTabIndex"];
        setState((){});
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.black,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        h6,
       Container(width: double.infinity,
         padding: EdgeInsets.only(left: Get.width*.04),
         child: Row(children: List.generate(2, (index) {
           return tabs(tabsList[index],index);
         }),),
       ),
        if (selectedTabIndex==0) Messages() else Expanded(child: Notifications())
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
