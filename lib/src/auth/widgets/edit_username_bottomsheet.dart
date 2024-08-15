import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/image_picker_services.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/validation.dart';
import '../../../../utils/countryCodeConverter.dart';

class EditUsername extends StatefulWidget {
  @override
  _EditUsernameState createState() => _EditUsernameState();
}

class _EditUsernameState extends State<EditUsername> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  FocusNode firstNameFn = FocusNode();
  FocusNode usernameFn = FocusNode();
  String? countryCode;
  File? pickedImage;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AuthVm authVm = Provider.of<AuthVm>(context, listen: false);
      authVm.stopLoader();
      pickedImage = null;
      Future.delayed(Duration(milliseconds: 100), () {
        countryCode =
            seperatePhoneAndDialCode(authVm.userModel?.dialCode ?? "+92");
        Get.forceAppUpdate();
      });
      usernameController.text = authVm.userModel!.username ?? "";

      // if(countries.where((element) => element.dialCode==authVm.userModel?.dialCode?.replaceAll("+", "")).toList().isNotEmpty)
      // {
      //   countryCode =countries.where((element) => element.dialCode==authVm.userModel?.dialCode?.replaceAll("+", "")).toList().first.code;
      // }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVm>(builder: (context, authVm, _) {
      return ModalProgressHUD(
        inAsyncCall: authVm.isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                Helper.focusOut(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: R.colors.black,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    h1,
                    Container(
                      margin: EdgeInsets.only(top: Get.height * 0.01),
                      width: Get.width * .2,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Get.width * .07),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          h3,
                          Text(
                              "${getTranslated(context, "edit_username").toString().capitalize}",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Get.width * .053)),
                          h3,
                          Form(
                            key: formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                h1P5,
                                label(getTranslated(
                                      context,
                                      "username",
                                    ) ??
                                    ""),
                                h0P5,
                                TextFormField(
                                  focusNode: usernameFn,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (v) async {
                                    await authVm.isUsernameAvailable(v);
                                  },
                                  onFieldSubmitted: (a) {
                                    setState(() {
                                      FocusScope.of(Get.context!)
                                          .requestFocus(new FocusNode());
                                    });
                                  },
                                  controller: usernameController,
                                  validator: (val) =>
                                      FieldValidator.validateUsername(val),
                                  decoration: AppDecorations.suffixTextField(
                                      "enter_username",
                                      R.textStyle.helvetica().copyWith(
                                          color: usernameFn.hasFocus
                                              ? R.colors.themeMud
                                              : R.colors.charcoalColor,
                                          fontSize: 10.sp),
                                      authVm.usernameIsAvailable
                                          ? Icon(
                                              Icons.verified_outlined,
                                              size: 23.sp,
                                              color: Colors.green,
                                            )
                                          : null),
                                ),
                              ],
                            ),
                          ),
                          // Spacer(),
                          SizedBox(
                            height: Get.height * .05,
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (formKey.currentState!.validate()) {
                                if (authVm.usernameIsAvailable) {
                                  await authVm.updateUsernameDataToDB(
                                      usernameController.text);
                                  Navigator.pop(context);
                                  return;
                                }
                                Fluttertoast.showToast(
                                    msg: "This username is not available");
                              }
                            },
                            child: Container(
                              height: Get.height * .06,
                              width: Get.width * .65,
                              decoration:
                                  AppDecorations.gradientButton(radius: 30),
                              child: Center(
                                child: Text(
                                  "${getTranslated(context, "save")?.toUpperCase()}",
                                  style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          h1,
                        ],
                      ),
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
