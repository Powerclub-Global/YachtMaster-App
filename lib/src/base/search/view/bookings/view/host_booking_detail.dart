// ignore_for_file: use_build_context_synchronously


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/widgets/payment_sheet.dart';
import 'package:yacht_master/src/base/widgets/exit_sheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'dart:developer' as msg;

import '../../../../../../services/notification_service.dart';
import '../../../../inbox/model/notification_model.dart';

class HostBookingDetail extends StatefulWidget {
  static String route = "/hostBookingDetail";

  const HostBookingDetail({Key? key}) : super(key: key);

  @override
  _HostBookingDetailState createState() => _HostBookingDetailState();
}

class _HostBookingDetailState extends State<HostBookingDetail> {
  BookingsModel? bookingsModel;
  double remaimingAmount = 0.0;
  UserModel? rentalUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      bookingsModel = args["bookingsModel"];
      if(bookingsModel!=null)
        {
          rentalUser=context.read<BaseVm>().allUsers.firstWhereOrNull((element) => element.uid==bookingsModel?.createdBy);
        }
      if (bookingsModel?.paymentDetail?.isSplit == true) {
        bookingsModel?.paymentDetail?.splitPayment?.forEach((element) {
          if (element.depositStatus == 0) {
            ///0 means paid 1 means half paid
            remaimingAmount = remaimingAmount + (element.remainingAmount ?? 0);
          }
        });
      }
      if (bookingsModel?.paymentDetail?.payInType == PayType.deposit.index) {
        double remainingDepositAmount =
            (bookingsModel?.priceDetaill?.totalPrice ?? 0) -
                ((bookingsModel?.priceDetaill?.totalPrice ?? 0) * (25 / 100));
        remaimingAmount = remaimingAmount + remainingDepositAmount;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BaseVm,BookingsVm>(builder: (context, baseVm,provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        appBar:GeneralAppBar.simpleAppBar(
            context, getTranslated(context, "booking_details") ?? ""),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
            child: Column(
              children: [
                h1,
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: R.colors.whiteColor
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: bookingsModel?.charterFleetDetail?.image ??
                              R.images.serviceUrl,
                          height: Get.height * .09,
                          width: Get.width * .3,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  SpinKitPulse(color: R.colors.themeMud,),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                    w4,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingsModel?.charterFleetDetail?.name ?? "",
                          style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.whiteColor,
                              fontSize: 15.sp),
                        ),
                        h0P5,
                       Text(
                           baseVm.allUsers.firstWhereOrNull((element) => element.uid==bookingsModel?.hostUserUid)?.firstName??"",
                                  style: R.textStyle
                                      .helvetica()
                                      .copyWith(
                                      color: R.colors.whiteDull,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                        h0P5,
                        SizedBox(width: Get.width*.5,
                          child: Text(
                            bookingsModel?.charterFleetDetail?.location ?? "",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteDull,
                                fontSize: 11.sp),maxLines: 2,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                h3,
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .03,
                      vertical: Get.height * .02),
                  child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Renter Details",
                                style: R.textStyle
                                    .helveticaBold()
                                    .copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 14.sp),
                              ),
                              h1P5,
                              Text(
                                "${rentalUser?.firstName}",
                                style: R.textStyle
                                    .helveticaBold()
                                    .copyWith(
                                    color: R.colors.whiteDull,
                                    fontSize: 12.sp),
                              ),
                              h1P5,
                              Text(
                                "${rentalUser?.email}",
                                style: R.textStyle
                                    .helveticaBold()
                                    .copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 11.sp),
                              ),
                              h1P5,
                              Text(
                                "${rentalUser?.dialCode}${rentalUser?.number}",
                                style: R.textStyle
                                    .helveticaBold()
                                    .copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 11.sp),
                              ),
                            ],
                          ),
                ),
                h2,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .03,
                      vertical: Get.height * .02),
                  child: Column(
                    children: [
                      tiles(
                        "start_date_time", DateFormat("dd/MM/yyyy hh:mm a").format((bookingsModel?.schedule?.dates?.first.toDate() ?? DateTime.now())),
                      ),
                      tiles("end_date_time",
                          DateFormat("dd/MM/yyyy hh:mm a").format((bookingsModel?.schedule?.dates?.last.toDate() ?? DateTime.now()))),
                      tiles("guests", "${bookingsModel?.totalGuest}",
                          isDivider: false),
                    ],
                  ),
                ),
                h2,
                Container(
                  decoration: BoxDecoration(
                      color: R.colors.blackDull,
                      borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * .05,
                      vertical: Get.height * .02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      h0P5,
                      Text(
                        "Pay in",
                        style: R.textStyle.helveticaBold().copyWith(
                            color: R.colors.whiteColor,
                            fontSize: 14.sp),
                      ),
                      h2P5,
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: R.colors.whiteColor),
                                    shape: BoxShape.circle,
                                    color: Colors.transparent),
                                padding: EdgeInsets.all(2),
                                child: Container(
                                  height: 11.sp,
                                  width: 11.sp,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: R.colors.whiteColor),
                                ),
                              ),
                              w2,
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        bookingsModel?.paymentDetail
                                            ?.payInType ==
                                            PayType.fullPay.index
                                            ? "Fully Pay"
                                            : "25% Deposit",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                            color:
                                            R.colors.whiteColor,
                                            fontSize: 10.sp,
                                            height: 1.5),
                                      ),
                                      Text(
                                        " with ",
                                        style: R.textStyle
                                            .helvetica()
                                            .copyWith(
                                            color:
                                            R.colors.whiteColor,
                                            fontSize: 10.sp,
                                            height: 1.5),
                                      ),
                                      Text(
                                        bookingsModel?.paymentDetail
                                            ?.paymentMethod ==
                                            PaymentMethodEnum.card.index
                                            ? "Credit Card"
                                            : bookingsModel
                                            ?.paymentDetail
                                            ?.paymentMethod ==
                                            PaymentMethodEnum
                                                .appStore.index
                                            ? "Apple Pay"
                                            : "Crypto Currency",
                                        style: R.textStyle
                                            .helvetica()
                                            .copyWith(
                                            color:
                                            R.colors.whiteColor,
                                            fontSize: 10.sp,
                                            height: 1.5),
                                      ),
                                    ],
                                  ),
                                  h0P7,
                                  if (bookingsModel?.paymentDetail
                                      ?.paymentMethod !=
                                      PaymentMethodEnum.card.index)
                                    SizedBox()
                                  else
                                    Text(
                                      "${(bookingsModel
                                          ?.paymentDetail
                                          ?.currentUserCardNum ??
                                          "").obsecureCardNum()}",
                                      style: R.textStyle
                                          .helveticaBold()
                                          .copyWith(
                                          color:
                                          R.colors.whiteColor,
                                          fontSize: 12.sp),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            // isDeposit==true?
                            // "\$${splitAmount*(25/100)}":
                            bookingsModel?.paymentDetail?.isSplit ==
                                true &&
                                bookingsModel
                                    ?.paymentDetail
                                    ?.splitPayment
                                    ?.isNotEmpty ==
                                    true
                                ? "\$${ double.parse(removeSign(bookingsModel?.paymentDetail?.splitPayment?.first.amount))}" :
                            bookingsModel?.paymentDetail?.paidAmount!=null?
                            "\$${double.parse(removeSign(bookingsModel?.paymentDetail?.paidAmount))}":
                            "",
                            style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.yellowDark,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                h2,
                if (bookingsModel?.paymentDetail?.isSplit == false &&
                    bookingsModel
                        ?.paymentDetail?.splitPayment?.isEmpty ==
                        true)
                  SizedBox()
                else
                  Container(
                    decoration: BoxDecoration(
                        color: R.colors.blackDull,
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(
                        horizontal: Get.width * .05,
                        vertical: Get.height * .02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        h0P5,
                        Text(
                          (bookingsModel?.paymentDetail?.splitPayment
                              ?.length ??
                              0) >
                              1
                              ? "Split Details (${bookingsModel?.paymentDetail?.splitPayment?.length})"
                              : "Split Details",
                          style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.whiteColor,
                              fontSize: 14.sp),
                        ),
                        h2P5,
                        Column(
                          children: List.generate(
                              bookingsModel?.paymentDetail?.splitPayment
                                  ?.length ??
                                  0, (index) {
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: (bookingsModel?.paymentDetail
                                          ?.payInType ==
                                          PayType.fullPay
                                              .index &&
                                          (bookingsModel
                                              ?.paymentDetail
                                              ?.splitPayment?[
                                          index]
                                              .paymentStatus ??
                                              0) >=
                                              0) ||
                                          (bookingsModel
                                              ?.paymentDetail
                                              ?.payInType ==
                                              PayType.deposit
                                                  .index &&
                                              (bookingsModel
                                                  ?.paymentDetail
                                                  ?.splitPayment?[
                                              index]
                                                  .paymentStatus ??
                                                  0) >=
                                                  0 &&
                                              (bookingsModel
                                                  ?.paymentDetail
                                                  ?.splitPayment?[
                                              index]
                                                  .depositStatus ??
                                                  0) >=
                                                  2)
                                          ? 10
                                          : 8,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            index == 0
                                                ? "Person ${index + 1} (default)"
                                                : "Person ${index + 1}",
                                            style: R.textStyle
                                                .helveticaBold()
                                                .copyWith(
                                                color: R.colors
                                                    .whiteDull,
                                                fontSize: 12.sp),
                                          ),
                                          h0P5,
                                          FutureBuilder(
                                              future: FbCollections.user
                                                  .doc(bookingsModel
                                                  ?.paymentDetail
                                                  ?.splitPayment?[
                                              index]
                                                  .userUid)
                                                  .get(),
                                              builder: (context,
                                                  AsyncSnapshot<
                                                      DocumentSnapshot>
                                                  splitUserSnapshot) {
                                                if (!splitUserSnapshot
                                                    .hasData) {
                                                  return SizedBox();
                                                } else {
                                                  return Text(
                                                    "${splitUserSnapshot.data?.get("email")}",
                                                    style: R.textStyle
                                                        .helveticaBold()
                                                        .copyWith(
                                                        color: R
                                                            .colors
                                                            .whiteColor,
                                                        fontSize:
                                                        10.sp),
                                                    overflow:
                                                    TextOverflow
                                                        .ellipsis,
                                                  );
                                                }
                                              }),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        "${bookingsModel?.paymentDetail?.splitPayment?[index].percentage}%",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                          color:
                                          R.colors.whiteColor,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        (removeSign(bookingsModel?.paymentDetail?.splitPayment?[index].remainingAmount) != "0.0" && bookingsModel?.bookingStatus==BookingStatus.canceled.index) ||
                                            (bookingsModel
                                                ?.paymentDetail
                                                ?.splitPayment?[
                                            index]
                                                .depositStatus ==
                                                DepositStatus
                                                    .nothingPaid
                                                    .index &&
                                                bookingsModel
                                                    ?.paymentDetail
                                                    ?.payInType ==
                                                    PayType
                                                        .deposit.index)
                                            ? "-"
                                            : bookingsModel
                                            ?.paymentDetail
                                            ?.splitPayment?[
                                        index]
                                            .depositStatus ==
                                            DepositStatus
                                                .twentyFivePaid
                                                .index &&
                                            bookingsModel
                                                ?.paymentDetail
                                                ?.payInType ==
                                                PayType.deposit
                                                    .index
                                            ? "\$${double.parse(removeSign( bookingsModel?.paymentDetail?.splitPayment?[index].remainingAmount))}"
                                            : "\$${double.parse(removeSign( bookingsModel?.paymentDetail?.splitPayment?[index].amount))}",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                          color:
                                          R.colors.yellowDark,
                                          fontSize: 12.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    if(bookingsModel?.bookingStatus==BookingStatus.completed.index)SizedBox()else  if (
                                    (bookingsModel?.bookingStatus!=BookingStatus.canceled.index) && (bookingsModel?.paymentDetail
                                        ?.payInType ==
                                        PayType.fullPay.index &&
                                        (bookingsModel
                                            ?.paymentDetail
                                            ?.splitPayment?[
                                        index]
                                            .paymentStatus ??
                                            0) >=
                                            0) ||
                                        (bookingsModel?.paymentDetail
                                            ?.payInType ==
                                            PayType.deposit.index &&
                                            (bookingsModel
                                                ?.paymentDetail
                                                ?.splitPayment?[
                                            index]
                                                .paymentStatus ??
                                                0) >=
                                                0 &&
                                            (bookingsModel
                                                ?.paymentDetail
                                                ?.splitPayment?[
                                            index]
                                                .depositStatus ??
                                                0) >=
                                                2))
                                      Expanded(
                                        flex: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (bookingsModel
                                                ?.paymentDetail
                                                ?.splitPayment?[
                                            index]
                                                .paymentType ==
                                                -1) {
                                              Helper.inSnackBar(
                                                  "Error",
                                                  "Renter did not pay yet",
                                                  R.colors.themeMud);
                                            } else if ((bookingsModel
                                                ?.paymentDetail
                                                ?.splitPayment?[
                                            index]
                                                .paymentStatus ??
                                                0) <
                                                2) {
                                              Get.bottomSheet(
                                                  ReceivePaymentSheet(
                                                    title: "Receive Money",
                                                    subTitle:
                                                    "Click the button below to mark the payment received.",
                                                    yesCallBack: () async {

                                                      bookingsModel?.paymentDetail?.splitPayment?[index].paymentStatus = PaymentStatus.markAsComplete.index;
                                                      bookingsModel?.paymentDetail?.splitPayment?[index].remainingAmount = 0.0;
                                                      if (bookingsModel
                                                          ?.paymentDetail
                                                          ?.splitPayment
                                                          ?.every((element) =>
                                                      element.paymentType ==
                                                          1 &&
                                                          element.paymentStatus ==
                                                              PaymentStatus
                                                                  .markAsComplete
                                                                  .index &&
                                                          removeSign(element.remainingAmount) ==
                                                              "0.0") ==
                                                          true) {
                                                        bookingsModel
                                                            ?.paymentDetail
                                                            ?.paymentStatus =
                                                            PaymentStatus
                                                                .markAsComplete
                                                                .index;
                                                        bookingsModel
                                                            ?.paymentDetail
                                                            ?.remainingAmount = 0.0;
                                                        bookingsModel
                                                            ?.paymentDetail
                                                            ?.paymentType =
                                                            PaymentType
                                                                .payInApp
                                                                .index;
                                                      }
                                                      setState(() {});
                                                      try {
                                                        await FbCollections
                                                            .bookings
                                                            .doc(
                                                            bookingsModel
                                                                ?.id)
                                                            .set(bookingsModel
                                                            ?.toJson());
                                                      } on Exception catch (e) {
                                                        // TODO
                                                        debugPrintStack();
                                                        msg.log(
                                                            e.toString());
                                                      }
                                                      Get.back();
                                                    },
                                                    buttonName: bookingsModel
                                                        ?.paymentDetail
                                                        ?.splitPayment?[
                                                    index]
                                                        .paymentType ==
                                                        -1
                                                        ? "Pending"
                                                        : bookingsModel
                                                        ?.paymentDetail
                                                        ?.splitPayment?[
                                                    index]
                                                        .paymentType ==
                                                        PaymentType
                                                            .payCash
                                                            .index
                                                        ? "CASH RECEIVED"
                                                        : "RECEIVE IN APP",
                                                  ));
                                            }
                                          },
                                          child: Container(
                                            height: 16.sp,
                                            margin: EdgeInsets.only(
                                                left: 2.w),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: R.colors
                                                        .whiteColor),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(5),
                                                color:
                                                Colors.transparent),
                                            child: Icon(
                                              Icons.check,
                                              color: bookingsModel
                                                  ?.paymentDetail
                                                  ?.splitPayment?[
                                              index]
                                                  .paymentStatus ==
                                                  PaymentStatus
                                                      .markAsComplete
                                                      .index &&
                                                  bookingsModel
                                                      ?.paymentDetail
                                                      ?.splitPayment?[
                                                  index]
                                                      .paymentType !=
                                                      -1
                                                  ? R.colors.whiteColor
                                                  : Colors.transparent,
                                              size: 17,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      SizedBox()
                                  ],
                                ),
                                if (index ==
                                    (bookingsModel
                                        ?.paymentDetail
                                        ?.splitPayment
                                        ?.length ??
                                        0) -
                                        1)
                                  SizedBox()
                                else
                                  Divider(
                                    color: R.colors.grey,
                                    height: 3.h,
                                  )
                              ],
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                h2,
                if (bookingsModel?.paymentDetail?.remainingAmount ==
                    0.0 ||
                    bookingsModel?.bookingStatus !=
                        BookingStatus.ongoing.index)
                  SizedBox()
                else
                  Container(
                    decoration: BoxDecoration(
                        color: R.colors.blackDull,
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(
                        horizontal: Get.width * .05,
                        vertical: Get.height * .02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Remaining Payment",
                          style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.whiteColor,
                              fontSize: 14.sp),
                        ),
                        Text(
                          "\$${double.parse(removeSign(bookingsModel?.paymentDetail?.remainingAmount))}",
                          style: R.textStyle.helveticaBold().copyWith(
                            color: R.colors.yellowDark,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                h4,
                h4,
              ],
            )
          ),
        ),
        bottomNavigationBar: bookingsModel?.bookingStatus ==
                BookingStatus.canceled.index || bookingsModel?.bookingStatus ==
            BookingStatus.completed.index
            ? SizedBox(
                height: 1,
              )
            : Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: (bookingsModel?.paymentDetail?.remainingAmount
                                .toStringAsFixed(1) ==
                            "0.0" &&
                        bookingsModel?.paymentDetail?.paymentType != -1 &&
                        bookingsModel?.paymentDetail?.paymentStatus ==
                            PaymentStatus.markAsComplete.index)
                    ? Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Get.bottomSheet(SureBottomSheet(
                                  title: "Mark Complete",
                                  subTitle:
                                  "Are you sure you want to complete this booking?",
                                  yesCallBack: () async {
                                    Get.back();
                                    bookingsModel?.bookingStatus =
                                        BookingStatus.completed.index;
                                    bookingsModel?.paymentDetail?.paymentStatus=PaymentStatus.giveRating.index;
                                    bookingsModel?.paymentDetail?.splitPayment?.forEach((element) {
                                      bookingsModel?.paymentDetail?.splitPayment?[bookingsModel?.paymentDetail?.splitPayment?.indexOf(element)??0].paymentStatus=PaymentStatus.giveRating.index;
                                    });
                                    setState(() {});
                                    try {
                                      await FbCollections.bookings
                                          .doc(bookingsModel?.id)
                                          .set(bookingsModel?.toJson());
                                    } on Exception catch (e) {
                                      // TODO
                                      debugPrintStack();
                                      msg.log(e.toString());
                                    }
                                    provider.selectedTabIndex = 1;
                                    provider.update();
                                    Get.back();
                                  },
                                ));
                              },
                              child: Container(
                                height: Get.height * .055,
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                decoration: AppDecorations.gradientButton(radius: 30),
                                child: Center(
                                  child: Text(
                                    "MARK COMPLETE",
                                    style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.black,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ),
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Get.bottomSheet(SureBottomSheet(
                                  title: "Cancel Booking",
                                  subTitle:
                                  "Are you sure you want to cancel this booking",
                                  yesCallBack: () async {
                                    Get.back();
                                    bookingsModel?.bookingStatus =
                                        BookingStatus.canceled.index;
                                    setState(() {});
                                    try {
                                      await FbCollections.bookings
                                          .doc(bookingsModel?.id)
                                          .set(bookingsModel?.toJson());
                                      await sendNotification();
                                    } on Exception catch (e) {
                                      // TODO
                                      debugPrintStack();
                                      msg.log(e.toString());
                                    }
                                    provider.selectedTabIndex = 2;
                                    provider.update();
                                    Get.back();
                                  },
                                ));
                              },
                              child: Container(
                                height: Get.height * .055,
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                decoration: AppDecorations.gradientButton(radius: 30),
                                child: Center(
                                  child: Text(
                                    "CANCEL BOOKING",
                                    style: R.textStyle.helvetica().copyWith(
                                        color: R.colors.black,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ),
                      ],
                    )
                    : (bookingsModel?.paymentDetail?.remainingAmount
                                    .toStringAsFixed(1) ==
                                "0.0" &&
                            bookingsModel?.paymentDetail?.paymentType != -1 &&
                            bookingsModel?.paymentDetail?.paymentStatus ==
                                PaymentStatus.payInAppOrCash.index)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (bookingsModel
                                          ?.paymentDetail?.paymentType ==
                                      -1) {
                                    Helper.inSnackBar(
                                        "Error",
                                        "Renter did not pay yet",
                                        R.colors.themeMud);
                                  } else if ((bookingsModel
                                              ?.paymentDetail?.paymentStatus ??
                                          0) <
                                      2) {
                                    bookingsModel
                                            ?.paymentDetail?.paymentStatus =
                                        PaymentStatus.markAsComplete.index;
                                    bookingsModel
                                        ?.paymentDetail?.remainingAmount = 0.0;
                                    bookingsModel?.paymentDetail?.paymentType =
                                        bookingsModel?.paymentDetail
                                                    ?.paymentType ==
                                                PaymentType.payCash.index
                                            ? PaymentType.payCash.index
                                            : PaymentType.payInApp.index;
                                    setState(() {});
                                    try {
                                      await FbCollections.bookings
                                          .doc(bookingsModel?.id)
                                          .set(bookingsModel?.toJson());
                                    } on Exception catch (e) {
                                      // TODO
                                      debugPrintStack();
                                      msg.log(e.toString());
                                    }
                                    Get.back();
                                  }
                                },
                                child: Container(
                                  height: Get.height * .055,
                                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                                  decoration:
                                      AppDecorations.gradientButton(radius: 30),
                                  child: Center(
                                    child: Text(
                                      bookingsModel?.paymentDetail
                                                  ?.paymentType ==
                                              PaymentType.payCash.index
                                          ? "CASH RECEIVED"
                                          : bookingsModel?.paymentDetail
                                                      ?.paymentType ==
                                                  PaymentType.payInApp.index
                                              ? "RECEIVE IN APP"
                                              : "PENDING",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.black,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              h0P6,
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(children: [
                                  TextSpan(
                                    text:
                                        "Didn't receive the remaining amount? ",
                                    style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 10.sp,
                                        ),
                                  ),
                                  TextSpan(
                                    text: "Cancel Booking",
                                    style: R.textStyle.helveticaBold().copyWith(
                                          color: R.colors.yellowDark,
                                          fontSize: 10.sp,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.bold,
                                          height: 1.5,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        print("_________here");
                                        Get.bottomSheet(SureBottomSheet(
                                          title: "Cancel Booking",
                                          subTitle:
                                              "Are you sure you want to cancel this booking",
                                          yesCallBack: () async {
                                            Get.back();
                                            bookingsModel?.bookingStatus =
                                                BookingStatus.canceled.index;
                                            setState(() {});
                                            try {
                                              await FbCollections.bookings
                                                  .doc(bookingsModel?.id)
                                                  .set(bookingsModel?.toJson());
                                              await sendNotification();
                                            } on Exception catch (e) {
                                              // TODO
                                              debugPrintStack();
                                              msg.log(e.toString());
                                            }
                                            provider.selectedTabIndex = 2;
                                            provider.update();
                                            Get.back();
                                          },
                                        ));
                                      },
                                  ),
                                ]),
                              ),
                            ],
                          )
                        : Padding(
                          padding:  EdgeInsets.only(bottom: 1.h),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text:
                                          "Didn't receive the remaining amount? ",
                                      style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.whiteColor,
                                            fontSize: 10.sp,
                                          ),
                                    ),
                                    TextSpan(
                                      text: "Cancel Booking",
                                      style: R.textStyle.helveticaBold().copyWith(
                                            color: R.colors.yellowDark,
                                            fontSize: 10.sp,
                                            decoration: TextDecoration.underline,
                                            fontWeight: FontWeight.bold,
                                            height: 1.5,
                                          ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          Get.bottomSheet(SureBottomSheet(
                                            title: "Cancel Booking",
                                            subTitle:
                                                "Are you sure you want to cancel this booking",
                                            yesCallBack: () async {
                                              Get.back();
                                              bookingsModel?.bookingStatus =
                                                  BookingStatus.canceled.index;
                                              setState(() {});
                                              try {
                                                await FbCollections.bookings
                                                    .doc(bookingsModel?.id)
                                                    .set(bookingsModel?.toJson());
                                                await sendNotification();
                                              } on Exception catch (e) {
                                                // TODO
                                                debugPrintStack();
                                                msg.log(e.toString());
                                              }
                                              provider.selectedTabIndex = 2;
                                              provider.update();
                                              Get.back();
                                            },
                                          ));
                                        },
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                        )),
      );
    });
  }

  Widget tiles(String title, String subTitle, {bool isDivider = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  h1,
                  Text(
                    "${getTranslated(context, title)}",
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: R.colors.whiteDull, fontSize: 14.sp),
                  ),
                  h0P7,
                  Text(
                    subTitle,
                    style: R.textStyle.helvetica().copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
        isDivider == false
            ? SizedBox()
            : Container(
                margin: EdgeInsets.only(top: Get.height * .01),
                width: Get.width,
                child: Divider(
                  color: R.colors.grey.withOpacity(.30),
                  thickness: 2,
                ),
              )
      ],
    );
  }

  ///FUNCTION
  Future<void> sendNotification() async {
    try {
      await  NotificationService.sendNotification(
          fcmToken: rentalUser?.fcm??"",
          title: "Cancel Alert",
          body: "Your Charter has been Canceled by the Host");
      DocumentReference ref=FbCollections.notifications.doc();
      NotificationModel notificationModel= NotificationModel(
          bookingId: bookingsModel?.id,
          receiver: [rentalUser?.uid],
          id: ref.id,
          sender: FirebaseAuth.instance.currentUser?.uid,
          createdAt: Timestamp.now(),
          isSeen: false,
          type: NotificationReceiverType.host.index,
          hostUserId: context.read<BaseVm>().allUsers.firstWhereOrNull((element) => element.uid==bookingsModel?.hostUserUid)?.uid??"",
          title: "Cancel Alert",
          text:"Your Charter has been Canceled by the Host");
      await ref.set(notificationModel.toJson());
    } catch (e) {
      print(e.toString());
    }
  }

}
