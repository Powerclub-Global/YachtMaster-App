// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';

import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/text_size.dart';
import 'package:yacht_master_admin/utils/widgets/show_image.dart';

import '../../model/reports_data.dart';

class FeedBackDetailDialogue extends StatefulWidget {
  final AppFeedbackModel model;
  const FeedBackDetailDialogue({Key? key, required this.model}) : super(key: key);

  @override
  State<FeedBackDetailDialogue> createState() => _FeedBackDetailDialogueState();
}

class _FeedBackDetailDialogueState extends State<FeedBackDetailDialogue> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.transparent,
      body: ResponsiveWidget(
          largeScreen: largeForgetView(), mediumScreen: smallForgetView(), smallScreen: smallForgetView()),
    );
  }

  Widget largeForgetView() {
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
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: R.colors.offWhite)),
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
                        style: R.textStyles
                            .poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15), fw: FontWeight.w500),
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
                                  widget.model.pricture ,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.model.userName ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
                                  ),
                                ),
                                Text(
                                  widget.model.phoneNumber ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
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
                LocalizationMap.getTranslatedValues("description"),
                style: R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15), fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child:  RatingBar.builder(
                ignoreGestures: false,
                initialRating: widget.model.rating??4.5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 25,
                glowColor: R.colors.yellowDark.withOpacity(.50),
                unratedColor: R.colors.unratedStar,
                itemBuilder: (context, _) =>  Padding(
                  padding:  EdgeInsets.only(right: 50),
                  child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                            colors:
                            [R.colors.gradMud,R.colors.gradMudLight]
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Image.asset(R.images.star,)),
                ),
                onRatingUpdate: (selectedRating) {
                },
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.model.feedback ?? "",
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 18),
                    fw: FontWeight.w300,
                    color: R.colors.greyHintColor),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),


          ],
        ),
      ),
    );
  }

  Widget smallForgetView() {
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
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, border: Border.all(width: 1, color: R.colors.offWhite)),
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
                        style: R.textStyles
                            .poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15), fw: FontWeight.w500),
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
                                  widget.model.pricture ?? "",
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.model.userName?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
                                  ),
                                ),
                            Text(
                              widget.model.phoneNumber ?? "",
                              style: R.textStyles.poppins(
                                fs: AdaptiveTextSize.getAdaptiveTextSize(context, 12),
                              ),)
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
                LocalizationMap.getTranslatedValues("description"),
                style: R.textStyles.poppins(fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15), fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child:  RatingBar.builder(
                ignoreGestures: false,
                initialRating: widget.model.rating??4.5,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 25,
                glowColor: R.colors.yellowDark.withOpacity(.50),
                unratedColor: R.colors.unratedStar,
                itemBuilder: (context, _) =>  Padding(
                  padding:  EdgeInsets.only(right: 50),
                  child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                            colors:
                            [R.colors.gradMud,R.colors.gradMudLight]
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Image.asset(R.images.star,)),
                ),
                onRatingUpdate: (selectedRating) {
                },
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.model.feedback ?? "",
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 18),
                    fw: FontWeight.w300,
                    color: R.colors.greyHintColor),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),


          ],
        ),
      ),
    );
  }



}
