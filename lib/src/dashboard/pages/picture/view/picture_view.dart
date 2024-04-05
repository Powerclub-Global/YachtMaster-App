import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/constants/fb_collections.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/z_bot/zbot_toast.dart';
import '../../../../../resources/resources.dart';
import '../../../../../resources/validator.dart';
import '../../../../../utils/text_size.dart';
import '../../../../../utils/widgets/app_button.dart';
import '../../../../auth/vm/auth_vm.dart';
import '../../../vm/base_vm.dart';
import '../vm/picture_vm.dart';

class PictureView extends StatefulWidget {
  const PictureView({Key? key}) : super(key: key);

  @override
  PictureViewState createState() => PictureViewState();
}

class PictureViewState extends State<PictureView> {
  final _settingsFormKey = GlobalKey<FormState>();

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  final FocusNode oldPFocus = FocusNode();
  final FocusNode newPFocus = FocusNode();
  bool passObscure = true;
  bool confirmPassObscure = true;

  @override
  Widget build(BuildContext context) {
    return Consumer3<PictureVM, BaseVm, AuthVM>(
        builder: (context, settingsVm, baseVm, authVm, _) {
      return Scaffold(
        backgroundColor: R.colors.dividerColor,
        body: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _settingsFormKey,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: EdgeInsets.symmetric(
                vertical: ResponsiveWidget.isLargeScreen(context) ? 32 : 20,
                horizontal: ResponsiveWidget.isLargeScreen(context) ? 35 : 23),
            decoration: BoxDecoration(
                color: R.colors.primary,
                borderRadius: BorderRadius.circular(12)),
            child: changePicture(settingsVm),
          ),
        ),
      );
    });
  }

  Widget changePicture(PictureVM vm) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveWidget.isLargeScreen(context) ? 20 : 10),
        Text(
          LocalizationMap.getTranslatedValues('ch_pic'),
          style: R.textStyles.poppins(
            fs: AdaptiveTextSize.getAdaptiveTextSize(
                context, ResponsiveWidget.isLargeScreen(context) ? 26 : 18),
            fw: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveWidget.isLargeScreen(context) ? 20 : 10),
        SizedBox(height: ResponsiveWidget.isLargeScreen(context) ? 40 : 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: Get.height * 0.1,
              width: Get.width,
              child: AppButton(
                textColor: R.colors.white,
                buttonTitle: 'up_save',
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: [
                      'jpg',
                      'jpeg',
                      'png',
                      'gif',
                    ],
                  );
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    Reference img = FirebaseStorage.instance
                        .ref('homeMedia')
                        .child(file.name);
                    //img.putData(file.bytes!);
                    ZBotToast.loadingShow();
                    await img.putData(file.bytes!);
                    await img.getDownloadURL().then((value) async {
                      await FBCollections.settings
                          .doc('global')
                          .update({'resURL': value});
                    });
                    ZBotToast.loadingClose();
                    print("done");
                  } else {
                    // User canceled the picker
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
