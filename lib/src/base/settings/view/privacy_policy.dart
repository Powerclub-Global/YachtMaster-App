import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';

class PrivacyPolicy extends StatefulWidget {
  static String route="/privacyPolicy";
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsVm>(
        builder: (context, provider,_) {
          return Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(context, provider.allContent.where((element) => element.type==AppContentType.privacyPolicy.index).first.title??""),
            body: SingleChildScrollView(
              child: Column(children: [
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    color: R.colors.grey.withOpacity(.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: Get.width*.04,vertical: Get.height*.02),
                  margin: EdgeInsets.symmetric(horizontal: Get.width*.04),
                  child:  HtmlWidget(
                    provider.allContent.where((element) => element.type==AppContentType.privacyPolicy.index).first.content??"",
                    onLoadingBuilder: (context, element, loadingProgress) => CircularProgressIndicator(),
                    onTapUrl: (url) => true,
                    renderMode: RenderMode.column,
                    textStyle: TextStyle(fontSize: 14,color: R.colors.whiteColor),
                  ),
                )
              ],),
            ),
          );
        }
    );
  }
}
