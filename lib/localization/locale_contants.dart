import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LANGUAGE_CODE = 'languageCode';
const String ENGLISH = 'en';
const String ARABIC = 'ar';

 setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs
      .setString(LANGUAGE_CODE, languageCode)
      .then((value) => print('prefs saved lang = $value'));
  return _locale(languageCode);
}

 getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? "ar";
  print('prefs lang code = $languageCode');
  return _locale(languageCode);
}

 getLanguageCode() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? "ar";
  return languageCode;
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, 'US');
    case ARABIC:
      return const Locale(ARABIC, "SA");
    default:
      return const Locale(ENGLISH, 'US');
  }
}
