import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';

class AskSuperHost extends StatefulWidget {
  static String route="/askSuperHost";
  const AskSuperHost({Key? key}) : super(key: key);

  @override
  _AskSuperHostState createState() => _AskSuperHostState();
}

class _AskSuperHostState extends State<AskSuperHost> {
  final formKey = GlobalKey<FormState>();
  TextEditingController fullNameCon = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController subjectCon = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController descCon = TextEditingController();
  FocusNode emailFn = FocusNode();
  FocusNode descFn= FocusNode();
  FocusNode fullNameFn= FocusNode();
  FocusNode subjectFn= FocusNode();
  FocusNode phoneNumFn= FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.black,
      appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "host_support_center")??""),
      body:   Padding(
        padding:  EdgeInsets.symmetric(vertical: Get.height*.02),
        child: Column(
          children: [
            Form(key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Expanded(
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 23.sp),
                  child: ListView(
                    children: [
                      label(getTranslated(context,    "full_name",)??""),
                      h0P5,
                      TextFormField(
                        focusNode: fullNameFn,
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
                                .requestFocus(new FocusNode());
                          });
                        },
                        controller: fullNameCon,
                        validator: (val) =>
                            FieldValidator.validateFullName(
                                fullNameCon.text),
                        decoration: AppDecorations.suffixTextField(

                            "enter_full_name",
                            R.textStyle.helvetica().copyWith(
                                color: fullNameFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                            Image.asset(R.images.name,scale: 14,
                                color: fullNameFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor)),
                      ),
                      h2,
                      label(getTranslated(context,     "email",)??""),
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
                                .requestFocus(new FocusNode());
                          });
                        },
                        controller: emailController,
                        validator: (val) =>
                            FieldValidator.validateEmail(
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
                              width: Get.width*.1,
                              child: Image.asset(R.images.email,scale: 15,
                                  color: emailFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor),
                            )),
                      ),
                      h2,
                      label(getTranslated(context,     "phone_num",)??""),
                      h0P5,
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        focusNode: phoneNumFn,
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
                        controller: phoneNumController,
                        validator: (val) =>
                            FieldValidator.validateMobile(
                                phoneNumController.text),
                        decoration: AppDecorations.suffixTextField(

                            "0000000000000",
                            R.textStyle.helvetica().copyWith(
                                color: phoneNumFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                            Image.asset(R.images.phone,scale: 14,
                                color: phoneNumFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor)),
                      ),

                      h2,
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        focusNode: subjectFn,
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
                        controller: subjectCon,
                        validator: (val) =>
                            FieldValidator.validateSubject(
                                subjectCon.text),
                        decoration: AppDecorations.simpleTextField(
                          "subject",
                          R.textStyle.helvetica().copyWith(
                              color: subjectFn.hasFocus
                                  ? R.colors.themeMud
                                  : R.colors.charcoalColor,
                              fontSize: 10.sp),
                        ),
                      ),
                      h2,
                      TextFormField(
                        focusNode: descFn,
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
                                .requestFocus(new FocusNode());
                          });
                        },
                        maxLines: 6,
                        controller: descCon,
                        validator: (val) =>
                            FieldValidator.validateDesc(
                                descCon.text),
                        decoration: AppDecorations.simpleTextField(
                          "desc",
                          R.textStyle.helvetica().copyWith(
                              color: descFn.hasFocus
                                  ? R.colors.themeMud
                                  : R.colors.charcoalColor,
                              fontSize: 10.sp),
                        ),
                      ),
                      h5,

                      GestureDetector(
                        onTap: (){
                          if(formKey.currentState!.validate())
                          {
                            Get.back();
                            Helper.inSnackBar("Success", "Submitted successfully", R.colors.themeMud);

                          }
                        },
                        child: Container(
                          height: Get.height*.06,
                          decoration: AppDecorations.gradientButton(radius: 30),
                          child: Center(
                            child: Text("${getTranslated(context, "submit")?.toUpperCase()}",
                              style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                                fontSize: 12.sp,fontWeight: FontWeight.bold,
                              ) ,),
                          ),
                        ),
                      ),
                      h9,

                    ],
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
