import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../../../../resources/resources.dart';
import '../../../../utils/heights_widths.dart';
import '../resources/decorations.dart';

class PermissionDialog extends StatefulWidget {
  const PermissionDialog({Key? key}) : super(key: key);

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.transparent,
      body: Align(
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: R.colors.black.withOpacity(0.16),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                ),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   R.images.forgotPasswordImage,
              //   height: 15.h,
              // ),
              h2,
              Text(
                "Oops!",
                textAlign: TextAlign.center,
                style: R.textStyle.helveticaBold().copyWith(
                  fontSize: 20.sp,
                  color: R.colors.black,
                ),
              ),
              h2,
              Text(
               "Please grant required permission",
                textAlign: TextAlign.center,
                style: R.textStyle.helvetica().copyWith(
                  fontSize: 12.sp,
                  color: R.colors.black,
                ),
              ),
              h2,
              GestureDetector(
                onTap: () async {
                  await openAppSettings();
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 7.h),
                  child: Container(
                    height: Get.height * .06,
                    decoration:
                    AppDecorations.gradientButton(radius: 30),
                    child: Center(
                      child: Text(
                        "Open settings",
                        style: R.textStyle.helvetica().copyWith(
                            color: R.colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith((states) => R.colors.blackDull.withOpacity(0.05)),
                ),
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  "Back",
                  style: R.textStyle.helveticaBold().copyWith(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
