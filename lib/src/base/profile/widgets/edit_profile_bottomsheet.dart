import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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
import '../../../../utils/keyboard_actions.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumController = TextEditingController();
  FocusNode firstNameFn = FocusNode();
  FocusNode lastNameFn = FocusNode();
  FocusNode phoneNumFn = FocusNode();
  String? countryCode;
  File? pickedImage;
  @override
  void initState() {
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     AuthVm authVm = Provider.of<AuthVm>(context, listen: false);
     authVm.stopLoader();
     pickedImage=null;
    Future.delayed(Duration(milliseconds: 100),(){
      countryCode=seperatePhoneAndDialCode(authVm.userModel?.dialCode??"+92");
      Get.forceAppUpdate();
    });
     firstNameController.text = authVm.userModel?.firstName ?? "";
     lastNameController.text = authVm.userModel?.lastName ?? "";
     phoneNumController.text = authVm.userModel?.number ?? "";

     // if(countries.where((element) => element.dialCode==authVm.userModel?.dialCode?.replaceAll("+", "")).toList().isNotEmpty)
     // {
     //   countryCode =countries.where((element) => element.dialCode==authVm.userModel?.dialCode?.replaceAll("+", "")).toList().first.code;
     // }

   });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BaseVm, AuthVm>(builder: (context, provider, authVm, _) {
      log("C:${countryCode}");
      return ModalProgressHUD(
        inAsyncCall: authVm.isLoading,
        progressIndicator:   SpinKitPulse(color: R.colors.themeMud,),
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
                      padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          h3,
                          Text(
                              "${getTranslated(context, "edit_profile").toString().capitalize}",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Get.width * .053)),
                          h3,
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircularProfileAvatar(
                                "",
                                radius: 25.sp,
                                child:pickedImage!=null?
                                    Image.file(pickedImage!):
                                CachedNetworkImage(
                                  imageUrl:  authVm.userModel?.imageUrl?.isEmpty==true || authVm.userModel?.imageUrl==null?
                                  R.images.dummyDp:authVm.userModel?.imageUrl??"",
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                      SpinKitPulse(color: R.colors.themeMud,),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                   pickedImage =
                                   await ImagePickerServices().getImage();
                                   setState(() {

                                   });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: R.colors.themeMud),
                                      color: R.colors.whiteColor,
                                      shape: BoxShape.circle),
                                  padding: EdgeInsets.all(3),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: R.colors.themeMud,
                                    size: 15,
                                  ),
                                ),
                              )
                            ],
                          ),

                          h4,
                          Form(
                            key: formKey,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                label(getTranslated(
                                      context,
                                      "first_name",
                                    ) ??
                                    ""),
                                h0P5,
                                TextFormField(
                                  focusNode: firstNameFn,
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
                                h1P5,
                                label(getTranslated(
                                      context,
                                      "last_name",
                                    ) ??
                                    ""),
                                h0P5,
                                TextFormField(
                                  textInputAction: TextInputAction.next,
                                  focusNode: lastNameFn,
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
                                  controller: lastNameController,
                                  validator: (val) =>
                                      FieldValidator.validateLastName(
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
                                h1P5,
                                label(getTranslated(
                                      context,
                                      "phone_num",
                                    ) ??
                                    ""),
                                h0P5,
                               if(countryCode!=null) IgnorePointer(
                                  ignoring: true,
                                  child: KeyboardActions(
                                    config: buildConfigDone(context, phoneNumFn,
                                        nextFocus: FocusNode(), isDone: true),
                                    disableScroll: true,
                                    autoScroll: false,
                                    child: IntlPhoneField(
                                      readOnly: true,
                                      controller: phoneNumController,
                                      focusNode: phoneNumFn,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      textInputAction: TextInputAction.next,
                                      // disableLengthCheck: true,
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.charcoalColor,
                                          fontSize: 10.sp),
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
                                        log("_______________Country code:$countryCode{}");
                                        print(phone.completeNumber);
                                      },
                                      onCountryChanged: (phone) {
                                        setState(() {
                                          countryCode = phone.dialCode;
                                        });
                                        log("_______________C:$countryCode");
                                        // print(phone.completeNumber);
                                      },
                                      onSubmitted: (value) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
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
                                await authVm.onClickEditProfile(firstNameController.text, lastNameController.text, pickedImage, context);
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
