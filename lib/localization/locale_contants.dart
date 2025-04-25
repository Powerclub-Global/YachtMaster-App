import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String globalLanguageCode = 'languageCode';
const String english = 'en';
const String arabic = 'ar';

setLocale(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs
      .setString(globalLanguageCode, languageCode)
      .then((value) => print('prefs saved lang = $value'));
  return _locale(languageCode);
}

getLocale() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(globalLanguageCode) ?? "ar";
  print('prefs lang code = $languageCode');
  return _locale(languageCode);
}

getLanguageCode() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String languageCode = prefs.getString(globalLanguageCode) ?? "ar";
  return languageCode;
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case english:
      return const Locale(english, 'US');
    case arabic:
      return const Locale(arabic, "SA");
    default:
      return const Locale(english, 'US');
  }
}
