import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/auth/view/login.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class LogoutBottomSheet extends StatefulWidget {
  const LogoutBottomSheet({Key? key}) : super(key: key);

  @override
  _LogoutBottomSheetState createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<BaseVm, AuthVm>(builder: (context, provider, authVm, _) {
      return Container(
          padding: EdgeInsets.symmetric(
            horizontal: Get.width * .07,
          ),
          decoration: BoxDecoration(
            color: R.colors.black,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 2.h,
              ),
              Image.asset(
                R.images.sure,
                scale: 4,
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
                getTranslated(context, "logout") ?? "",
                style: R.textStyle
                    .helveticaBold()
                    .copyWith(color: R.colors.whiteColor, fontSize: 16.sp),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                "${getTranslated(context, 'are_you_sure')} ${getTranslated(context, 'you_want_logout')}",
                style: R.textStyle.helvetica().copyWith(
                    color: R.colors.whiteDull,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4.h,
              ),
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
                      onTap: () async {
                        await authVm.logoutUser();
                        Get.offAllNamed(LoginScreen.route);
                      },
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
              h2,
            ],
          ));
    });
  }
}
