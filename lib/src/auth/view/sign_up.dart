import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../localization/app_localization.dart';
import '../../../resources/decorations.dart';
import '../view_model/auth_vm.dart';
import '../../base/settings/view/privacy_policy.dart';
import '../../base/settings/view/terms_of_services.dart';
import '../../base/settings/view_model/settings_vm.dart';
import '../../../utils/heights_widths.dart';
import '../../../utils/helper.dart';
import '../../../utils/validation.dart';
import '../../../utils/zbot_toast.dart';

import '../../../resources/resources.dart';
import '../../../utils/keyboard_actions.dart';

class SignUpScreen extends StatefulWidget {
  static String route = "/signUpScreen";

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final signupKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  FocusNode emailFn = FocusNode();
  FocusNode usernameFn = FocusNode();

  TextEditingController phoneNumController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  FocusNode passwordFn = FocusNode();
  FocusNode firstNameFn = FocusNode();
  FocusNode lastNameFn = FocusNode();
  FocusNode phoneNumFn = FocusNode();
  FocusNode confirmPassFn = FocusNode();
  String countryCode = "US";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var settingsVm = Provider.of<SettingsVm>(context, listen: false);
      settingsVm.fetchContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVm>(builder: (context, provider, _) {
      return ModalProgressHUD(
        inAsyncCall: provider.isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: GestureDetector(
          onTap: () {
            Helper.focusOut(context);
            setState(() {});
          },
          child: Scaffold(
            backgroundColor: R.colors.black,
            body: Form(
              key: signupKey,
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
                    getTranslated(context, "sign_up") ?? "",
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: R.colors.whiteColor, fontSize: 17.sp),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 23.sp),
                      child: ListView(
                        children: [
                          label(getTranslated(context, "first_name") ?? ""),
                          h0P5,
                          TextFormField(
                            focusNode: firstNameFn,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.sentences,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(25)
                            ],
                            onChanged: (v) {
                              setState(() {});
                            },
                            onTap: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (a) {
                              setState(() {
                                FocusScope.of(Get.context!)
                                    .requestFocus(lastNameFn);
                              });
                            },
                            controller: firstNameController,
                            validator: (val) =>
                                FieldValidator.validateFirstName(
                                    firstNameController.text),
                            decoration: AppDecorations.suffixTextField(
                                "enter_first_name",
                                R.textStyle.helvetica().copyWith(
                                    color: firstNameFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                Image.asset(R.images.name,
                                    scale: 14,
                                    color: firstNameFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor)),
                          ),
                          h2,
                          label(getTranslated(context, "last_name") ?? ""),
                          h0P5,
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            focusNode: lastNameFn,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(25)
                            ],
                            textCapitalization: TextCapitalization.sentences,
                            onChanged: (v) {
                              setState(() {});
                            },
                            onTap: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (a) {
                              setState(() {
                                FocusScope.of(Get.context!)
                                    .requestFocus(emailFn);
                              });
                            },
                            controller: lastNameController,
                            validator: (val) => FieldValidator.validateLastName(
                                lastNameController.text),
                            decoration: AppDecorations.suffixTextField(
                                "enter_last_name",
                                R.textStyle.helvetica().copyWith(
                                    color: lastNameFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                Image.asset(R.images.name,
                                    scale: 14,
                                    color: lastNameFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor)),
                          ),
                          h2,
                          label(
                              getTranslated(context, "create_username") ?? ""),
                          h0P5,
                          TextFormField(
                            focusNode: usernameFn,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) async {
                              print(value);
                              await provider.isUsernameAvailable(value);
                              setState(() {});
                            },
                            onTap: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (a) {
                              setState(() {
                                FocusScope.of(Get.context!)
                                    .requestFocus(phoneNumFn);
                              });
                            },
                            controller: usernameController,
                            validator: (value) =>
                                FieldValidator.validateUsername(
                                    usernameController.text),
                            decoration: AppDecorations.suffixTextField(
                                "create_username",
                                R.textStyle.helvetica().copyWith(
                                    color: usernameFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                provider.usernameIsAvailable
                                    ? Icon(
                                        Icons.verified_outlined,
                                        size: 23.sp,
                                        color: Colors.green,
                                      )
                                    : null,
                                prefix: '@'),
                          ),
                          h2,
                          label(getTranslated(context, "email") ?? ""),
                          h0P5,
                          TextFormField(
                            focusNode: emailFn,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) {
                              setState(() {});
                            },
                            onTap: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (a) {
                              setState(() {
                                FocusScope.of(Get.context!)
                                    .requestFocus(usernameFn);
                              });
                            },
                            controller: emailController,
                            validator: (val) => FieldValidator.validateEmail(
                                emailController.text),
                            decoration: AppDecorations.suffixTextField(
                                "enter_email",
                                R.textStyle.helvetica().copyWith(
                                    color: emailFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                Container(
                                  alignment: Alignment.center,
                                  width: Get.width * .1,
                                  child: Image.asset(R.images.email,
                                      scale: 15,
                                      color: emailFn.hasFocus
                                          ? R.colors.themeMud
                                          : R.colors.charcoalColor),
                                )),
                          ),
                          h2,
                          label(getTranslated(context, "phone_num") ?? ""),
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

                              decoration: InputDecoration(
                                hintText: getTranslated(
                                    Get.context!, "0000000000000"),
                                hintStyle: R.textStyle.helvetica().copyWith(
                                    color: emailFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                suffixIconConstraints:
                                    BoxConstraints(maxWidth: 50, minWidth: 50),
                                filled: true,
                                isDense: true,
                                fillColor: R.colors.whiteColor,
                                suffixIcon: Image.asset(R.images.phone,
                                    scale: 14,
                                    color: phoneNumFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor),
                                errorStyle: R.textStyle.helvetica().copyWith(
                                    color: R.colors.redColor, fontSize: 9.sp),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: R.colors.black)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: R.colors.themeMud)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.red)),
                              ),
                              initialCountryCode: countryCode,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]"))
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
                                Helper.moveFocus(context, passwordFn);
                              },
                            ),
                          ),
                          h4,
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(children: [
                              TextSpan(
                                text:
                                    "${getTranslated(context, "before_using_this_app_review_its_privacy")} ",
                                style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 12.sp,
                                    ),
                              ),
                              TextSpan(
                                text: getTranslated(context, "privacy_policy"),
                                style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      height: 1.5,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    log("_________________________________________CLICK");
                                    Get.toNamed(PrivacyPolicy.route);
                                  },
                              ),
                              TextSpan(
                                  text: " ${getTranslated(context, "and")} ",
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 11.sp,
                                      height: 1.5)),
                              TextSpan(
                                text:
                                    getTranslated(context, "terms_of_services"),
                                style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    log("_________________________________________CLICK");
                                    Get.toNamed(TermsOfServices.route);
                                  },
                              ),
                            ]),
                          ),
                          h2,
                          GestureDetector(
                            onTap: () async {
                              if (signupKey.currentState!.validate()) {
                                ZBotToast.loadingShow();
                                await provider.onClickSignup(
                                    emailController.text,
                                    firstNameController.text,
                                    lastNameController.text,
                                    countryCode.trim(),
                                    phoneNumController.text.trim(),
                                    usernameController.text.trim());
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          h9,
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 30),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "already_have_an_account") ?? "",
                      style: R.textStyle.helvetica().copyWith(
                          color: R.colors.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp),
                    ),
                    SizedBox(
                      width: 1.w,
                    ),
                    Text(
                      getTranslated(context, "sign_in") ?? "",
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
        ),
      );
    });
  }
}
