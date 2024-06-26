import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/src/auth/view/sign_up.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/zbot_toast.dart';
import'dart:io' show Platform;
import '../../../resources/resources.dart';
import '../../../utils/keyboard_actions.dart';

class LoginScreen extends StatefulWidget {
  static String route = "/loginScreen";

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isShowPassLogin = false;
  final _loginKey = GlobalKey<FormState>();
  FocusNode phoneNumFn = FocusNode();
  TextEditingController phoneNumController = TextEditingController();
  String countryCode = "US";
  bool isLoading=false;
  startLoader()
  {
    setState(() {
      isLoading=true;
    });
  }
  stopLoader()
  {
    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVm>(builder: (context, provider, _) {
      return GestureDetector(
        onTap: () {
          Helper.focusOut(context);
          setState(() {});
        },
        child: Scaffold(
          backgroundColor: R.colors.black,
          body: Form(
            key: _loginKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                h5,
                Image.asset(
                  R.images.logo,
                  scale: 3,
                ),
                h5,
                Text(
                  getTranslated(context, "sign_in") ?? "",
                  style: R.textStyle
                      .helvetica()
                      .copyWith(color: R.colors.whiteColor, fontSize: 17.sp),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23.sp),
                    child: ListView(
                      children: [
                        h4,
                        label(getTranslated(
                          context,
                          "phone_num",
                        ) ??
                            ""),
                        h0P5,
                        KeyboardActions(
                          config: buildConfigDone(context, phoneNumFn,
                              nextFocus: FocusNode(), isDone: true),
                          disableScroll: true,
                          autoScroll: false,
                          child: IntlPhoneField(
                            controller: phoneNumController,
                            focusNode: phoneNumFn,
                            autovalidateMode:
                            AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.next,
                            // disableLengthCheck: true,
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
                        SizedBox(
                          height: 8.h,
                        ),
                        GestureDetector(
                          onTap: () async {

                            if (_loginKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              ZBotToast.loadingShow();
                              await provider.onClickLoginOTP(countryCode.trim(),phoneNumController.text.trim());

                            }
                          },
                          child: Container(
                            height: Get.height * .06,
                            decoration:
                            AppDecorations.gradientButton(radius: 30),
                            child: Center(
                              child: Text(
                                getTranslated(context, "login") ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

                        h9,

                        if(Provider.of<BookingsVm>(context,listen: false).appUrlModel?.is_enable_social_login==true)...[
                          Row(
                          children: [
                            Expanded(
                                child: Divider(
                                  color: R.colors.grey.withOpacity(.50),
                                  thickness: 1,
                                )),
                            Expanded(
                              child: Text(
                                getTranslated(context, "sign_in_with") ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: R.colors.grey.withOpacity(.50),
                                )),
                          ],
                        ),
                        h5,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           if(Platform.isIOS) socialLinks(R.images.appleLogo, () async {
                              await provider.onClickAppleLogin();
                            }),
                            w6,
                            socialLinks(R.images.google, () async {
                              await provider.onClickGoogleLogin();
                            })
                          ],
                        )]
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar:  Padding(
            padding: EdgeInsets.only(top: 20, bottom: 30),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(SignUpScreen.route);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getTranslated(context, "dont_have_account") ?? "",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp),
                  ),
                  SizedBox(
                    width: 1.w,
                  ),
                  Text(
                    getTranslated(context, "sign_up") ?? "",
                    style: R.textStyle.helveticaBold().copyWith(
                        color: R.colors.themeMud,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget socialLinks(String img, Function() callBack) {
    return GestureDetector(
        onTap: callBack,
        child: Image.asset(
          img,
          height: 42,
        ));
  }
}
