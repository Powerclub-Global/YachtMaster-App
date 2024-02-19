// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class ReceivePaymentSheet extends StatefulWidget {
  String? title;
  String? subTitle;
  Function()? yesCallBack;
  String? buttonName;

  ReceivePaymentSheet({this.title, this.subTitle, this.yesCallBack,this.buttonName});

  @override
  _ReceivePaymentSheetState createState() => _ReceivePaymentSheetState();
}

class _ReceivePaymentSheetState extends State<ReceivePaymentSheet> {
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
          Image.asset(R.images.sure,scale: 4,),
          h3,
          Text(
            widget.title??"",
            textAlign: TextAlign.center,
            style: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 14.sp),
          ),
          h2,
          SizedBox(
            width: Get.width*.65,
            child: Text(
              widget.subTitle??"",
              textAlign: TextAlign.center,
              style: R.textStyle
                  .helveticaBold()
                  .copyWith(color: R.colors.whiteColor, fontSize: 11.sp,height: 1.5),
            ),
          ),
          h2,
          GestureDetector(
            onTap: widget.yesCallBack,
            child: Container(
              height: Get.height*.055,
              width: Get.width*.8,
              margin: EdgeInsets.only(bottom: Get.height*.015),
              decoration: AppDecorations.gradientButton(radius: 30),
              child: Center(
                child: Text(widget.buttonName??"",
                  style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                      fontSize: 12.sp,fontWeight: FontWeight.bold
                  ) ,),
              ),
            ),
          ),
          h3,
        ],
      ),
    );
  }
}
