import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';

import '../utils/text_size.dart';
import 'resources.dart';

class AppDecoration {
  InputDecoration fieldDecoration({
    Widget? preIcon,
    String? labelText,
    required String hintText,
    Widget? suffixIcon,
    double? radius,
    double? horizontalPadding,
    double? verticalPadding,
    double? iconMinWidth,
    double? suffixMaxHeight,
    double? suffixMinHeight,
    Color? fillColor,
    FocusNode? focusNode,
    bool? isLabelTranslated = true,
    TextStyle? hintTextStyle
  }) {
    return InputDecoration(
      suffixIconConstraints: BoxConstraints(
          minWidth: iconMinWidth ?? 60,
          minHeight:suffixMinHeight?? 50,maxHeight:suffixMaxHeight?? 50
      ),
      contentPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? 16, vertical: verticalPadding ?? 14),
      fillColor: fillColor ?? R.colors.textFieldFillColor,
      hintText: LocalizationMap.getTranslatedValues(hintText),
      prefixIcon: preIcon,
      suffixIcon: suffixIcon != null ? Container(child: suffixIcon) : null,
      hintStyle:hintTextStyle?? R.textStyles.poppins(
        color: R.colors.greyHintColor,
        fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
        fw: FontWeight.w300,
      ),
      counterText: "",
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        borderSide: BorderSide(color: R.colors.textFieldFillColor),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        borderSide: BorderSide(color: R.colors.textFieldFillColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        borderSide: BorderSide(color: R.colors.textFieldFillColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        borderSide: BorderSide(color: R.colors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        borderSide: BorderSide(color: R.colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 10)),
        borderSide: BorderSide(color: R.colors.red),
      ),
      filled: true,
    );
  }
}
