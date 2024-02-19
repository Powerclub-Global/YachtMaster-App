import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';

class PrivacySharing extends StatefulWidget {
  static String route="/privacySharing";
  const PrivacySharing({Key? key}) : super(key: key);

  @override
  _PrivacySharingState createState() => _PrivacySharingState();
}

class _PrivacySharingState extends State<PrivacySharing> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsVm>(
        builder: (context, provider,_) {
          return Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(context, provider.allContent.where((element) => element.type==AppContentType.privacySharing.index).first.title??""),
            body: Column(children: [
              Container(
                width: Get.width,
                height: Get.height/1.5,
                decoration: BoxDecoration(
                  color: R.colors.grey.withOpacity(.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: Get.width*.04,vertical: Get.height*.02),
                margin: EdgeInsets.symmetric(horizontal: Get.width*.04),
                child: Text(provider.allContent.where((element) => element.type==AppContentType.privacySharing.index).first.content??"",style: R.textStyle.helvetica().copyWith(
                  color: R.colors.whiteDull,fontSize: 12.sp,
                ),textAlign: TextAlign.left,),
              )
            ],),
          );
        }
    );
  }
}
