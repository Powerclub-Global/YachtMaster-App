import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/localization/locale_contants.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class Translate extends StatefulWidget {
  const Translate({Key? key}) : super(key: key);

  @override
  _TranslateState createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsVm>(builder: (context, provider, _) {
      return Container(
        decoration: BoxDecoration(
          color: R.colors.black,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            h2,
            GeneralAppBar.simpleAppBar(context, getTranslated(context, "translate")??"",
                style: R.textStyle
                    .helveticaBold()
                    .copyWith(color: Colors.white, fontSize: 18.sp)),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: Get.width*.07,vertical: Get.height*.03),
              child: Column(
                children: [
                  flags(provider, 0, "United States", R.images.us),
                  h1P5,
                  flags(provider, 1, "United Kingdom", R.images.uk),
                  h1P5,
                  flags(provider, 2, "Arabic", R.images.uae),
                ],
              ),
            ),
            h2,
          ],
        ),
      );
    });
  }

  Widget flags(SettingsVm provider, int index,String title,String img) {
    return GestureDetector(
      onTap: () async {
        provider.selectedLang=index;
        provider.update();
        await setLocale(
            provider.selectedLang == 2 ? "ar" : "en");
        provider.onChangeLang(
            provider.selectedLang == 2 ? ARABIC:ENGLISH ,
            context);
        Get.back();
      },
      child: Container(
        decoration: BoxDecoration(
          color: R.colors.blackLight,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: Get.width * .03, vertical: Get.height * .02),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  img,
                  height: Get.height * .04,
                ),
                w3,
                Text(title,
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: Colors.white, fontSize: 14.sp)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white)),
              padding: EdgeInsets.all(2),
              child: Container(
                height: 13,
                width: 13,
                decoration: BoxDecoration(
                    color: provider.selectedLang == index
                        ? R.colors.whiteColor
                        : R.colors.black,
                    shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
