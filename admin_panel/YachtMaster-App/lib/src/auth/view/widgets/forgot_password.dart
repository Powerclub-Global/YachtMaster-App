import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';

import '../../../../../resources/resources.dart';
import '../../../../../utils/widgets/app_button.dart';
import '../../../../resources/validator.dart';
import '../../../../utils/text_size.dart';
import '../../vm/auth_vm.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  FocusNode emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVM>(builder: (context, authVm, _) {
      return Scaffold(
        backgroundColor: R.colors.transparent,
        body: ResponsiveWidget(largeScreen: largeForgetView(authVm),mediumScreen: smallForgetView(authVm),smallScreen: smallForgetView(authVm)),
      );
    });
  }

  Widget largeForgetView(AuthVM authVm){
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 7.sp),
        decoration: BoxDecoration(
          color: R.colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        width: 25.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: R.colors.offWhite)),
                  child: Icon(
                    Icons.clear,
                    size: 15,
                    color: R.colors.offWhite,
                  ),
                ),
              ),
            ),
            Text(
              LocalizationMap.getTranslatedValues('forgot_password'),
              style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(context, 25),
                fw: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              LocalizationMap.getTranslatedValues(
                  'enter_your_registered_email_to_get_change_password_link'),
              textAlign: TextAlign.center,
              style: R.textStyles.poppins(
                  color: R.colors.infoTextColor,
                  fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15)),
            ),
            SizedBox(height: 3.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                LocalizationMap.getTranslatedValues("email"),
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: TextFormField(
                controller: emailController,
                focusNode: emailFocus,
                validator: FieldValidator.validateEmail,
                style:R.textStyles.poppins(
                  color: R.colors.offWhite,
                  fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
                  fw: FontWeight.w300,
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: R.decoration.fieldDecoration(
                  hintText: "enter_email",
                ),
              ),
            ),
            SizedBox(
              height: 5.sp,
            ),
            Container(
              height: 10.sp,
              width: 10.w,
              margin: EdgeInsets.symmetric(vertical: 4.sp),
              child: AppButton(
                buttonTitle: 'proceed',
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    authVm.forgotPassword(emailController.text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget smallForgetView(AuthVM authVm){
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.sp, horizontal: 7.sp),
        decoration: BoxDecoration(
          color: R.colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 1, color: R.colors.black)),
                  child: Icon(
                    Icons.clear,
                    size: 15,
                    color: R.colors.black,
                  ),
                ),
              ),
            ),
            Text(
              LocalizationMap.getTranslatedValues('forgot_password'),
              style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(context, 25),
                fw: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              LocalizationMap.getTranslatedValues(
                  'enter_your_registered_email_to_get_change_password_link'),
              textAlign: TextAlign.center,
              style: R.textStyles.poppins(
                  color: R.colors.infoTextColor,
                  fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15)),
            ),
            SizedBox(height: 3.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                LocalizationMap.getTranslatedValues("email"),
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: TextFormField(
                controller: emailController,
                focusNode: emailFocus,
                validator: FieldValidator.validateEmail,
                style:R.textStyles.poppins(
                  color: R.colors.offWhite,
                  fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
                  fw: FontWeight.w300,
                ),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: R.decoration.fieldDecoration(
                  hintText: "enter_email",
                ),
              ),
            ),
            SizedBox(
              height: 5.sp,
            ),
            Container(
              height: 15.sp,
              width: 15.w,
              margin: EdgeInsets.symmetric(vertical: 4.sp),
              child: AppButton(
                buttonTitle: 'proceed',
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    authVm.forgotPassword(emailController.text);
                    // Get.back();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }





}
