import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class CreateUsername extends StatelessWidget {
  static String route = "/createUsername";
  const CreateUsername({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    User? user = args["user"];
    bool isApple = args["isApple"];
    String phoneNo = args["phoneNo"];
    String countryCode = args["countryCode"];
    final formKey = GlobalKey<FormState>();
    TextEditingController usernameController = TextEditingController();
    return Consumer<AuthVm>(builder: (context, provider, _) {
      return Scaffold(
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  R.images.logo,
                  scale: 3,
                ),
                h1P5,
                SizedBox(
                  width: Get.width * .8,
                  child: Text(
                    getTranslated(context,
                            "please_create_a_username_because_it_is_required") ??
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
                  child: TextFormField(
                    cursorRadius: const Radius.circular(10),
                    cursorHeight: 14,
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                    validator: (value) {
                      if (value!.length > 5) {
                        return null;
                      } else {
                        return "Username should contain more than 5 characters.";
                      }
                    },
                    controller: usernameController,
                    onChanged: (value) async {
                      await provider.isUsernameAvailable(value);
                    },
                    keyboardType: TextInputType.text,
                    autocorrect: false,
                    decoration: InputDecoration(
                        floatingLabelStyle:
                            TextStyle(fontSize: 14.sp, color: Colors.amber),
                        prefixStyle: TextStyle(fontSize: 14.sp),
                        errorStyle: TextStyle(fontSize: 14.sp),
                        contentPadding: EdgeInsets.symmetric(vertical: 1.sp),
                        icon: Icon(
                          Icons.account_circle,
                          size: 23.sp,
                        ),
                        labelText: "Username",
                        prefixText: "@",
                        labelStyle: TextStyle(fontSize: 13.sp),
                        suffixIcon: provider.usernameIsAvailable
                            ? Icon(
                                Icons.verified_outlined,
                                size: 23.sp,
                                color: Colors.green,
                              )
                            : null),
                  ),
                ),
                h9,
                GestureDetector(
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      print("starting account creation");
                      provider.addUsernameFinishSignUp(
                          user!,
                          countryCode,
                          phoneNo,
                          isApple,
                          true,
                          usernameController.text.trim());
                    }
                  },
                  child: Container(
                    height: Get.height * .06,
                    decoration: AppDecorations.gradientButton(radius: 30),
                    child: Center(
                      child: Text(
                        "${getTranslated(context, "create_account")?.toUpperCase()}",
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
          ),
        ),
      );
    });
  }
}
