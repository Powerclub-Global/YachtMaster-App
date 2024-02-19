import 'package:get/get.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/utils/helper.dart';

class FieldValidator {
  static String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "email_is_required");
    }

    if (!RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    )
        .hasMatch(value)) {
      return getTranslated(Get.context!, "please_enter_a_valid_email_address");
    }

    return null;
  }

  static String? validateTitle(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_offer_title");
    }
    return null;
  }

  static String? validateEmpty(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "required");
    }
    return null;
  }
  static String? validateAmount(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "required");
    }
    if (!RegExp(r"(\-?\d+\.?\d{0,2})")
        .hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_amount");
    }
    return null;
  }
  static String? validateAccountNumber(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "required");
    }
    if (!RegExp(r"^[0-9]{7,14}$")
        .hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_account_number");
    }
    return null;
  }

  static String? validateRequired(String? value) {
    if (value!.removeAllWhitespace.isEmpty) {
      return getTranslated(Get.context!, "required");
    }
    return null;
  }

  static String? validateRequiredPrice(String? value) {
    if (value!.removeAllWhitespace.isEmpty) {
      return getTranslated(Get.context!, "required");
    }
    if (double.parse(value) == 0) {
      return getTranslated(Get.context!, "price_greater_than");
    }
    return null;
  }

  static String? validateHolderName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_card_holder_name");
    }
    if (!RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$")
        .hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_name");
    }
    return null;
  }

  static String? validateCvcNumber(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_cvc_number");
    }
    if (value.length < 3) {
      return getTranslated(Get.context!, "number_must_be_3_digits");
    }

    return null;
  }

  static String? validateExpiration(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_expiration_date");
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/?(([0-9]{4}|[0-9]{2})$)').hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_date");
    }
    if(int.parse(value.substring(0,2))<=now.month)
      {
        return "invalid month";

      }
    if(int.parse(value.substring(3,5))<int.parse(now.year.toString().substring(2,4)))
    {
      return "invalid year";

    }
    return null;
  }

  static String? validateCardNumber(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_card_number");
    }
    if (value.length < 16) {
      return getTranslated(Get.context!, "number_must_be_16_digits");
    }

    return null;
  }

  static String? validateDescription(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_description");
    }
    return null;
  }

  static String? validateEmailUserName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "enter_email_username");
    }
    return null;
  }

  static String? validateText(String? value) {
    if (value!.length > 250) {
      return getTranslated(Get.context!, "maximum_250_characters_allowed");
    }

    return null;
  }

  static String? validateEmailWithoutPhone(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "email_is_required");
    }
    if (!RegExp(
            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
        .hasMatch(value)) {
      return getTranslated(Get.context!, "please_enter_a_valid_email_address");
    }

    return null;
  }

  static String? validateFirstName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "first_name_is_required");
    }

    if (!RegExp(r"^[A-Za-z-]{2,25}$").hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_name");
    }

    return null;
  }

  static String? validateFullName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!,"please_enter_your_full_name");
    }
    if (value.length <= 2) {
      return getTranslated(Get.context!,"invalid_name");
    } else if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
      return getTranslated(Get.context!,"invalid_name");
    }
    // if (!RegExp(r"^([ \u00c0-\u01ffa-zA-Z'\-])+$").hasMatch(value)) {
    //   return LocalizationMap.getTranslatedValues("invalid_name");
    // }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "last_name_is_required");
    }

    if (!RegExp(r"^[A-Za-z-]{2,25}$").hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_name");
    }

    return null;
  }

  static String? validateJobName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "job_title_is_required");
    }
    if (!RegExp(r'^[a-z A-Z,.\-]+$').hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_title");
    }
    if (value.length > 50) {
      return getTranslated(Get.context!, "maximum_50_characters_allowed");
    }
    return null;
  }

  static String? validateCompanyName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "company_name_is_required");
    }
    if (!RegExp(r'^[a-z A-Z,.\-]+$').hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_name");
    }
    if (value.length > 100) {
      return getTranslated(Get.context!, "maximum_100_characters_allowed");
    }
    return null;
  }

  static String? validateCityName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "city_is_required");
    }
    if (!RegExp(r'^[a-z A-Z,.\-]+$').hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_name");
    }
    if (value.length > 25) {
      return getTranslated(Get.context!, "maximum_25_characters_allowed");
    }
    return null;
  }

  static String? validateCountryName(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "country_is_required");
    }
    if (!RegExp(r'^[a-z A-Z,.\-]+$').hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_name");
    }
    if (value.length > 25) {
      return getTranslated(Get.context!, "maximum_25_characters_allowed");
    }
    return null;
  }

  static String? validateMobile(String? value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(pattern);
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "phone_number_required");
    } else if (!regExp.hasMatch(value)) {
      return getTranslated(Get.context!, "invalid_phone_number");
    }
    return null;
  }

  static String? validateSubject(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "subject_is_required");
    }

    return null;
  }

  static String? validateDesc(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "description_is_required");
    }

    return null;
  }

  static String? validatePasswordSignup(String? value) {
    if (value!.isEmpty) {
      return getTranslated(Get.context!, "password_required");
    }
    if (value.length < 6) {
      return getTranslated(
          Get.context!, "password_should_consists_of_minimum_6_character");
    }
    if (!RegExp(r"^(?=.*?[0-9])").hasMatch(value)) {
      return getTranslated(
          Get.context!, "password_should_include_at_least_1_number");
    }
    if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(value)) {
      return getTranslated(
          Get.context!, "password_should_include_1_special_character");
    }
    return null;
  }
}
