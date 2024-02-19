// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class YachtWidget extends StatelessWidget {
  YachtsModel? yacht;
  double? width;
  double? height;
  bool isSmall;
  bool isPopUp;
  bool isShowStar;
  YachtWidget(
      {this.yacht,
      this.width,
      this.height,
      this.isSmall = false,
      this.isShowStar = true,
      this.isPopUp = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return Padding(
        padding: EdgeInsets.only(bottom: Get.height * .03),
        child: Container(
          width: width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(colors: [
                    Colors.transparent,
                    R.colors.black.withOpacity(.70),
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                      .createShader(bounds);
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  decoration: BoxDecoration(
                    color: R.colors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        yacht?.images?.first ?? R.images.serviceUrl,
                        height: height,
                        width: Get.width * .85,
                        fit: BoxFit.cover,
                      )),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isPopUp == true ? 10.w : Get.width * .04,
                      vertical: Get.height * .01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              yacht?.name ?? "",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteDull,
                                  fontSize: isSmall ? 11.sp : 15.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                            h0P7,
                            Text(
                              yacht?.location?.city ?? "",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteDull,
                                  fontSize: isSmall ? 9.sp : 13.sp),
                            )
                          ],
                        ),
                      ),
                      // Expanded(
                      //   flex: 3,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.end,
                      //     mainAxisAlignment: MainAxisAlignment.end,
                      //     children: [
                      //       Row(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         mainAxisAlignment: MainAxisAlignment.end,
                      //         children: [
                      //           Text(
                      //             "Starting: ",
                      //             style: R.textStyle.helvetica().copyWith(
                      //                 color: R.colors.whiteColor,
                      //                 fontSize: isSmall ? 7.sp : 12.sp),
                      //           ),
                      //           Expanded(
                      //             child: Text(
                      //               "\$${Helper.numberFormatter(double.parse(yacht?.price?.toStringAsFixed(0) ?? ""))}",
                      //               style: R.textStyle.helvetica().copyWith(
                      //                   color: R.colors.yellowDark,
                      //                   fontSize: isSmall ? 8.sp : 12.sp),
                      //               textAlign: TextAlign.end,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isPopUp == true ? 10.w : Get.width * .04,
                      vertical: Get.height * .01),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Starting: ",
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: isSmall ? 7.sp : 12.sp),
                                ),
                                Text(
                                  "\$${Helper.numberFormatter(double.parse(yacht?.price?.toStringAsFixed(0) ?? ""))}",
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.yellowDark,
                                      fontSize: isSmall ? 8.sp : 12.sp),
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
