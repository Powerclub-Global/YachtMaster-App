import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';

import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class TipAmountSheet extends StatefulWidget {
  Function(String value)? yesCallBack;
  TipAmountSheet({
    this.yesCallBack,
  });

  @override
  _TipAmountSheetState createState() => _TipAmountSheetState();
}

class _TipAmountSheetState extends State<TipAmountSheet> {
  TextEditingController tipAmount = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
      decoration: BoxDecoration(
        color: R.colors.black,
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30), topLeft: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            h1,
            Icon(Icons.monetization_on,
                color: R.colors.whiteColor, size: 30.sp),
            h2,
            Text(
              "How much would you like to tip?",
              textAlign: TextAlign.center,
              style: R.textStyle
                  .helveticaBold()
                  .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
            ),
            h2,
            SizedBox(
              height: 190,
              width: Get.width * .65,
              child: TextField(
                controller: tipAmount,
                keyboardType: TextInputType.number,
                decoration: AppDecorations.suffixTextField(
                  "Enter Amount",
                  R.textStyle.helvetica().copyWith(
                      color: R.colors.black,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold),
                  Text(
                    "USD",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.black,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            h2,
            GestureDetector(
              onTap: () {
                String tip = tipAmount.text;
                widget.yesCallBack!(tip);
                Get.back();
              },
              child: Container(
                height: Get.height * .055,
                width: Get.width * .8,
                margin: EdgeInsets.only(bottom: Get.height * .015),
                decoration: AppDecorations.gradientButton(radius: 30),
                child: Center(
                  child: Text(
                    "Confirm Tip",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
