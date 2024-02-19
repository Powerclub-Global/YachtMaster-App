import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/resources.dart';


class AppTextStyle {
  static TextStyle poppinsExtraLight() {
    return TextStyle(
        fontSize: 14.sp,
        fontFamily: "Poppins",
        color: R.colors.blackColor,
        fontWeight: FontWeight.w200);
  }

  static TextStyle poppinsLight() {
    return TextStyle(
        fontSize: 9.sp,
        fontFamily: "Poppins",
        color: R.colors.blackColor,
        fontWeight: FontWeight.w300);
  }

  static TextStyle poppinsRegular() {
    return TextStyle(
        fontSize: 12.sp,
        fontFamily: "Poppins",
        color: R.colors.whiteColor,
        fontWeight: FontWeight.w400);
  }

  static TextStyle poppinsMedium() {
    return TextStyle(
        fontSize: 12.sp,
        fontFamily: "Poppins",
        color: R.colors.whiteColor,
        fontWeight: FontWeight.w500);
  }



   TextStyle helvetica() {
    return TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Helvetica',
      color: R.colors.charcoalColor,
    );
  }
   TextStyle helveticaBold() {
    return TextStyle(
      fontSize: 14.sp,
      fontFamily: 'Helvetica-Bold',
      color: R.colors.charcoalColor,
    );
  }
}
