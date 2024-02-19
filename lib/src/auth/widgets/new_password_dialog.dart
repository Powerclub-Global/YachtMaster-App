import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/yacht/widgets/congo_bottomSheet.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/validation.dart';

class NewPasswordDialog extends StatefulWidget {

  @override
  _NewPasswordDialogState createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<NewPasswordDialog> {
  final formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();
  FocusNode passwordFn= FocusNode();
  FocusNode confirmPassFn= FocusNode();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration:  BoxDecoration(
          color: Colors.black,
          boxShadow: [ BoxShadow(blurRadius: 3.0)],
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Get.width * .07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: Get.height * 0.01),
                width: Get.width * .2,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: Get.height * .04,
              ),
              SizedBox(
                  height: Get.height * .085,
                  child: Image.asset(R.images.otp)),
              SizedBox(
                height: Get.height * .04,
              ),
              Text('New Password',
                  style: R.textStyle.helveticaBold().copyWith(
                      color:  R.colors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: Get.height * .024)),
              SizedBox(
                height: Get.height * .02,
              ),
              Text(
                'must include upper case and numbers',
                style:R.textStyle.helvetica().copyWith(
                  color: Colors.white,
                  fontSize: Get.width * .04,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: Get.height * .01,
              ),
              Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      h2,
                      label(getTranslated(context,  "password",)??""),
                      h0P5,
                      TextFormField(
                        focusNode: passwordFn,
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
                                .requestFocus(confirmPassFn);
                          });
                        },
                        controller: passwordController,
                        validator: (val) =>
                            FieldValidator.validatePasswordSignup(
                                passwordController.text),
                        decoration: AppDecorations.suffixTextField(

                            "enter_password",
                            R.textStyle.helvetica().copyWith(
                                color: passwordFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                            Image.asset(R.images.lock,scale: 14,
                                color: passwordFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor)),
                      ),
                      h2,
                      label(getTranslated(context,  "confirm_password",)??""),
                      h0P5,
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        focusNode: confirmPassFn,
                        onChanged: (v) {
                          setState(() {});
                        },
                        onTap: () {
                          setState(() {});
                        },
                        onFieldSubmitted: (a) {
                          setState(() {
                            FocusScope.of(Get.context!)
                                .requestFocus(new FocusNode());
                          });
                        },
                        controller: confirmPassController,
                        validator:(value){
                          if (value!.isEmpty) return "Confirm Password Required";
                          if (value.length < 6)
                            return "Password should consists of minimum 6 character";
                          if (value.length > 50)
                            return "Maximum 50 characters are allowed";
                          if (!RegExp(r"^(?=.*?[0-9])").hasMatch(value)) {
                            return 'Password should include 1 number';
                          }if (!RegExp(r'^(?=.*?[!@#\$&*~])').hasMatch(value)) {
                            return 'Password should include 1 special character';
                          }
                          if(value!=passwordController.text)
                          {
                            return 'Password did not match';
                          }
                          return null;
                        },
                        decoration: AppDecorations.suffixTextField(

                            "enter_confirm_password",
                            R.textStyle.helvetica().copyWith(
                                color: confirmPassFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                            Image.asset(R.images.lock,scale: 14,
                                color: confirmPassFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor)),
                      ),
                    ],
                  )),
              SizedBox(
                height: Get.height * .03,
              ),
              GestureDetector(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    Get.back();
                    Get.bottomSheet(Congoratulations(getTranslated(context, "your_password_has_been_successfully_updated")??"",(){
                      Timer(Duration(seconds: 2), () {
                        Get.back();
                      });
                    }),barrierColor: R.colors.grey.withOpacity(.30));

                  }
                },
                child:  Container(
                  height: Get.height*.06,width: Get.width*.6,
                  decoration: AppDecorations.gradientButton(radius: 30),
                  child: Center(
                    child: Text("${getTranslated(context, "save")?.toUpperCase()}",
                      style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                        fontSize: 12.sp,fontWeight: FontWeight.bold,
                      ) ,),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}