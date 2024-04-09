import 'dart:developer';
import 'dart:ui';

import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/constant.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/image_picker_services.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/widgets/otp_dialog.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';

class RulesBottomSheet extends StatefulWidget {
  String? title;
  String? subTitle;
  int? index;

  RulesBottomSheet({this.title, this.subTitle, this.index});

  @override
  _RulesBottomSheetState createState() => _RulesBottomSheetState();
}

class _RulesBottomSheetState extends State<RulesBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController titleCon = TextEditingController();
  TextEditingController descCon = TextEditingController();
  FocusNode titleFn = FocusNode();
  FocusNode descFn = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var yachtVm = Provider.of<YachtVm>(context, listen: false);

    if (widget.index == 8 &&
        (yachtVm.charterModel?.boardingInstructions?.title != "" &&
            yachtVm.charterModel?.boardingInstructions != null)) {
      titleCon.text = yachtVm.charterModel?.boardingInstructions?.title ?? '';
      descCon.text =
          yachtVm.charterModel?.boardingInstructions?.description ?? '';
    }
    if (widget.index == 7 &&
        (yachtVm.charterModel?.healthSafety?.title != "" &&
            yachtVm.charterModel?.healthSafety != null)) {
      titleCon.text = yachtVm.charterModel?.healthSafety?.title ?? '';
      descCon.text = yachtVm.charterModel?.healthSafety?.description ?? '';
    }
    if (widget.index == 6 &&
        (yachtVm.charterModel?.yachtRules?.title != "" &&
            yachtVm.charterModel?.yachtRules != null)) {
      titleCon.text = yachtVm.charterModel?.yachtRules?.title ?? '';
      descCon.text = yachtVm.charterModel?.yachtRules?.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YachtVm>(builder: (context, provider, _) {
      return BackdropFilter(
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
                            "${getTranslated(context, widget.title ?? "").toString().capitalize}",
                            style: R.textStyle.helveticaBold().copyWith(
                                color: R.colors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: Get.width * .053)),
                        h2,
                        Text(
                          "${getTranslated(context, widget.subTitle ?? "").toString().capitalize}",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteDull,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              fontSize: Get.width * .04),
                          textAlign: TextAlign.center,
                        ),
                        h4,
                        Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              label(getTranslated(
                                    context,
                                    "title",
                                  ) ??
                                  ""),
                              h0P5,
                              TextFormField(
                                focusNode: titleFn,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(25)
                                ],
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
                                controller: titleCon,
                                validator: (val) =>
                                    FieldValidator.validateRequired(
                                        titleCon.text),
                                decoration: AppDecorations.suffixTextField(
                                    "enter_title",
                                    R.textStyle.helvetica().copyWith(
                                        color: titleFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    SizedBox()),
                              ),
                              h1P5,
                              label(getTranslated(
                                    context,
                                    "desc",
                                  ) ??
                                  ""),
                              h0P5,
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                focusNode: descFn,
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
                                controller: descCon,
                                maxLines: 4,
                                validator: (val) =>
                                    FieldValidator.validateRequired(
                                        descCon.text),
                                decoration: AppDecorations.suffixTextField(
                                    "write_here",
                                    R.textStyle.helvetica().copyWith(
                                        color: descFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    SizedBox()),
                              ),
                            ],
                          ),
                        ),
                        // Spacer(),
                        SizedBox(
                          height: Get.height * .05,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              switch (widget.index) {
                                case 6:
                                  provider.charterModel?.yachtRules =
                                      YachtRules(
                                          title: titleCon.text,
                                          description: descCon.text);
                                  break;
                                case 7:
                                  provider.charterModel?.healthSafety =
                                      HealthSafety(
                                          title: titleCon.text,
                                          description: descCon.text);
                                  break;
                                case 8:
                                  provider.charterModel?.boardingInstructions =
                                      BoardingInstructions(
                                          title: titleCon.text,
                                          description: descCon.text);
                                  break;
                              }
                              provider.update();
                              Get.back();
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
      );
    });
  }
}
