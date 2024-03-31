// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/model/charter_model.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/model/user_data.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';

import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/text_size.dart';
import 'package:yacht_master_admin/utils/widgets/show_image.dart';

import '../../../../../../utils/webview_screen.dart';

class UserDialogue extends StatefulWidget {
  final UserModel model;
  const UserDialogue({Key? key, required this.model}) : super(key: key);

  @override
  State<UserDialogue> createState() => _UserDialogueState();
}

class _UserDialogueState extends State<UserDialogue> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserVM>(builder: (context, userVm, _) {
      return Scaffold(
        backgroundColor: R.colors.transparent,
        body: ResponsiveWidget(
            largeScreen: largeForgetView(userVm),
            mediumScreen: smallForgetView(userVm),
            smallScreen: smallForgetView(userVm)),
      );
    });
  }

  Widget largeForgetView(UserVM userVm) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 7.sp),
        decoration: BoxDecoration(
          color: R.colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        width: 40.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
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
            ),
            Text(
              LocalizationMap.getTranslatedValues('user_details'),
              style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(context, 25),
                fw: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${LocalizationMap.getTranslatedValues('user')}:",
                        style: R.textStyles.poppins(
                            fs: AdaptiveTextSize.getAdaptiveTextSize(
                                context, 15),
                            fw: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: DisplayImage.showImage(
                                  widget.model.imageUrl,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.model.firstName ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  widget.model.email ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  widget.model.phoneNumber ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),


            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${LocalizationMap.getTranslatedValues("documents")}:",
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            if(widget.model.hostDocumentUrl==null || widget.model.hostDocumentUrl=="")
              Text(
                "No Document uploaded by user",
                style: R.textStyles.poppins(
                  fs: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
                ),
              )else GestureDetector(
                onTap: () {
                  html.window.open(
                      widget.model.hostDocumentUrl??"",
                      "open",
                      'left=100,top=100,width=800,height=600');
                },
                child: Text(
                  "${widget.model.hostDocumentUrl}",
                  style: R.textStyles.poppins().copyWith(
                      fontSize: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
                      fontWeight: FontWeight.w500,color: Colors.indigo,decoration: TextDecoration.underline),
                )),
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget smallForgetView(UserVM userVm) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.sp, horizontal: 7.sp),
        decoration: BoxDecoration(
          color: R.colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
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
            ),
            Text(
              LocalizationMap.getTranslatedValues('feedback_details'),
              style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(context, 25),
                fw: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationMap.getTranslatedValues('created_by'),
                        style: R.textStyles.poppins(
                            fs: AdaptiveTextSize.getAdaptiveTextSize(
                                context, 15),
                            fw: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: DisplayImage.showImage(
                                  widget.model.imageUrl ?? "",
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.model.firstName ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  widget.model.email ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  widget.model.phoneNumber ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${LocalizationMap.getTranslatedValues("documents")}:",
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
           if(widget.model.hostDocumentUrl==null || widget.model.hostDocumentUrl=="")
             Text(
               "No Document uploaded by user",
               style: R.textStyles.poppins(
                 fs: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
               ),
             )else
             GestureDetector(
                onTap: () {
                  html.window.open(
                      widget.model.hostDocumentUrl??"",
                      "open",
                      'left=100,top=100,width=800,height=600');
                },
                child: Text(
                  "${widget.model.hostDocumentUrl}",
                  style: R.textStyles.poppins().copyWith(
                      fontSize: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
                      fontWeight: FontWeight.w500,color: Colors.indigo,decoration: TextDecoration.underline),
                )),
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget charterTile(CharterModel charterModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.only(top: 5, bottom: 12, right: 10),
      decoration: BoxDecoration(
        color: R.colors.textFieldFillColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 70,
                  width: 80,
                  child: DisplayImage.showImage(
                    charterModel.images?.first ?? "",
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  charterModel.name ?? "",
                  style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      color: R.colors.white),
                ),
                Text(
                  "${charterModel.priceFullDay?.toStringAsFixed(2) ?? ""}/per day",
                  style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      color: R.colors.white),
                ),
                Text(
                  charterModel.location?.adress ?? "",
                  style: R.textStyles.poppins(
                      fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                      color: R.colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
