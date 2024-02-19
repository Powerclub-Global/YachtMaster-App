import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String? getTranslated(BuildContext context, String key) {
  return AppLocalization.of(context)?.getTranslatedValues(key);
}

class AppLocalization {
  final Locale locale;
  AppLocalization(this.locale);

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  late Map<String, String> _localizedValues;
   load() async {
    String jsonStringVaues = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonStringVaues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String? getTranslatedValues(String key) {
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();
  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'ar',
    ].contains(locale.languageCode);
  }

  @override
   load(Locale locale) async {
    AppLocalization localization = AppLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
