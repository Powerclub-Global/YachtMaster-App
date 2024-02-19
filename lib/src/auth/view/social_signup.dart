import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';

import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

import '../../../resources/resources.dart';
import '../../../utils/keyboard_actions.dart';

class SocialSignup extends StatefulWidget {
  static String route = "/socialSignup";

  @override
  _SocialSignupState createState() => _SocialSignupState();
}

class _SocialSignupState extends State<SocialSignup> {
  final formKey = GlobalKey<FormState>();
  FocusNode phoneNumFn = FocusNode();
  TextEditingController phoneNumController = TextEditingController();
  String countryCode = "US";
  User? user;
  bool isApple=false;
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    user = args["user"];
    isApple = args["isApple"];
    return Consumer<AuthVm>(builder: (context, provider, _) {
      return ModalProgressHUD(
        inAsyncCall: provider.isLoading,
        progressIndicator:   SpinKitPulse(color: R.colors.themeMud,),
        child: GestureDetector(
          onTap: () {
            Helper.focusOut(context);
            setState(() {});
          },
          child: Scaffold(
            backgroundColor: R.colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: R.colors.whiteColor,
                  )),
            ),
            body: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Image.asset(
                    R.images.logo,
                    scale: 3,
                  ),
                  h5,
                  Text(
                    getTranslated(context, "sign_up") ?? "",
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: R.colors.whiteColor, fontSize: 17.sp),
                  ),
                  h1P5,
                  SizedBox(
                    width: Get.width * .8,
                    child: Text(
                      getTranslated(context,
                              "please_provide_your_phone_number_because_it_is_required") ??
                          "",
                      style: R.textStyle.helvetica().copyWith(
                            color: R.colors.whiteColor,
                            fontSize: 13.sp,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  h4,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23.sp),
                    child: Column(
                      children: [
                        label(getTranslated(context, "phone_num",) ?? ""),
                        h0P5,
                        KeyboardActions(
                          config: buildConfigDone(context, phoneNumFn,
                              nextFocus: FocusNode(), isDone: true),
                          disableScroll: true,
                          autoScroll: false,
                          child: IntlPhoneField(
                            controller: phoneNumController,
                            focusNode: phoneNumFn,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.next,
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.charcoalColor, fontSize: 10.sp),
                            decoration: AppDecorations.suffixTextField(
                                "0000000000000",
                                R.textStyle.helvetica().copyWith(
                                      color: phoneNumFn.hasFocus
                                          ? R.colors.themeMud
                                          : R.colors.charcoalColor,
                                      fontSize: 10.sp,
                                    ),
                                Image.asset(R.images.phone,
                                    scale: 14,
                                    color: phoneNumFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor)),
                            initialCountryCode: countryCode,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            dropdownTextStyle: R.textStyle
                                .helveticaBold()
                                .copyWith(
                                    color: phoneNumFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                            flagsButtonPadding:
                                EdgeInsets.symmetric(horizontal: 4.w),
                            showDropdownIcon: false,
                            showCountryFlag: false,
                            onChanged: (phone) {
                              setState(() {
                                countryCode = phone.countryCode;
                              });
                              log("_______________$countryCode{}");
                              print(phone.completeNumber);
                            },
                            onCountryChanged: (phone) {
                              setState(() {
                                countryCode = phone.code;
                              });
                              log("_______________$countryCode");
                              // print(phone.completeNumber);
                            },
                            onSubmitted: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        h9,
                        GestureDetector(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              await provider.onClickSocialSignup(user,countryCode.trim(),phoneNumController.text.trim(),true,isApple:isApple);
                            }
                          },
                          child: Container(
                            height: Get.height * .06,
                            decoration:
                                AppDecorations.gradientButton(radius: 30),
                            child: Center(
                              child: Text(
                                "${getTranslated(context, "sign_up")?.toUpperCase()}",
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
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
