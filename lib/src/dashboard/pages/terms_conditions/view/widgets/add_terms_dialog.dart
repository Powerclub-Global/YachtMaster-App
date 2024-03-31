// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/src/dashboard/pages/settings/vm/settings_vm.dart';
import 'package:yacht_master_admin/utils/heights_widths.dart';
import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/widgets/app_button.dart';
import '../../../../../../constants/enums.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../utils/text_size.dart';

class AddTermsDialog extends StatefulWidget {
  final String text;
  final String label;
  final String docId;
  final AppContentType contentType;

  const AddTermsDialog({
    Key? key,
    required this.text,
    required this.label,
    required this.docId,
    required this.contentType,
  }) : super(key: key);

  @override
  State<AddTermsDialog> createState() => _AddTermsDialogState();
}

class _AddTermsDialogState extends State<AddTermsDialog> {
  final QuillEditorController quillController = QuillEditorController();
  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsVM>(builder: (context,settingsVM,_){
      return Scaffold(
        backgroundColor: R.colors.transparent,
        body: Center(
          child: Container(
            margin: EdgeInsets.all(ResponsiveWidget.isLargeScreen(context)?20:10),
            padding: EdgeInsets.symmetric(vertical: ResponsiveWidget.isLargeScreen(context)?4.sp:10.sp, horizontal: 7.sp),
            decoration: BoxDecoration(
              color: R.colors.primary,
              borderRadius: BorderRadius.circular(25),
            ),
            width: ResponsiveWidget.isLargeScreen(context)?60.w:80.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocalizationMap.getTranslatedValues(widget.label),
                        style: R.textStyles.poppins(
                            fs: AdaptiveTextSize.getAdaptiveTextSize(context, ResponsiveWidget.isLargeScreen(context)?28:22),
                            fw: FontWeight.w600),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 1, color: R.colors.offWhite)),
                          child: Icon(
                            Icons.clear,
                            size: 15,
                            color: R.colors.offWhite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  h3,
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: R.colors.videoBorderColor,
                        )),
                    child: Column(
                      children: [
                        ToolBar(controller: quillController,toolBarColor: R.colors.transparent,activeIconColor: R.colors.secondary,iconColor: R.colors.offWhite),
                        RawScrollbar(
                          thickness: 2,
                          thumbColor: R.colors.secondary,
                          radius: const Radius.circular(5),
                          thumbVisibility: false,
                          controller: scrollController,
                          scrollbarOrientation: ScrollbarOrientation.right,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: QuillHtmlEditor(
                              controller: quillController,
                              minHeight: 35.h,
                              text: widget.text,
                              hintTextStyle: R.textStyles.poppins(
                                color: R.colors.greyHintColor,
                                fs: AdaptiveTextSize.getAdaptiveTextSize(Get.context!, 15),
                                fw: FontWeight.w300,
                              ),
                              hintText: "Start Typing",
                              backgroundColor: R.colors.transparent,
                              textStyle: TextStyle(color: R.colors.offWhite),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  h3,
                  SizedBox(
                    width: Get.width*.2,
                    child: AppButton(
                      textColor: R.colors.white,
                      buttonTitle: 'save',
                      onTap: () async {
                        String htmlText = await quillController.getText();
                        settingsVM.allContent.firstWhereOrNull((element) => element.type==widget.contentType.index)?.content= htmlText;
                        await settingsVM.updateContent(widget.docId, htmlText);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

  }
}
