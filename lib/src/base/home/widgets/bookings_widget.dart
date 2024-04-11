// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class BookingsWidget extends StatefulWidget {
  BookingsModel? bookings;
  int index;
  bool isBooking;
  bool? isLargeView;
  BookingsWidget(
      {this.bookings,
      this.index = -1,
      this.isBooking = false,
      this.isLargeView = false});
  @override
  _BookingsWidgetState createState() => _BookingsWidgetState();
}

class _BookingsWidgetState extends State<BookingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeVm>(builder: (context, provider, _) {
      log("____${widget.bookings?.charterFleetDetail?.id}");
      return Padding(
        padding: EdgeInsets.only(bottom: widget.isLargeView == false ? 0 : 2.h),
        child: FutureBuilder(
            future: FbCollections.charterFleet
                .doc(widget.bookings?.charterFleetDetail?.id)
                .get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return SizedBox();
              } else {
                CharterModel charterModel =
                    CharterModel.fromJson(snapshot.data);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isLargeView == false)
                      SizedBox()
                    else
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                                  colors: [
                                Colors.transparent,
                                R.colors.black.withOpacity(.40),
                                R.colors.black.withOpacity(.70)
                              ],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft)
                              .createShader(bounds);
                        },
                        blendMode: BlendMode.srcATop,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: R.colors.whiteColor),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: charterModel.images?.first ??
                                  R.images.serviceUrl,
                              height: 120.sp,
                              width: Get.width * .85,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      SpinKitPulse(
                                color: R.colors.themeMud,
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.isLargeView == false ? 0 : 7.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              if (widget.isLargeView == true)
                                SizedBox()
                              else
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: R.colors.whiteColor),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl: charterModel.images?.first ??
                                          R.images.serviceUrl,
                                      height: Get.height * .09,
                                      width: Get.width * .3,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              SpinKitPulse(
                                        color: R.colors.themeMud,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              if (widget.isLargeView == true)
                                SizedBox()
                              else
                                w4,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Start Time: ${DateFormat("dd/MM/yyyy hh:mm a").format((widget.bookings?.schedule?.dates?.first.toDate() ?? DateTime.now()))}",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontWeight: widget.isLargeView == true
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: widget.isLargeView == true
                                              ? 13.sp
                                              : 11.sp),
                                    ),
                                    h0P7,
                                    Text(
                                      "End Time: ${DateFormat("dd/MM/yyyy hh:mm a").format((widget.bookings?.schedule?.dates?.last.toDate() ?? DateTime.now()))}",
                                      style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.whiteColor,
                                            fontSize: widget.isLargeView == true
                                                ? 12.sp
                                                : 11.sp,
                                          ),
                                    ),
                                    h0P5,
                                    Text(
                                      "Guests: ${widget.bookings?.totalGuest}",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: widget.isLargeView == true
                                              ? 12.sp
                                              : 10.sp),
                                    ),
                                    if (widget.isLargeView == true)
                                      h4
                                    else
                                      h1P5,
                                    Text(
                                      "\$${Helper.numberFormatter(double.parse(widget.bookings?.priceDetaill?.totalPrice.toString().split(".").first ?? ""))}",
                                      style: R.textStyle
                                          .helveticaBold()
                                          .copyWith(
                                              color: R.colors.yellowDark,
                                              fontSize: 13.sp),
                                    ),
                                    h0P5,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        FutureBuilder(
                                            future: FbCollections.user
                                                .doc(charterModel.createdBy)
                                                .get(),
                                            builder: (context,
                                                AsyncSnapshot<DocumentSnapshot>
                                                    hostSnap) {
                                              if (!hostSnap.hasData) {
                                                return SizedBox();
                                              } else {
                                                return Text(
                                                  hostSnap.data
                                                      ?.get("first_name"),
                                                  // "${widget.bookings?.charter?.host?.firstName}",
                                                  style: R.textStyle
                                                      .helvetica()
                                                      .copyWith(
                                                          color: R.colors
                                                              .whiteColor,
                                                          fontSize: 10.sp),
                                                );
                                              }
                                            }),
                                        if (widget.bookings!.isPending!)
                                          Padding(
                                            padding:
                                                EdgeInsets.only(right: 4.w),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          7.sp),
                                                  color: R.colors.yellowDark),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    top: 0.5.h,
                                                    bottom: 0.5.h,
                                                    left: 2.2.w,
                                                    right: 2.2.w),
                                                child: Text(
                                                  "Pending",
                                                  style: R.textStyle
                                                      .helvetica()
                                                      .copyWith(
                                                          color: R.colors
                                                              .whiteColor,
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          SizedBox(),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (widget.index == provider.allBookings.length - 1 ||
                              widget.isLargeView == true)
                            SizedBox()
                          else
                            SizedBox(
                                width: Get.width * .9,
                                child: Divider(
                                  color: R.colors.grey.withOpacity(.40),
                                  thickness: 2,
                                  height: Get.height * .03,
                                ))
                        ],
                      ),
                    ),
                  ],
                );
              }
            }),
      );
    });
  }
}
