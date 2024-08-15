import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/appwrite.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../../resources/decorations.dart';
import '../../../../../resources/resources.dart';
import '../../../../../utils/heights_widths.dart';
import '../../../../../utils/helper.dart';

class InviteScreen extends StatefulWidget {
  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  @override
  Widget build(BuildContext context) {
    var authVm = Provider.of<AuthVm>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              R.images.invite,
              scale: 4,
            ),
            h4,
            Text(
              getTranslated(context, "invite_your_friend_and_earn_money") ?? "",
              style: R.textStyle
                  .helveticaBold()
                  .copyWith(color: Colors.white, fontSize: 13.sp),
            ),
            h1,
            SizedBox(
              width: Get.width * .7,
              child: Text(
                getTranslated(context,
                        "share_the_link_below_earn_when_your_friend_signup") ??
                    "",
                style: R.textStyle.helveticaBold().copyWith(
                    height: 1.5, color: Colors.white, fontSize: 11.sp),
                textAlign: TextAlign.center,
              ),
            ),
            h4,
            DottedBorder(
                borderType: BorderType.RRect,
                radius: Radius.circular(12),
                color: R.colors.whiteColor,
                dashPattern: [4, 2],
                strokeWidth: 1.4,
                child: Container(
                  width: Get.width * .85,
                  height: Get.height * .07,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: R.colors.blackDull),
                  padding: EdgeInsets.symmetric(horizontal: 2.5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            'https://yachtmasterapp.com?from=${authVm.userModel!.username}',
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor, fontSize: 12.5.sp),
                          ),
                        ),
                      ),
                      w1,
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData( ClipboardData(
                              text:
                                  "https://yachtmasterapp.com?from=${authVm.userModel!.username}"));
                          Helper.inSnackBar("Copied",
                              "Your text has been copied", R.colors.themeMud);
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Image.asset(
                                R.images.copying,
                                scale: 4,
                              ),
                              w2,
                              Text(
                                "${getTranslated(context, "copy")?.toLowerCase()}",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 10.sp),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            h6,
            GestureDetector(
              onTap: () {
                Share.share(
                    "Start Exploring the Magic of Yacht Master! \n https://yachtmasterapp.com?from=${authVm.userModel!.username}");
              },
              child: Container(
                height: Get.height * .055,
                width: Get.width * .8,
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: AppDecorations.gradientButton(radius: 30),
                child: Center(
                  child: Text(
                    getTranslated(context, "invite_a_friend") ?? "",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            h3
          ],
        ),
      ),
    );
  }
}
