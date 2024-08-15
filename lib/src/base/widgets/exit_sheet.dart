import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sizer/sizer.dart';
import '../../../localization/app_localization.dart';
import '../../../resources/decorations.dart';
import '../../../resources/resources.dart';
import '../../../utils/heights_widths.dart';

class SureBottomSheet extends StatefulWidget {
  String? title;
  String? subTitle;
  Function()? yesCallBack;

  SureBottomSheet({this.title, this.subTitle, this.yesCallBack});

  @override
  _SureBottomSheetState createState() => _SureBottomSheetState();
}

class _SureBottomSheetState extends State<SureBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
      decoration: BoxDecoration(
        color: R.colors.black,
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          h1,
          Image.asset(
            R.images.sure,
            scale: 4,
          ),
          h3,
          Text(
            widget.title ?? "",
            textAlign: TextAlign.center,
            style: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 14.sp),
          ),
          h2,
          SizedBox(
            width: Get.width * .65,
            child: Text(
              widget.subTitle ?? "",
              textAlign: TextAlign.center,
              style: R.textStyle.helveticaBold().copyWith(
                  color: R.colors.whiteColor, fontSize: 11.sp, height: 1.5),
            ),
          ),
          h2,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: Get.height * .055,
                    width: Get.width * .8,
                    margin: EdgeInsets.only(bottom: Get.height * .015),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: R.colors.blueGrey),
                    child: Center(
                      child: Text(
                        "${getTranslated(context, "no")?.toUpperCase()}",
                        style: R.textStyle.helvetica().copyWith(
                            color: R.colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.yesCallBack,
                  child: Container(
                    height: Get.height * .055,
                    width: Get.width * .8,
                    margin: EdgeInsets.only(bottom: Get.height * .015),
                    decoration: AppDecorations.gradientButton(radius: 30),
                    child: Center(
                      child: Text(
                        "${getTranslated(context, "yes")?.toUpperCase()}",
                        style: R.textStyle.helvetica().copyWith(
                            color: R.colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          h3,
        ],
      ),
    );
  }
}
