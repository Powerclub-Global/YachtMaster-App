import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../model/content_model.dart';
import '../view_model/settings_vm.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/launch_url.dart';
import '../../../../utils/zbot_toast.dart';

class AboutApp extends StatefulWidget {
  static String route = "/aboutApp";
  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  String? websiteLink;
  String? fb;
  String? google;
  String? instagram;
  String? twitter;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ZBotToast.loadingShow();
      await fetchSocialLinks();
      // await context.read<SettingsVm>().fetchContent();

      ZBotToast.loadingClose();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.black,
      appBar: GeneralAppBar.simpleAppBar(
          context, getTranslated(context, "how_yachtmaster_works") ?? ""),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .008),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: R.colors.blackLight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        R.images.logo,
                        height: Get.height * .07,
                      ),
                      Text(
                        'Version 1.1.1',
                        style: R.textStyle.helveticaBold().copyWith(
                            color: R.colors.whiteDull, fontSize: 11.sp),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Container(
                  width: Get.width,
                  margin: EdgeInsets.all(10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: R.colors.blackLight,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, 'website') ?? "",
                              style: R.textStyle.helveticaBold().copyWith(
                                  fontSize: 12.sp, color: R.colors.whiteDull),
                            ),
                            Text(
                              websiteLink ?? "",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteDull, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: websiteLink ?? ""));
                          Helper.inSnackBar("Copied",
                              "Your text has been copied", R.colors.themeMud);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                              color: R.colors.themeMud, shape: BoxShape.circle),
                          child: Icon(
                            Icons.content_copy,
                            color: R.colors.whiteColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.5.h,
                ),
                Container(
                  width: Get.width,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .04, vertical: Get.height * .02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: R.colors.blackLight,
                  ),
                  child: Column(
                    children: [
                      Text(
                        getTranslated(context, 'follow_us') ?? "",
                        style: R.textStyle.helvetica().copyWith(
                            fontSize: 14.sp, color: R.colors.whiteColor),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // links(R.images.facebook,fb??"",),
                          // links(R.images.google,google??"",),
                          links(
                            R.images.twitter,
                            twitter ?? "",
                          ),
                          links(
                            R.images.instagram,
                            instagram ?? "",
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Column(
                  children: List.generate(
                      context
                          .read<SettingsVm>()
                          .allContent
                          .where((element) =>
                              element.type ==
                              AppContentType.howYachtWorks.index)
                          .length, (index) {
                    ContentModel content = context
                        .read<SettingsVm>()
                        .allContent
                        .where((element) =>
                            element.type == AppContentType.howYachtWorks.index)
                        .toList()[index];
                    return questionAnswer(
                        content.title ?? "", content.content ?? "");
                  }),
                )
              ],
            )),
      ),
    );
  }

  Widget questionAnswer(String title, String desc) {
    return Consumer<SettingsVm>(builder: (context, provider, _) {
      return Padding(
        padding: EdgeInsets.only(bottom: Get.height * .02),
        child: Container(
          decoration: BoxDecoration(
              color: R.colors.blackLight,
              borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              Container(
                width: Get.width,
                decoration: BoxDecoration(
                    color: R.colors.lightGrey,
                    borderRadius: BorderRadius.circular(18)),
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width * .04, vertical: Get.height * .015),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: R.textStyle.helveticaBold().copyWith(
                        color: R.colors.whiteColor,
                        fontSize: 12.5.sp,
                        height: 1.2),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width * .04, vertical: Get.height * .02),
                child: Text(desc.replaceAll("/n", "\n"),
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteDull,
                        fontSize: 11.5.sp,
                        height: 1.2)),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget links(String img, String url) {
    return GestureDetector(
      onTap: () {
        LaunchUrl.launchURL(url);
      },
      child: Image.asset(
        img,
        height: Get.height * .045,
      ),
    );
  }

  Future<void> fetchSocialLinks() async {
    try {
      QuerySnapshot snapshot = await FbCollections.appSocialLinks.get();
      if (snapshot.docs.isNotEmpty) {
        websiteLink = snapshot.docs.first.get("website");
        fb = snapshot.docs.first.get("facebook");
        google = snapshot.docs.first.get("google");
        twitter = snapshot.docs.first.get("twitter");
        instagram = snapshot.docs.first.get("instagram");
        setState(() {});
      }
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }
}
