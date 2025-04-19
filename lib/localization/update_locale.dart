import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'locale_contants.dart';
import '../main.dart';


bool isRTL = false;

class UpdateLocale {
   language(String languageCode, BuildContext? context) {
    print(languageCode);
    Locale temp;
    setLocale(languageCode);
    switch (languageCode) {
      case "en":
        temp = Locale(languageCode, 'US');
        isRTL = false;
        Get.updateLocale(temp);

        break;
      case "ar":
        temp = Locale(languageCode, 'SA');
        isRTL = true;
        Get.updateLocale(temp);
        break;
      case "ur":
        temp = Locale(languageCode, 'PK');
        isRTL = true;
        Get.updateLocale(temp);
        break;
      default:
        temp = Locale(languageCode, 'US');
        isRTL = false;
        Get.updateLocale(temp);
    }
    MyApp.setLocale(context!, temp);
    return true;
  }
}
