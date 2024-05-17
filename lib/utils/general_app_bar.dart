import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../localization/app_localization.dart';
import '../resources/resources.dart';
import 'dart:ui' as ui;

class GeneralAppBar{
  static PreferredSize simpleAppBar(BuildContext context,String title,
      {TextStyle? style})
  {
    return PreferredSize(
      preferredSize: Size.fromHeight(50),
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(title,style:style ?? R.textStyle.helvetica().copyWith(
              color: Colors.white
          )),
          leading: GestureDetector(
              onTap: (){
                Get.back();

              },
              child: Icon(Icons.arrow_back_ios_rounded,color: R.colors.whiteColor,)),
        ),
      ),
    );
  }

}
class GeneralWidgets{
  static Widget seeAllWidget(BuildContext context,String title,{bool isSeeAll=true,Function()? onTap,bool isPadding=true})
  {
    return  Padding(
      padding:  EdgeInsets.symmetric(
        horizontal:isPadding? Get.width * .03:0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            getTranslated(context, title) ?? "",
            style: R.textStyle.helvetica().copyWith(color: Colors.white),
          ),
         if (isSeeAll==false) SizedBox() else GestureDetector(
           onTap: onTap,
           child: Text(
              getTranslated(context, "see_all") ?? "",
              style: R.textStyle
                  .helvetica()
                  .copyWith(color: Colors.white, fontSize: 10.sp),
            ),
         ),
        ],
      ),
    );
  }

}