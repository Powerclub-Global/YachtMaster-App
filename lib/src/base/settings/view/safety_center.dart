import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/dummy.dart';
import '../../../../resources/resources.dart';
import '../view_model/settings_vm.dart';
import '../../../../utils/general_app_bar.dart';

class SafetyCenter extends StatefulWidget {
  static String route="/safetyCenter";
  const SafetyCenter({Key? key}) : super(key: key);

  @override
  _SafetyCenterState createState() => _SafetyCenterState();
}

class _SafetyCenterState extends State<SafetyCenter> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsVm>(
      builder: (context, provider,_) {
        return Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(context, provider.allContent.where((element) => element.type==AppContentType.safetyCenter.index).first.title??""),
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
                child:
                HtmlWidget(
                  provider.allContent.where((element) => element.type==AppContentType.safetyCenter.index).first.content??"",
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
