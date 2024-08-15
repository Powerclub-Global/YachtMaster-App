import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'locale_contants.dart';
import '../main.dart';


bool isRTL = false;

class UpdateLocale {
   language(String languageCode, BuildContext? context) {
    print(languageCode);
    Locale _temp;
    setLocale(languageCode);
    switch (languageCode) {
      case "en":
        _temp = Locale(languageCode, 'US');
        isRTL = false;
        Get.updateLocale(_temp);

        break;
      case "ar":
        _temp = Locale(languageCode, 'SA');
        isRTL = true;
        Get.updateLocale(_temp);
        break;
      case "ur":
        _temp = Locale(languageCode, 'PK');
        isRTL = true;
        Get.updateLocale(_temp);
        break;
      default:
        _temp = Locale(languageCode, 'US');
        isRTL = false;
        Get.updateLocale(_temp);
    }
    MyApp.setLocale(context!, _temp);
    return true;
  }
}
