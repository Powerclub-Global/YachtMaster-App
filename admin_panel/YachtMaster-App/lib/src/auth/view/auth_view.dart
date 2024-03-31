import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/utils/heights_widths.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';

import '../../../resources/localization/localization_map.dart';
import '../../../resources/resources.dart';
import '../../../resources/validator.dart';
import '../../../utils/text_size.dart';
import '../../../utils/widgets/app_button.dart';
import '../vm/auth_vm.dart';
import 'widgets/forgot_password.dart';

class AuthView extends StatefulWidget {
  static String route = "/auth_view";
  const AuthView({Key? key}) : super(key: key);

  @override
  AuthViewState createState() => AuthViewState();
}

class AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passObscure = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVM>(builder: (context, authVm, _) {
      return Scaffold(
        backgroundColor: R.colors.lightGreyColor,
        body: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveWidget.isLargeScreen(context) ? 12.w : 5.w,
                vertical: ResponsiveWidget.isLargeScreen(context) ? 7.h : 2.h),
            color: R.colors.black,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: R.colors.dividerColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ResponsiveWidget(
                  largeScreen: largeAuthView(authVm),
                  mediumScreen: smallAuthView(authVm),
                  smallScreen: smallAuthView(authVm)),
            ),
          ),
        ),
      );
    });
  }

  Widget largeAuthView(AuthVM authVm) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocalizationMap.getTranslatedValues("welcome_to_login"),
                  style: R.textStyles.poppins(
                    fw: FontWeight.bold,
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 25),
                  ),
                ),
                h3,
                Text(
                  LocalizationMap.getTranslatedValues("please_fill_email_password_to_login_your_app_account"),
                  textAlign: TextAlign.center,
                  style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    color: R.colors.greyHintColor,
                  ),
                ),
                h5,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    LocalizationMap.getTranslatedValues("email"),
                    style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      fw: FontWeight.w500,
                    ),
                  ),
                ),
                emailField(),
                h2,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    LocalizationMap.getTranslatedValues("password"),
                    style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      fw: FontWeight.w500,
                    ),
                  ),
                ),
                passwordField(authVM: authVm),
                h2,
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //       onPressed: () {
                //         Get.dialog(const ForgotPassword());
                //       },
                //       child: Text(
                //         LocalizationMap.getTranslatedValues("forgot_password_question"),
                //         style: R.textStyles.poppins(
                //             fw: FontWeight.w500,
                //             fs: AdaptiveTextSize.getAdaptiveTextSize(context, 18)),
                //       )),
                // ),
                h5,
                SizedBox(
                  width: Get.width,
                  height: 7.h,
                  child: AppButton(
                    buttonTitle: "login_now",
                    onTap: () => loginFN(vm: authVm),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: R.colors.primary,
            ),
            child: Image.asset(
              R.images.splashIcon,
              scale: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget smallAuthView(AuthVM authVm) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocalizationMap.getTranslatedValues("welcome_to_login"),
                  style: R.textStyles.poppins(
                    fw: FontWeight.bold,
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 25),
                  ),
                ),
                h3,
                Text(
                  LocalizationMap.getTranslatedValues("please_fill_email_password_to_login_your_app_account"),
                  textAlign: TextAlign.center,
                  style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    color: R.colors.greyText,
                  ),
                ),
                h5,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    LocalizationMap.getTranslatedValues("email"),
                    style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      fw: FontWeight.w500,
                    ),
                  ),
                ),
                emailField(),
                h2,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    LocalizationMap.getTranslatedValues("password"),
                    style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      fw: FontWeight.w500,
                    ),
                  ),
                ),
                passwordField(authVM: authVm),
                h2,
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //       onPressed: () {
                //         Get.dialog(const ForgotPassword());
                //       },
                //       child: Text(
                //         LocalizationMap.getTranslatedValues("forgot_password_question"),
                //         style: R.textStyles.poppins(
                //             fw: FontWeight.w500,
                //             fs: AdaptiveTextSize.getAdaptiveTextSize(context, 18)),
                //       )),
                // ),
                h5,
                SizedBox(
                  width: 40.w,
                  height: 8.h,
                  child: AppButton(
                    buttonTitle: "login_now",
                    onTap: () => loginFN(vm: authVm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget emailField() {
    return TextFormField(
        controller: emailController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        focusNode: emailFocus,
        style:R.textStyles.poppins(
          color: R.colors.offWhite,
          fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
          fw: FontWeight.w300,
        ),
        validator: FieldValidator.validateEmail,
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.emailAddress,
        decoration: R.decoration.fieldDecoration(
          hintText: "email_hint",
        ));
  }

  Widget passwordField({required AuthVM authVM}) {
    return TextFormField(
      controller: passwordController,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      focusNode: passwordFocus,
      validator: FieldValidator.validatePassword,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      obscureText: passObscure,
      style:R.textStyles.poppins(
        color: R.colors.offWhite,
        fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
        fw: FontWeight.w300,
      ),
      onFieldSubmitted: (value) => loginFN(vm: authVM),
      decoration: R.decoration.fieldDecoration(
          hintText: "password_hint",
          suffixIcon: InkWell(
            onTap: () {
              setState(() {
                passObscure = !passObscure;
              });
            },
            child: Icon(
              passObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: R.colors.hintIconColor,
            ),
          )),
    );
  }

  void loginFN({required AuthVM vm}) {
    if (_formKey.currentState!.validate()) {
      // Get.offAllNamed(DashboardView.route);
      vm.signIn(emailController.text, passwordController.text);
    }
  }
}
