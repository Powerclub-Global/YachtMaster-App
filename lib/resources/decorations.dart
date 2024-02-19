
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';

class AppDecorations {
  static InputDecoration suffixTextField(String? hint,TextStyle? hintStyle,Widget? icon,) {
    return InputDecoration(
      hintText: getTranslated(Get.context!, hint??""),
      hintStyle: hintStyle,
      suffixIconConstraints: BoxConstraints(maxWidth: 50,
          minHeight: 30,
          maxHeight: 30,
          minWidth: 50),

      filled:true,
      fillColor: R.colors.whiteColor,
      isDense: true,
      suffixIcon:icon,
      errorStyle:  R.textStyle.helvetica().copyWith(
          color: R.colors.redColor,
          fontSize: 9.sp),
      enabledBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

          borderSide: BorderSide(
              color:R.colors.black
          )),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:  BorderSide(
              color:R.colors.themeMud
          )),
      errorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent)),
      focusedErrorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red)),
    );
  }
  static InputDecoration simpleTextField(String? hint,TextStyle? hintStyle,) {
    return InputDecoration(
      hintText: getTranslated(Get.context!, hint??""),
      hintStyle: hintStyle,
      labelStyle: R.textStyle.helvetica().copyWith(
          color: R.colors.charcoalColor,fontSize: 9.sp),
      filled:true,
      fillColor: R.colors.whiteColor,
      isDense: true,
      enabledBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

          borderSide: BorderSide(
              color:R.colors.black
          )),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:  BorderSide(
              color:R.colors.themeMud
          )),
      errorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent)),
      focusedErrorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red)),
    );
  }
  static InputDecoration generalTextField(String? hint,TextStyle? hintStyle,) {
    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      labelStyle: R.textStyle.helvetica().copyWith(
          color: R.colors.charcoalColor,fontSize: 9.sp),
      filled:true,
      fillColor: R.colors.whiteColor,
      isDense: true,
      enabledBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),

          borderSide: BorderSide(
              color:R.colors.black
          )),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:  BorderSide(
              color:R.colors.themeMud
          )),
      errorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.transparent)),
      focusedErrorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red)),
    );
  }
  static InputDecoration greyTextField(String? hint,{Widget? prefixIcon}) {
    return InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: Get.width*.04),
      prefixIconConstraints: BoxConstraints(
          maxHeight: 12,minHeight: 12,maxWidth: 40,minWidth: 40
      ),
      prefixIcon: prefixIcon,
      hintText:
      "${getTranslated(Get.context!, hint??"")}",
      hintStyle: R.textStyle.helvetica().copyWith(
          color: R.colors.whiteColor,
          fontSize: 11.sp),
    );
  }

  static BoxDecoration buttonDecoration(Color color,double radius) {
    return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius)
    );
  }
  static BoxDecoration gradientButton( {double radius=10}) {
    return  BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:[
            R.colors.gradMud,
            R.colors.themeMud,
            R.colors.gradMudLight,
            R.colors.themeMud,
            R.colors.gradMud,
          ] ),
      borderRadius: BorderRadius.circular(radius),

    );
  }
  static BoxDecoration cardsDecoration({Color? borderColor,double? borderWidth=1,double? radius=10}) {
    return BoxDecoration(
        color: R.colors.whiteColor,
        borderRadius: BorderRadius.circular(radius!),
        border: Border.all(color:borderColor!,width: borderWidth!),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.15),
              blurRadius: 2,spreadRadius: 2,
              offset: Offset(0,0)
          )
        ]
    );
  }
  static BoxDecoration favDecoration() {
    return BoxDecoration(
        // color: R.colors.whiteColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.30),
              blurRadius: 10,spreadRadius: 2,
              offset: Offset(0,0)
          )
        ]
    );
  }
  static BoxDecoration cardsDecorationColored(Color color, [double? radius=10,Color? borderColor=Colors.grey]) {
    return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius!),
        border: Border.all(color: borderColor!),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.15),
              blurRadius: 2,spreadRadius: 2,
              offset: Offset(0,0)
          )
        ]

    );
  }

}

Widget label(String label, {double fs=10})
{
  return Row(
    children: [
      Text(label,style:R.textStyle.helvetica().copyWith(
          color: R.colors.whiteColor,
          fontSize: fs.sp),
      ),
    ],
  );
}