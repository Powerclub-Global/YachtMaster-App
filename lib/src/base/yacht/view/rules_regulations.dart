import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../resources/dummy.dart';
import '../../../../resources/resources.dart';
import '../../settings/view_model/settings_vm.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';

import '../../../../constant/enums.dart';

class RulesRegulations extends StatefulWidget {
  static String route = "/rulesRegulations";
  const RulesRegulations({Key? key}) : super(key: key);

  @override
  _RulesRegulationsState createState() => _RulesRegulationsState();
}

class _RulesRegulationsState extends State<RulesRegulations> {
  String title = "";
  String desc = "";
  String appBarTitle = "";
  TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    appBarTitle = args["appBarTitle"];
    title = args["title"];
    desc = args["desc"];
    return Consumer<SettingsVm>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        appBar:
            GeneralAppBar.simpleAppBar(context, appBarTitle, style: textStyle),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (title == "") SizedBox() else h2,
              if (title == "")
                SizedBox()
              else
                Center(
                  child: Text(
                    title,
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: R.colors.whiteColor, fontSize: 13.sp),
                  ),
                ),
              h2,
              if (desc == "")
                SizedBox()
              else
                Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: R.colors.grey.withOpacity(.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: Get.width * .04, vertical: Get.height * .02),
                    margin: EdgeInsets.symmetric(horizontal: Get.width * .04),
                    child: HtmlWidget(
                      desc,
                      onLoadingBuilder: (context, element, loadingProgress) => CircularProgressIndicator(),
                      onTapUrl: (url) => true,
                      renderMode: RenderMode.column,
                      textStyle: TextStyle(fontSize: 14,color: R.colors.whiteColor),

                    ),)
            ],
          ),
        ),
      );
    });
  }
}
