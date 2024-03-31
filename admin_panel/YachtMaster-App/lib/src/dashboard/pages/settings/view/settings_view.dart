import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../../../resources/resources.dart';
import '../../../../../resources/validator.dart';
import '../../../../../utils/text_size.dart';
import '../../../../../utils/widgets/app_button.dart';
import '../../../../auth/vm/auth_vm.dart';
import '../../../vm/base_vm.dart';
import '../vm/settings_vm.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final _settingsFormKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  final FocusNode oldPFocus = FocusNode();
  final FocusNode newPFocus = FocusNode();
  bool passObscure = true;
  bool confirmPassObscure = true;

  @override
  Widget build(BuildContext context) {
    return Consumer3<SettingsVM, BaseVm, AuthVM>(
        builder: (context, settingsVm, baseVm, authVm, _) {
      return Scaffold(
        backgroundColor: R.colors.dividerColor,
        body: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _settingsFormKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(vertical: ResponsiveWidget.isLargeScreen(context)?32:20, horizontal: ResponsiveWidget.isLargeScreen(context)?35:23),
            decoration: BoxDecoration(
                color: R.colors.primary, borderRadius: BorderRadius.circular(12)),
            child: changePassword(settingsVm),
          ),
        ),
      );
    });
  }

  Widget changePassword(SettingsVM vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveWidget.isLargeScreen(context)?20:10),
        Text(
          LocalizationMap.getTranslatedValues('change_password'),
          style: R.textStyles.poppins(
            fs: AdaptiveTextSize.getAdaptiveTextSize(context, ResponsiveWidget.isLargeScreen(context)?26:18),
            fw: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveWidget.isLargeScreen(context)?20:10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:
                        EdgeInsets.only(left: 2.sp, bottom: 1.sp, top: 5.sp),
                    child: Text(
                      LocalizationMap.getTranslatedValues('old_password'),
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          fw: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    style: R.textStyles.poppins(),
                    obscureText: passObscure,
                    focusNode: oldPFocus,
                    validator: FieldValidator.validateOldPassword,
                    onTap: () {
                      setState(() {});
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: oldPasswordController,
                    decoration: R.decoration.fieldDecoration(
                      hintText: 'password_hint',
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              passObscure = !passObscure;
                            });
                          },
                          child: Icon(
                            passObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: R.colors.hintIconColor,
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding:
                        EdgeInsets.only(left: 2.sp, bottom: 1.sp, top: 5.sp),
                    child: Text(
                      LocalizationMap.getTranslatedValues('new_password'),
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          fw: FontWeight.w500),
                    ),
                  ),
                  TextFormField(
                    style: R.textStyles.poppins(),
                    obscureText: confirmPassObscure,
                    focusNode: newPFocus,
                    validator: FieldValidator.validateNewPassword,
                    onTap: () {
                      setState(() {});
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: newPasswordController,
                    decoration: R.decoration.fieldDecoration(
                      hintText: 'password_hint',
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              confirmPassObscure= !confirmPassObscure;
                            });
                          },
                          child: Icon(
                            confirmPassObscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: R.colors.hintIconColor,
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveWidget.isLargeScreen(context)?40:20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: Get.width*.1,
              child: AppButton(
                textColor: R.colors.white,
                buttonTitle: 'save',
                onTap: () async {
                  if (_settingsFormKey.currentState!.validate()) {
                    if (oldPasswordController.text ==
                        newPasswordController.text) {
                      ZBotToast.showToastError(
                          message: LocalizationMap.getTranslatedValues(
                              "new_password_and_old_password_cannot_be_same"));
                    } else {
                      ZBotToast.loadingShow();
                      await vm
                          .changePassword(oldPasswordController.text.trim(),
                              newPasswordController.text.trim())
                          .then((value) {
                        setState(() {
                          oldPasswordController.clear();
                          newPasswordController.clear();
                        });
                      });
                      ZBotToast.loadingClose();

                    }
                  }
                },
              ),
            )
          ],
        ),
      ],
    );
  }
}
