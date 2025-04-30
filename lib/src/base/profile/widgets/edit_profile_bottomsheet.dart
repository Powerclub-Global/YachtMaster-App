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
import 'package:yacht_master/src/auth/widgets/otp_dialog.dart';
import 'package:yacht_master/src/base/settings/view/settings_view.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/image_picker_services.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../base_vm.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/validation.dart';
import '../../../../utils/countryCodeConverter.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  FocusNode firstNameFn = FocusNode();
  FocusNode usernameFn = FocusNode();
  FocusNode lastNameFn = FocusNode();
  FocusNode phoneNumFn = FocusNode();
  FocusNode emailFn = FocusNode();
  String? countryCode;
  File? pickedImage;
  String? originalPhoneNumber;
  String? originalUsername;
  String? originalEmail;
  
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AuthVm authVm = Provider.of<AuthVm>(context, listen: false);
      authVm.stopLoader();
      pickedImage = null;
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          countryCode = seperatePhoneAndDialCode(
            authVm.userModel?.dialCode ?? "",
          );
        });
      });
      firstNameController.text = authVm.userModel?.firstName ?? "";
      lastNameController.text = authVm.userModel?.lastName ?? "";
      phoneNumController.text = authVm.userModel?.number ?? "";
      usernameController.text = authVm.userModel?.username ?? "";
      emailController.text = authVm.userModel?.email ?? "";
      
      // Store original values for comparison
      originalPhoneNumber = authVm.userModel?.number ?? "";
      originalUsername = authVm.userModel?.username ?? "";
      originalEmail = authVm.userModel?.email ?? "";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BaseVm, AuthVm>(
      builder: (context, provider, authVm, _) {
        log("C:$countryCode");
        return ModalProgressHUD(
          inAsyncCall: authVm.isLoading,
          progressIndicator: SpinKitPulse(color: R.colors.themeMud),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  Helper.focusOut(context);
                },
                child: DecoratedBox(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: Get.width * .07,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            h3,
                            Text(
                              "${getTranslated(context, "edit_profile").toString().capitalize}",
                              style: R.textStyle.helveticaBold().copyWith(
                                color: R.colors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: Get.width * .053,
                              ),
                            ),
                            h3,
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircularProfileAvatar(
                                  "",
                                  radius: 25.sp,
                                  child:
                                      pickedImage != null
                                          ? Image.file(pickedImage!)
                                          : CachedNetworkImage(
                                            imageUrl:
                                                authVm
                                                                .userModel
                                                                ?.imageUrl
                                                                ?.isEmpty ==
                                                            true ||
                                                        authVm
                                                                .userModel
                                                                ?.imageUrl ==
                                                            null
                                                    ? R.images.dummyDp
                                                    : authVm
                                                            .userModel
                                                            ?.imageUrl ??
                                                        "",
                                            fit: BoxFit.cover,
                                            progressIndicatorBuilder:
                                                (
                                                  context,
                                                  url,
                                                  downloadProgress,
                                                ) => SpinKitPulse(
                                                  color: R.colors.themeMud,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    pickedImage =
                                        await ImagePickerServices().getImage();
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: R.colors.themeMud,
                                      ),
                                      color: R.colors.whiteColor,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(3),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: R.colors.themeMud,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            h4,
                            Form(
                              key: formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                children: [
                                  label(
                                    getTranslated(context, "phone_number") ??
                                        "",
                                  ),
                                  h0P5,
                                  TextFormField(
                                    focusNode: phoneNumFn,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (v) {
                                      setState(() {});
                                    },
                                    onTap: () {
                                      setState(() {});
                                    },
                                    onFieldSubmitted: (a) {
                                      setState(() {
                                        FocusScope.of(
                                          Get.context!,
                                        ).requestFocus(FocusNode());
                                      });
                                    },
                                    controller: phoneNumController,
                                    validator:
                                        (val) =>
                                            FieldValidator.validateMobile(val),
                                    decoration: AppDecorations.suffixTextField(
                                      "enter_phone_number",
                                      R.textStyle.helvetica().copyWith(
                                        color:
                                            phoneNumFn.hasFocus
                                                ? R.colors.themeMud
                                                : R.colors.charcoalColor,
                                        fontSize: 10.sp,
                                      ),
                                      Image.asset(
                                        R.images.phone,
                                        scale: 14,
                                        color:
                                            phoneNumFn.hasFocus
                                                ? R.colors.themeMud
                                                : R.colors.charcoalColor,
                                      ),
                                    ),
                                  ),
                                  h1P5,
                                  label(getTranslated(context, "email") ?? ""),
                                  h0P5,
                                  TextFormField(
                                    textInputAction: TextInputAction.next,
                                    focusNode: emailFn,
                                    onChanged: (v) {
                                      setState(() {});
                                    },
                                    onTap: () {
                                      setState(() {});
                                    },
                                    onFieldSubmitted: (a) {
                                      setState(() {
                                        FocusScope.of(
                                          Get.context!,
                                        ).requestFocus(FocusNode());
                                      });
                                    },
                                    controller: emailController,
                                    validator:
                                        (val) =>
                                            FieldValidator.validateEmail(val),
                                    decoration: AppDecorations.suffixTextField(
                                      "enter_email",
                                      R.textStyle.helvetica().copyWith(
                                        color:
                                            emailFn.hasFocus
                                                ? R.colors.themeMud
                                                : R.colors.charcoalColor,
                                        fontSize: 10.sp,
                                      ),
                                      Image.asset(
                                        R.images.email,
                                        scale: 14,
                                        color:
                                            emailFn.hasFocus
                                                ? R.colors.themeMud
                                                : R.colors.charcoalColor,
                                      ),
                                    ),
                                  ),
                                  h1P5,
                                  label(
                                    getTranslated(context, "username") ?? "",
                                  ),
                                  h0P5,
                                  TextFormField(
                                    focusNode: usernameFn,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (v) async {
                                      if (v.length >= 5 && v != originalUsername) {
                                        await authVm.isUsernameAvailable(v);
                                        print('Checking username availability');
                                        setState(() {});
                                      } else if (v == originalUsername) {
                                        authVm.setUsernameAvailable(true);
                                        setState(() {});
                                      }
                                    },
                                    onTap: () {
                                      setState(() {});
                                    },
                                    onFieldSubmitted: (a) {
                                      setState(() {
                                        FocusScope.of(
                                          Get.context!,
                                        ).requestFocus(FocusNode());
                                      });
                                    },
                                    controller: usernameController,
                                    validator:
                                        (val) =>
                                            FieldValidator.validateUsername(
                                              val,
                                            ),
                                    decoration: AppDecorations.suffixTextField(
                                      "enter_username",
                                      R.textStyle.helvetica().copyWith(
                                        color:
                                            usernameFn.hasFocus
                                                ? R.colors.themeMud
                                                : R.colors.charcoalColor,
                                        fontSize: 10.sp,
                                      ),
                                      (usernameController.text == originalUsername || authVm.usernameIsAvailable)
                                          ? Icon(
                                            Icons.verified_outlined,
                                            size: 23.sp,
                                            color: Colors.green,
                                          )
                                          : Icon(
                                            Icons.error_outline,
                                            size: 23.sp,
                                            color: Colors.red,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Spacer(),
                            SizedBox(height: Get.height * .05),
                            GestureDetector(
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  if (usernameController.text.trim() != originalUsername && 
                                      !authVm.usernameIsAvailable) {
                                    Fluttertoast.showToast(
                                      msg: "Username is already taken. Please pick a different one.",
                                    );
                                    return;
                                  }

                                  try {
                                    bool phoneChanged = phoneNumController.text.trim() != originalPhoneNumber;
                                    bool usernameChanged = usernameController.text.trim() != originalUsername;
                                    bool emailChanged = emailController.text.trim() != originalEmail;
                                    
                                    if (usernameChanged) {
                                      await authVm.sendOtpForUsernameChange(
                                        phoneNumController.text.trim(),
                                      );
                                      await Get.dialog(
                                        OTP(
                                          phoneNumController.text.trim(),
                                          false,
                                          (otpCode) async {
                                            await authVm.verifyOtpForUsernameChange(
                                              countryCode ?? "",
                                              phoneNumController.text.trim(),
                                              otpCode,
                                              usernameController.text.trim(),
                                            );
                                            if (phoneChanged || emailChanged) {
                                              await authVm.updateEmailAndPhoneNumber(
                                                emailController.text.trim(),
                                                phoneNumController.text.trim(),
                                                countryCode ?? "",
                                              );
                                            }
                                            
                                            Fluttertoast.showToast(
                                              msg: "Profile updated successfully",
                                            );

                                            authVm.stopLoader();
                                            Get.offAllNamed(SettingsView.route);
                                          },
                                          () async {
                                            await authVm.sendOtpForUsernameChange(
                                              phoneNumController.text.trim(),
                                            );
                                          },
                                        ),
                                      );
                                    } else if (phoneChanged || emailChanged) {
                                      await authVm.updateEmailAndPhoneNumber(
                                        emailController.text.trim(),
                                        phoneNumController.text.trim(),
                                        countryCode ?? "",
                                      );
                                      
                                      Fluttertoast.showToast(
                                        msg: "Profile updated successfully",
                                      );

                                      authVm.stopLoader();
                                      Get.offAllNamed(SettingsView.route);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: "No changes to update",
                                      );
                                      Get.back();
                                    }
                                  } catch (e) {
                                    authVm.stopLoader();
                                    Fluttertoast.showToast(
                                      msg: "Error updating profile: $e",
                                    );
                                  }
                                }
                              },
                              child: Container(
                                height: Get.height * .06,
                                width: Get.width * .65,
                                decoration: AppDecorations.gradientButton(
                                  radius: 30,
                                ),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}