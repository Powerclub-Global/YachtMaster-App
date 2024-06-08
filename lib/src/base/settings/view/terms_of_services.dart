import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yacht_master/utils/launch_url.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/dummy.dart';
import '../../../../resources/resources.dart';
import '../view_model/settings_vm.dart';
import '../../../../utils/general_app_bar.dart';

class TermsOfServices extends StatefulWidget {
  static String route = "/termsOfServices";
  const TermsOfServices({Key? key}) : super(key: key);

  @override
  _TermsOfServicesState createState() => _TermsOfServicesState();
}

class _TermsOfServicesState extends State<TermsOfServices> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsVm>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        appBar: GeneralAppBar.simpleAppBar(
            context,
            provider.allContent
                    .where((element) =>
                        element.type == AppContentType.termsOfService.index)
                    .first
                    .title ??
                ""),
        body: SingleChildScrollView(
          child: Column(
            children: [
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
                  provider.allContent
                          .where((element) =>
                              element.type ==
                              AppContentType.termsOfService.index)
                          .first
                          .content ??
                      "",
                  onLoadingBuilder: (context, element, loadingProgress) =>
                      CircularProgressIndicator(),
                  onTapUrl: (url) => launchUrl(Uri.parse(url)),
                  renderMode: RenderMode.column,
                  textStyle:
                      TextStyle(fontSize: 14, color: R.colors.whiteColor),
                  customStylesBuilder: (element) {
                    if (element.localName == 'a') {
                      return {'color': 'gold'}; // Set the link color to gold
                    }
                    return null;
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
