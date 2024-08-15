import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/dummy.dart';
import '../../../../resources/resources.dart';
import '../view_model/settings_vm.dart';
import '../../../../utils/general_app_bar.dart';

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
