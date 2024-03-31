// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master_admin/resources/localization/localization_map.dart';
import 'package:yacht_master_admin/resources/resources.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/model/bookings_model.dart';
import 'package:yacht_master_admin/src/dashboard/pages/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/model/charter_model.dart';
import 'package:yacht_master_admin/src/dashboard/pages/users/view_model/user_vm.dart';

import 'package:yacht_master_admin/utils/responsive_widget.dart';
import 'package:yacht_master_admin/utils/text_size.dart';
import 'package:yacht_master_admin/utils/widgets/show_image.dart';

import '../../../../../../constants/enums.dart';

class PaymentDialogue extends StatefulWidget {
  final BookingsModel model;
  const PaymentDialogue({Key? key, required this.model}) : super(key: key);

  @override
  State<PaymentDialogue> createState() => _PaymentDialogueState();
}

class _PaymentDialogueState extends State<PaymentDialogue> {
  ScrollController scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return Consumer2<UserVM, BookingsVm>(builder: (context, userVm, vm, _) {
      return Scaffold(
        backgroundColor: R.colors.transparent,
        body: ResponsiveWidget(
            largeScreen: largeForgetView(userVm, vm),
            mediumScreen: smallForgetView(userVm, vm),
            smallScreen: smallForgetView(userVm, vm)),
      );
    });
  }

  Widget largeForgetView(UserVM userVm, BookingsVm vm) {
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
              LocalizationMap.getTranslatedValues('payment_details'),
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
                        LocalizationMap.getTranslatedValues('charter_detail'),
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
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: DisplayImage.showImage(
                                  widget.model.charterFleetDetail?.image ?? "",
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.model.charterFleetDetail?.name ?? "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  getStartingFromText(),
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  widget.model.charterFleetDetail?.location ??
                                      "",
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocalizationMap.getTranslatedValues('created_by'),
                        style: R.textStyles.poppins(
                            fs: AdaptiveTextSize.getAdaptiveTextSize(
                                context, 15),
                            fw: FontWeight.w500),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 17, horizontal: 8),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child: DisplayImage.showImage(
                                  userVm.userList
                                          .firstWhereOrNull((element) =>
                                              element.uid ==
                                              widget.model.hostUserUid)
                                          ?.firstName ??
                                      "",
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userVm.userList
                                          .firstWhereOrNull((element) =>
                                              element.uid ==
                                              widget.model.hostUserUid)
                                          ?.firstName ??
                                      "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  userVm.userList
                                          .firstWhereOrNull((element) =>
                                              element.uid ==
                                              widget.model.hostUserUid)
                                          ?.email ??
                                      "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  userVm.userList
                                          .firstWhereOrNull((element) =>
                                              element.uid ==
                                              widget.model.hostUserUid)
                                          ?.phoneNumber ??
                                      "",
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

            SizedBox(
              height: 1.h,
            ),
            paymentTile(widget.model,userVm,vm),
            SizedBox(
              height: 1.h,
            ),
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget smallForgetView(UserVM userVm, BookingsVm vm) {
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
              LocalizationMap.getTranslatedValues('payment_details'),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocalizationMap.getTranslatedValues('created_by'),
                        style: R.textStyles.poppins(
                            fs: AdaptiveTextSize.getAdaptiveTextSize(
                                context, 15),
                            fw: FontWeight.w500),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 17, horizontal: 8),
                            alignment: Alignment.center,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child: DisplayImage.showImage(
                                  userVm.userList
                                      .firstWhereOrNull((element) =>
                                  element.uid ==
                                      widget.model.hostUserUid)
                                      ?.firstName ??
                                      "",
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userVm.userList
                                      .firstWhereOrNull((element) =>
                                  element.uid ==
                                      widget.model.hostUserUid)
                                      ?.firstName ??
                                      "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  userVm.userList
                                      .firstWhereOrNull((element) =>
                                  element.uid ==
                                      widget.model.hostUserUid)
                                      ?.email ??
                                      "",
                                  style: R.textStyles.poppins(
                                    fs: AdaptiveTextSize.getAdaptiveTextSize(
                                        context, 12),
                                  ),
                                ),
                                Text(
                                  userVm.userList
                                      .firstWhereOrNull((element) =>
                                  element.uid ==
                                      widget.model.hostUserUid)
                                      ?.phoneNumber ??
                                      "",
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
                LocalizationMap.getTranslatedValues("schedule"),
                style: R.textStyles.poppins(
                    fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                    fw: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            paymentTile(widget.model,userVm,vm),
            SizedBox(
              height: 1.h,
            ),
            SizedBox(
              height: 1.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentTile(BookingsModel bookingsModel,UserVM vm,BookingsVm bookingsVm) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.only(top: 5, bottom: 12, right: 10),
      decoration: BoxDecoration(
        color: R.colors.textFieldFillColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bookingsModel.paymentDetail?.isSplit == false &&
              bookingsModel
                  .paymentDetail?.splitPayment?.isEmpty ==
                  true)
           const SizedBox()
          else  ...[
            Text(
            (bookingsModel.paymentDetail?.splitPayment
                ?.length ??
                0) >
                1
                ? "Split Details (${bookingsModel.paymentDetail?.splitPayment?.length})"
                : "Split Details",
            style: R.textStyles.poppins(
                fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                color: R.colors.white),
          ),
            Divider(
              color: R.colors.greyColor,
            ),
            Column(
              children: List.generate(
                  bookingsModel.paymentDetail
                      ?.splitPayment?.length ??
                      0, (index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              index == 0
                                  ? "Person ${index + 1} (default)"
                                  : "Person ${index + 1}",
                              style: R.textStyles.poppins(
                                  fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                                  color: R.colors.white),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(
                              "${vm.userList.firstWhereOrNull((element) => element.uid==bookingsModel.paymentDetail?.splitPayment?[index].userUid)?.email}",
                              style: R.textStyles.poppins(
                                  fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                                  color: R.colors.white),
                              overflow:
                              TextOverflow
                                  .ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          "${bookingsModel.paymentDetail?.splitPayment?[index].percentage}%",
                          style: R.textStyles.poppins(
                              fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                              color: R.colors.white),
                        ),
                        Text(
                          ((bookingsModel.paymentDetail?.payInType ==
                              PayType
                                  .deposit
                                  .index &&
                              bookingsModel.paymentDetail?.splitPayment?[index].depositStatus ==
                                  DepositStatus
                                      .nothingPaid
                                      .index) ||
                              bookingsModel.paymentDetail
                                  ?.payInType ==
                                  PayType
                                      .fullPay
                                      .index &&
                                  bookingsModel.paymentDetail?.splitPayment?[index].remainingAmount.toStringAsFixed(1) != "0.0"
                              // && bookingsModel?.bookingStatus==BookingStatus.canceled.index
                          )
                              ? "-"
                              : bookingsModel.paymentDetail?.payInType ==
                              PayType
                                  .deposit
                                  .index &&
                              bookingsModel
                                  .paymentDetail
                                  ?.splitPayment?[index]
                                  .depositStatus ==
                                  DepositStatus.twentyFivePaid.index
                              ? "\$${NumberFormat("##,###.##", "en_US").format(double.parse(bookingsModel.paymentDetail?.splitPayment?[index].remainingAmount.toStringAsFixed(1)))}"
                              : "\$${NumberFormat("##,###.##", "en_US").format(double.parse(bookingsModel.paymentDetail?.splitPayment?[index].amount.toStringAsFixed(1)))}",
                          style: R.textStyles.poppins(
                              fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                              color: R.colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    if (index ==
                        (bookingsModel.paymentDetail
                            ?.splitPayment
                            ?.length ??
                            0) -
                            1)
                      SizedBox()
                    else
                      Divider(
                        color: R.colors.greyColor,
                        height: 3.h,
                      )
                  ],
                );
              }),
            ),
            Divider(
              color: R.colors.greyColor,
            ),
          ],
          Row(
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${LocalizationMap.getTranslatedValues("sub_total")}:",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    if (widget.model.durationType ==
                        CharterDayType.multiDay.index &&
                       widget.model.schedule?.dates?.isNotEmpty ==
                            true)
                      Text(
                      "${LocalizationMap.getTranslatedValues("days")}:",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    Text(
                      "${LocalizationMap.getTranslatedValues("service_fee")}:",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    Text(
                      "${LocalizationMap.getTranslatedValues("taxes")}:",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),

                    Text(
                      "${LocalizationMap.getTranslatedValues("tip")}:",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    Divider(
                      color: R.colors.greyColor,
                    ),
                    Text(
                      "${LocalizationMap.getTranslatedValues("total")}:",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    
                    Text(
                      "\$${widget.model.priceDetaill?.subTotal}",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    if (widget.model.durationType ==
                        CharterDayType.multiDay.index &&
                        widget.model.schedule?.dates?.isNotEmpty ==
                            true)
                      Text(
                        "${widget.model.schedule?.dates?.length}",
                        style: R.textStyles.poppins(
                            fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                            color: R.colors.white),
                      ),
                    Text(
                      "${widget.model.priceDetaill?.serviceFee}",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    Text(
                      "${widget.model.priceDetaill?.taxes}",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),

                    Text(
                      "${widget.model.priceDetaill?.tip}",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                    Divider(
                      color: R.colors.greyColor,
                    ),
                    Text(
                      "${widget.model.priceDetaill?.totalPrice}",
                      style: R.textStyles.poppins(
                          fs: AdaptiveTextSize.getAdaptiveTextSize(context, 15),
                          color: R.colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getStartingFromText(){
    CharterModel? charter = context.read<UserVM>().allCharters.firstWhereOrNull((element) => element.id == widget.model.charterFleetDetail?.id);
    String text = '';
    if((charter?.priceFourHours ?? 0) != 0){
      text = "\$${charter?.priceFourHours?.toStringAsFixed(2)}/4 hours";
    }else if((charter?.priceHalfDay ?? 0) != 0){
      text = "\$${charter?.priceHalfDay?.toStringAsFixed(2)}/8 hours";
    }else if((charter?.priceFullDay ?? 0) != 0){
      text = "\$${charter?.priceFullDay?.toStringAsFixed(2)}/24 hours";
    }
    return text;
  }
}
