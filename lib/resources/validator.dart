

import 'package:yacht_master_admin/resources/localization/localization_map.dart';

class FieldValidator {

  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return LocalizationMap.getTranslatedValues(
          "please_enter_your_email_address");
    }
    if (!RegExp(r'^[^\s]').hasMatch(value)) {
      return LocalizationMap.getTranslatedValues("invalid_email_address");
    }
    if (!RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(value)) {
      return LocalizationMap.getTranslatedValues("invalid_email_address");
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value!.isEmpty) {
      return LocalizationMap.getTranslatedValues("please_enter_your_password");
    }
    // if (!RegExp(r'^[^\s]').hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues("please_enter_your_password");
    // }
    // if (value.length < 8) {
    //   return LocalizationMap.getTranslatedValues("password_limit");
    // }
    // if (!RegExp(r"^(?=.*?[0-9])").hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues(
    //       "password_should_include_1_number");
    // }
    // if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(value.trim())) {
    //   return LocalizationMap.getTranslatedValues(
    //       "password_should_1_special_character");
    // }
    return null;
  }

  static String? validateOldPassword(String? value) {
    if (value!.isEmpty) {
      return LocalizationMap.getTranslatedValues(
          "please_enter_your_old_password");
    }
    // if (!RegExp(r'^[^\s]').hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues(
    //       "please_enter_your_old_password");
    // }
    // if (value.length < 8) {
    //   return LocalizationMap.getTranslatedValues(
    //       "old_password_consists_minimum_8_character");
    // }
    // if (!RegExp(r"^(?=.*?[0-9])").hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues(
    //       "old_password_should_include_1_number");
    // }
    // if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(value.trim())) {
    //   return LocalizationMap.getTranslatedValues(
    //       "old_password_should_include_1_special_char");
    // }
    return null;
  }

  static String? validateNewPassword(String? value) {
    if (value!.isEmpty) {
      return LocalizationMap.getTranslatedValues(
          "please_enter_your_new_password");
    }
    // if (!RegExp(r'^[^\s]').hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues(
    //       "please_enter_your_new_password");
    // }
    // if (value.length < 8) {
    //   return LocalizationMap.getTranslatedValues(
    //       "new_password_consists_minimum_8_character");
    // }
    // if (!RegExp(r"^(?=.*?[0-9])").hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues(
    //       "new_password_should_include_1_number");
    // }
    // if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(value.trim())) {
    //   return LocalizationMap.getTranslatedValues(
    //       "new_password_should_include_1_special_char");
    // }
    return null;
  }

  static String? validateEmpty(String? value) {
    if (value!.isEmpty) {
      return LocalizationMap.getTranslatedValues("field_required");
    }
    return null;
  }


}
