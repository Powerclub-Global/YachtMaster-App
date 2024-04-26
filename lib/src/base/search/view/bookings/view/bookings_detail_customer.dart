import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/payments_methods.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/settings/widgets/feedback_bottomsheet.dart';
import 'package:yacht_master/src/base/yacht/widgets/congo_bottomSheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';

class BookingsDetail extends StatefulWidget {
  static String route = "/bookingsDetail";

  const BookingsDetail({Key? key}) : super(key: key);

  @override
  _BookingsDetailState createState() => _BookingsDetailState();
}

class _BookingsDetailState extends State<BookingsDetail> {
  BookingsModel? bookingsModel;
  double remaimingAmount = 0.0;
  bool isLoading = false;
  SplitPaymentModel? firstSlpliter;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      bookingsModel = args["bookingsModel"];
      if (bookingsModel?.paymentDetail?.isSplit == true) {
        firstSlpliter = bookingsModel?.paymentDetail?.splitPayment
            ?.where((element) =>
                element.userUid == FirebaseAuth.instance.currentUser?.uid)
            .first;
        bookingsModel?.paymentDetail?.splitPayment?.forEach((element) {
          if (element.depositStatus == 1) {
            ///0 means paid 1 means not fully paid
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
    return Consumer<BookingsVm>(builder: (context, provider, _) {
      return Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(
              context, getTranslated(context, "booking_details") ?? ""),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
              child: FutureBuilder(
                  future: FbCollections.charterFleet
                      .doc(bookingsModel?.charterFleetDetail?.id)
                      .get(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox();
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SpinKitPulse(
                        color: R.colors.themeMud,
                      );
                    } else {
                      CharterModel charterModel =
                          CharterModel.fromJson(snapshot.data?.data());
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          h1,
                          Row(
                            children: [
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
                              w4,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    charterModel.name ?? "",
                                    style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.whiteColor,
                                        fontSize: 15.sp),
                                  ),
                                  h0P5,
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
                                            hostSnap.data?.get("first_name"),
                                            style: R.textStyle
                                                .helvetica()
                                                .copyWith(
                                                    color: R.colors.whiteDull,
                                                    fontSize: 13.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                          );
                                        }
                                      }),
                                  h0P5,
                                  SizedBox(
                                    width: Get.width * .5,
                                    child: Text(
                                      " ${charterModel.location?.adress}",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteDull,
                                          fontSize: 11.sp),
                                      maxLines: 2,
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
                            child: FutureBuilder(
                                future: FbCollections.user
                                    .doc(charterModel.createdBy)
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot>
                                        userSnapshot) {
                                  if (!userSnapshot.hasData) {
                                    return SizedBox();
                                  } else if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: SpinKitPulse(
                                        color: R.colors.themeMud,
                                      ),
                                    );
                                  } else {
                                    UserModel bookingUser = UserModel.fromJson(
                                        userSnapshot.data?.data());
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Host Details",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteColor,
                                                  fontSize: 14.sp),
                                        ),
                                        h1P5,
                                        Text(
                                          "${bookingUser.firstName}",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteDull,
                                                  fontSize: 12.sp),
                                        ),
                                        h1P5,
                                        Text(
                                          "${bookingUser.email}",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteColor,
                                                  fontSize: 11.sp),
                                        ),
                                        h1P5,
                                        Text(
                                          "${bookingUser.dialCode}${bookingUser.number}",
                                          style: R.textStyle
                                              .helveticaBold()
                                              .copyWith(
                                                  color: R.colors.whiteColor,
                                                  fontSize: 11.sp),
                                        ),
                                      ],
                                    );
                                  }
                                }),
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
                                tiles("marina_address",
                                    charterModel.location!.adress ?? ""),
                                tiles("dock_no",
                                    charterModel.location!.dockno ?? ""),
                                tiles("slip_no",
                                    charterModel.location!.slipno ?? "",
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
                                horizontal: Get.width * .03,
                                vertical: Get.height * .02),
                            child: Column(
                              children: [
                                tiles(
                                  "start_date_time",
                                  DateFormat("dd/MM/yyyy hh:mm a").format(
                                      (bookingsModel?.schedule?.dates?.first
                                              .toDate() ??
                                          DateTime.now())),
                                ),
                                tiles(
                                    "end_date_time",
                                    DateFormat("dd/MM/yyyy hh:mm a").format(
                                        (bookingsModel?.schedule?.dates?.last
                                                .toDate() ??
                                            DateTime.now()))),
                                tiles("guests", "${bookingsModel?.totalGuest}",
                                    isDivider: false),
                              ],
                            ),
                          ),
                          h2,
                          Container(
                            width: Get.width,
                            decoration: BoxDecoration(
                                color: R.colors.blackDull,
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(
                                horizontal: Get.width * .03,
                                vertical: Get.height * .02),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  charterModel.boardingInstructions?.title ??
                                      "",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 14.sp),
                                ),
                                h1P5,
                                Text(
                                  charterModel
                                          .boardingInstructions?.description ??
                                      "",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteDull,
                                      fontSize: 12.sp),
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
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    bookingsModel?.paymentDetail
                                                                ?.payInType ==
                                                            PayType
                                                                .fullPay.index
                                                        ? "Fully Pay"
                                                        : "25% Deposit",
                                                    style: R.textStyle
                                                        .helveticaBold()
                                                        .copyWith(
                                                            color: R.colors
                                                                .whiteColor,
                                                            fontSize: 10.sp,
                                                            height: 1.5),
                                                  ),
                                                  Text(
                                                    " with ",
                                                    style: R.textStyle
                                                        .helvetica()
                                                        .copyWith(
                                                            color: R.colors
                                                                .whiteColor,
                                                            fontSize: 10.sp,
                                                            height: 1.5),
                                                  ),
                                                  Text(
                                                    bookingsModel?.paymentDetail
                                                                ?.paymentMethod ==
                                                            PaymentMethodEnum
                                                                .wallet.index
                                                        ? "Wallet"
                                                        : bookingsModel
                                                                    ?.paymentDetail
                                                                    ?.paymentMethod ==
                                                                PaymentMethodEnum
                                                                    .card.index
                                                            ? "Credit Card"
                                                            : bookingsModel
                                                                        ?.paymentDetail
                                                                        ?.paymentMethod ==
                                                                    PaymentMethodEnum
                                                                        .appStore
                                                                        .index
                                                                ? "Apple Pay"
                                                                : "Crypto Currency",
                                                    style: R.textStyle
                                                        .helvetica()
                                                        .copyWith(
                                                            color: R.colors
                                                                .whiteColor,
                                                            fontSize: 10.sp,
                                                            height: 1.5),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            h0P7,
                                            if (bookingsModel?.paymentDetail
                                                    ?.paymentMethod !=
                                                PaymentMethodEnum.card.index)
                                              SizedBox()
                                            else
                                              Text(
                                                "${(bookingsModel?.paymentDetail?.currentUserCardNum ?? "").obsecureCardNum()}",
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
                                          ? "\$${Helper.numberFormatter(double.parse(bookingsModel?.paymentDetail?.splitPayment?.first.amount?.toStringAsFixed(1)))}"
                                          : bookingsModel?.paymentDetail
                                                          ?.isSplit ==
                                                      true &&
                                                  bookingsModel?.paymentDetail
                                                          ?.payInType ==
                                                      PayType.deposit.index
                                              ? "\$${Helper.numberFormatter(double.parse(((bookingsModel?.priceDetaill?.totalPrice ?? 0) * (25 / 100)).toStringAsFixed(1)))}"
                                              : "\$${Helper.numberFormatter(double.parse(bookingsModel?.paymentDetail?.paidAmount?.toStringAsFixed(1)))}",
                                      style:
                                          R.textStyle.helveticaBold().copyWith(
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
                                        bookingsModel?.paymentDetail
                                                ?.splitPayment?.length ??
                                            0, (index) {
                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 3,
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
                                                        future: FbCollections
                                                            .user
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
                                                flex: 2,
                                                child: Text(
                                                  ((bookingsModel?.paymentDetail?.payInType == PayType.deposit.index &&
                                                              bookingsModel?.paymentDetail?.splitPayment?[index].depositStatus ==
                                                                  DepositStatus
                                                                      .nothingPaid
                                                                      .index) ||
                                                          bookingsModel
                                                                      ?.paymentDetail
                                                                      ?.payInType ==
                                                                  PayType
                                                                      .fullPay
                                                                      .index &&
                                                              bookingsModel?.paymentDetail?.splitPayment?[index].remainingAmount.toStringAsFixed(1) !=
                                                                  "0.0"
                                                      // && bookingsModel?.bookingStatus==BookingStatus.canceled.index
                                                      )
                                                      ? "-"
                                                      : bookingsModel?.paymentDetail?.payInType ==
                                                                  PayType
                                                                      .deposit
                                                                      .index &&
                                                              bookingsModel
                                                                      ?.paymentDetail
                                                                      ?.splitPayment?[index]
                                                                      .depositStatus ==
                                                                  DepositStatus.twentyFivePaid.index
                                                          ? "\$${Helper.numberFormatter(double.parse(bookingsModel?.paymentDetail?.splitPayment?[index].remainingAmount.toStringAsFixed(1)))}"
                                                          : "\$${Helper.numberFormatter(double.parse(bookingsModel?.paymentDetail?.splitPayment?[index].amount.toStringAsFixed(1)))}",
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
                          if (bookingsModel?.paymentDetail?.remainingAmount
                                  .toStringAsFixed(1) ==
                              "0.0")
                            SizedBox()
                          else
                            bookingsModel?.paymentDetail?.splitPayment
                                            ?.isNotEmpty ==
                                        true &&
                                    bookingsModel?.paymentDetail?.isSplit ==
                                        true &&
                                    bookingsModel?.paymentDetail?.payInType ==
                                        PayType.fullPay.index &&
                                    bookingsModel?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .toList()
                                            .first
                                            .paymentStatus ==
                                        PaymentStatus.payInAppOrCash.index &&
                                    firstSlpliter?.remainingAmount
                                            .toStringAsFixed(1) ==
                                        "0.0"
                                ? SizedBox()
                                : Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: R.colors.blackDull,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Get.width * .05,
                                        vertical: Get.height * .02),
                                    child: bookingsModel?.bookingStatus ==
                                                BookingStatus.canceled.index &&
                                            bookingsModel?.paymentDetail
                                                    ?.remainingAmount
                                                    .toStringAsFixed(1) ==
                                                "0.0"
                                        ? Text(
                                            "Cancelled By Host",
                                            style: R.textStyle
                                                .helveticaBold()
                                                .copyWith(
                                                    color: R.colors.deleteColor,
                                                    fontSize: 14.sp),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Remaining Payment",
                                                style: R.textStyle
                                                    .helveticaBold()
                                                    .copyWith(
                                                        color:
                                                            R.colors.whiteColor,
                                                        fontSize: 14.sp),
                                              ),
                                              Text(
                                                bookingsModel?.paymentDetail?.isSplit == true &&
                                                        bookingsModel
                                                                ?.paymentDetail
                                                                ?.payInType ==
                                                            PayType.fullPay
                                                                .index &&
                                                        firstSlpliter?.paymentStatus ==
                                                            PaymentStatus
                                                                .payInAppOrCash
                                                                .index
                                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(firstSlpliter?.remainingAmount)))}"
                                                    : bookingsModel?.paymentDetail?.isSplit == true &&
                                                            bookingsModel
                                                                    ?.paymentDetail
                                                                    ?.payInType ==
                                                                PayType.deposit
                                                                    .index &&
                                                            firstSlpliter?.depositStatus ==
                                                                DepositStatus
                                                                    .nothingPaid
                                                                    .index
                                                        ? "\$${Helper.numberFormatter(double.parse(removeSign(firstSlpliter?.remainingDeposit)))}"
                                                        : bookingsModel?.paymentDetail?.isSplit == true &&
                                                                bookingsModel
                                                                        ?.paymentDetail
                                                                        ?.payInType ==
                                                                    PayType
                                                                        .deposit
                                                                        .index &&
                                                                firstSlpliter?.depositStatus ==
                                                                    DepositStatus
                                                                        .twentyFivePaid
                                                                        .index
                                                            ? "\$${Helper.numberFormatter(double.parse(removeSign(firstSlpliter?.remainingAmount)))}"
                                                            : bookingsModel?.paymentDetail?.isSplit == true &&
                                                                    bookingsModel?.paymentDetail?.payInType ==
                                                                        PayType
                                                                            .deposit
                                                                            .index &&
                                                                    firstSlpliter?.depositStatus ==
                                                                        DepositStatus.fullPaid.index
                                                                ? "\$${Helper.numberFormatter(double.parse(removeSign(firstSlpliter?.remainingAmount)))}"
                                                                : bookingsModel?.paymentDetail?.isSplit == true && bookingsModel?.paymentDetail?.payInType == PayType.fullPay.index
                                                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(firstSlpliter?.remainingAmount)))}"
                                                                    : "\$${Helper.numberFormatter(double.parse(removeSign(bookingsModel?.paymentDetail?.remainingAmount)))}",
                                                style: R.textStyle
                                                    .helveticaBold()
                                                    .copyWith(
                                                      color:
                                                          R.colors.yellowDark,
                                                      fontSize: 15.sp,
                                                    ),
                                              ),
                                            ],
                                          ),
                                  ),
                          h4,
                          h4,
                        ],
                      );
                    }
                  }),
            ),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: ((bookingsModel?.paymentDetail?.isSplit == true &&
                        removeSign(firstSlpliter?.remainingAmount) == "0.0" &&
                        bookingsModel?.bookingStatus ==
                            BookingStatus.ongoing.index &&
                        firstSlpliter?.paymentType != -1 &&
                        firstSlpliter?.paymentStatus ==
                            PaymentStatus.payInAppOrCash.index) ||
                    (bookingsModel?.paymentDetail?.isSplit == false &&
                        removeSign(bookingsModel?.paymentDetail?.remainingAmount) ==
                            "0.0" &&
                        bookingsModel?.bookingStatus ==
                            BookingStatus.ongoing.index &&
                        bookingsModel?.paymentDetail?.paymentType != -1 &&
                        bookingsModel?.paymentDetail?.paymentStatus ==
                            PaymentStatus.payInAppOrCash.index))
                ? SizedBox()
                : ((bookingsModel?.paymentDetail?.isSplit == false &&
                            bookingsModel?.paymentDetail?.payInType ==
                                PayType.deposit.index &&
                            bookingsModel?.paymentDetail?.paymentStatus ==
                                PaymentStatus.payInAppOrCash.index &&
                            bookingsModel?.bookingStatus ==
                                BookingStatus.ongoing.index) ||
                        (bookingsModel?.paymentDetail?.isSplit == true &&
                            bookingsModel?.paymentDetail?.payInType ==
                                PayType.deposit.index &&
                            removeSign(firstSlpliter?.remainingDeposit) ==
                                "0.0" &&
                            removeSign(firstSlpliter?.remainingAmount) !=
                                "0.0" &&
                            bookingsModel?.bookingStatus ==
                                BookingStatus.ongoing.index) ||
                        (bookingsModel?.paymentDetail?.isSplit == true &&
                            bookingsModel?.paymentDetail?.payInType ==
                                PayType.fullPay.index &&
                            firstSlpliter?.paymentStatus ==
                                PaymentStatus.payInAppOrCash.index &&
                            firstSlpliter?.paymentType == -1 &&
                            bookingsModel?.bookingStatus ==
                                BookingStatus.ongoing.index))
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.w, vertical: 1.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  var baseVm = Provider.of<BaseVm>(context,
                                      listen: false);
                                  var authVm = Provider.of<AuthVm>(context,
                                      listen: false);
                                  if (bookingsModel?.paymentDetail?.isSplit ==
                                      true) {
                                    if (bookingsModel
                                            ?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .first
                                            .depositStatus ==
                                        DepositStatus.nothingPaid.index) {
                                      bookingsModel?.paymentDetail?.paidAmount =
                                          bookingsModel
                                                  ?.paymentDetail?.paidAmount +
                                              bookingsModel
                                                  ?.paymentDetail?.splitPayment
                                                  ?.where((element) =>
                                                      element.userUid ==
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid)
                                                  .first
                                                  .remainingDeposit;
                                      bookingsModel?.paymentDetail
                                          ?.remainingAmount = bookingsModel
                                              ?.paymentDetail?.remainingAmount -
                                          bookingsModel
                                              ?.paymentDetail?.splitPayment
                                              ?.where((element) =>
                                                  element.userUid ==
                                                  FirebaseAuth.instance
                                                      .currentUser?.uid)
                                              .first
                                              .remainingDeposit;
                                    } else if (bookingsModel
                                            ?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .first
                                            .depositStatus ==
                                        DepositStatus.twentyFivePaid.index) {
                                      bookingsModel?.paymentDetail?.paidAmount =
                                          bookingsModel
                                                  ?.paymentDetail?.paidAmount +
                                              bookingsModel
                                                  ?.paymentDetail?.splitPayment
                                                  ?.where((element) =>
                                                      element.userUid ==
                                                      FirebaseAuth.instance
                                                          .currentUser?.uid)
                                                  .first
                                                  .remainingAmount;
                                      bookingsModel?.paymentDetail
                                          ?.remainingAmount = bookingsModel
                                              ?.paymentDetail?.remainingAmount -
                                          bookingsModel
                                              ?.paymentDetail?.splitPayment
                                              ?.where((element) =>
                                                  element.userUid ==
                                                  FirebaseAuth.instance
                                                      .currentUser?.uid)
                                              .first
                                              .remainingAmount;
                                    }
                                    bookingsModel?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .first
                                            .paymentType =
                                        PaymentType.payCash.index;
                                    bookingsModel?.paymentDetail?.splitPayment?.where((element) => element.userUid == FirebaseAuth.instance.currentUser?.uid).first.amount = bookingsModel
                                                ?.paymentDetail?.payInType ==
                                            PayType.fullPay.index
                                        ? bookingsModel?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .first
                                            .amount
                                        : bookingsModel?.paymentDetail?.splitPayment?.where((element) => element.userUid == FirebaseAuth.instance.currentUser?.uid).first.depositStatus ==
                                                DepositStatus.nothingPaid.index
                                            ? bookingsModel
                                                ?.paymentDetail?.splitPayment
                                                ?.where((element) =>
                                                    element.userUid ==
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid)
                                                .first
                                                .remainingDeposit
                                            : bookingsModel?.paymentDetail?.splitPayment?.where((element) => element.userUid == FirebaseAuth.instance.currentUser?.uid).first.amount +
                                                bookingsModel?.paymentDetail
                                                    ?.splitPayment
                                                    ?.where((element) => element.userUid == FirebaseAuth.instance.currentUser?.uid)
                                                    .first
                                                    .remainingAmount;
                                    bookingsModel?.paymentDetail?.splitPayment
                                        ?.where((element) =>
                                            element.userUid ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid)
                                        .first
                                        .remainingAmount = bookingsModel
                                                ?.paymentDetail?.splitPayment
                                                ?.where((element) =>
                                                    element.userUid ==
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid)
                                                .first
                                                .depositStatus ==
                                            DepositStatus.twentyFivePaid.index
                                        ? 0.0
                                        : bookingsModel
                                            ?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .first
                                            .remainingAmount;
                                    bookingsModel?.paymentDetail?.splitPayment
                                        ?.where((element) =>
                                            element.userUid ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid)
                                        .first
                                        .remainingDeposit = 0.0;
                                    bookingsModel?.paymentDetail?.splitPayment
                                        ?.where((element) =>
                                            element.userUid ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid)
                                        .first
                                        .depositStatus = bookingsModel
                                                ?.paymentDetail?.splitPayment
                                                ?.where((element) =>
                                                    element.userUid ==
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid)
                                                .first
                                                .depositStatus ==
                                            DepositStatus.twentyFivePaid.index
                                        ? DepositStatus.fullPaid.index
                                        : DepositStatus.twentyFivePaid.index;
                                    bookingsModel?.paymentDetail?.splitPayment
                                            ?.where((element) =>
                                                element.userUid ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid)
                                            .first
                                            .paymentStatus =
                                        PaymentStatus.payInAppOrCash.index;
                                  } else {
                                    bookingsModel?.paymentDetail?.paymentType =
                                        PaymentType.payCash.index;
                                    bookingsModel?.paymentDetail?.paidAmount =
                                        bookingsModel
                                                ?.paymentDetail?.paidAmount +
                                            bookingsModel?.paymentDetail
                                                ?.remainingAmount;
                                    bookingsModel
                                        ?.paymentDetail?.remainingAmount = 0.0;
                                    bookingsModel
                                            ?.paymentDetail?.paymentStatus =
                                        PaymentStatus.payInAppOrCash.index;
                                  }
                                  baseVm.selectedPage = -1;
                                  baseVm.isHome = true;
                                  baseVm.update();
                                  try {
                                    log("}}}}}}}}}}}}}}}}}}}${bookingsModel?.id}");

                                    await FbCollections.bookings
                                        .doc(bookingsModel?.id)
                                        .set(bookingsModel?.toJson());
                                  } on Exception catch (e) {
                                    // TODO
                                    debugPrintStack();
                                    log(e.toString());
                                  }
                                  Get.bottomSheet(Congoratulations(
                                      getTranslated(context,
                                              "your_booking_has_been_confirmed_successfully_crypto") ??
                                          "", () {
                                    Timer(Duration(seconds: 2), () async {
                                      await authVm.cancleStreams();
                                      Get.offAllNamed(BaseView.route);
                                    });
                                  }));
                                },
                                child: Container(
                                  height: Get.height * .055,
                                  decoration: AppDecorations.buttonDecoration(
                                      R.colors.whiteDull, 30),
                                  child: Center(
                                    child: Text(
                                      "PAY CASH",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.black,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            w2,
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  provider.update();

                                  Get.toNamed(PaymentMethods.route, arguments: {
                                    "isDeposit": bookingsModel
                                                ?.paymentDetail?.payInType ==
                                            PayType.fullPay.index
                                        ? false
                                        : true,
                                    "bookingsModel": bookingsModel,
                                    "isCompletePayment": true
                                  });
                                },
                                child: Container(
                                  height: Get.height * .055,
                                  decoration:
                                      AppDecorations.gradientButton(radius: 30),
                                  child: Center(
                                    child: Text(
                                      "PAY IN APP",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.black,
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ((bookingsModel?.paymentDetail?.isSplit == true &&
                            bookingsModel?.paymentDetail?.payInType ==
                                PayType.deposit.index &&
                            removeSign(firstSlpliter?.remainingDeposit) !=
                                "0.0" &&
                            bookingsModel?.bookingStatus ==
                                BookingStatus.ongoing.index))
                        ? GestureDetector(
                            onTap: () {
                              provider.update();
                              Get.toNamed(PaymentMethods.route, arguments: {
                                "isDeposit":
                                    bookingsModel?.paymentDetail?.payInType ==
                                            PayType.fullPay.index
                                        ? false
                                        : true,
                                "bookingsModel": bookingsModel,
                                "isCompletePayment": true
                              });
                            },
                            child: Container(
                              height: Get.height * .055,
                              width: Get.width * .85,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              decoration:
                                  AppDecorations.gradientButton(radius: 30),
                              child: Center(
                                child: Text(
                                  "CONFIRM & PAY",
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.black,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          )
                        : ((firstSlpliter?.paymentStatus ==
                                        PaymentStatus.giveRating.index &&
                                    bookingsModel?.bookingStatus ==
                                        BookingStatus.completed.index) ||
                                (bookingsModel?.paymentDetail?.paymentStatus ==
                                        PaymentStatus.giveRating.index &&
                                    bookingsModel?.paymentDetail?.isSplit == false &&
                                    bookingsModel?.bookingStatus == BookingStatus.completed.index))
                            ? GestureDetector(
                                onTap: () {
                                  Get.bottomSheet(FeedbackSheet(
                                    bookingsModel: bookingsModel,
                                    submitCallBack: (rat, desc) async {
                                      log("____________RATING:${rat}____:${desc}____${bookingsModel?.id}");
                                      firstSlpliter?.paymentStatus =
                                          PaymentStatus.ratingDone.index;
                                      if (bookingsModel
                                              ?.paymentDetail?.splitPayment
                                              ?.every((element) =>
                                                  element.paymentStatus ==
                                                  PaymentStatus
                                                      .ratingDone.index) ==
                                          true) {
                                        bookingsModel
                                                ?.paymentDetail?.paymentStatus =
                                            PaymentStatus.ratingDone.index;
                                      }
                                      setState(() {});
                                      String docId = Timestamp.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      ReviewModel reviewModel = ReviewModel(
                                        bookingId: bookingsModel?.id,
                                        userId: FirebaseAuth
                                            .instance.currentUser?.uid,
                                        rating: rat,
                                        description: desc,
                                        createdAt: Timestamp.now(),
                                        charterFleetDetail: CharterFleetDetail(
                                            id: bookingsModel
                                                ?.charterFleetDetail?.id,
                                            location: bookingsModel
                                                ?.charterFleetDetail?.location,
                                            name: bookingsModel
                                                ?.charterFleetDetail?.name,
                                            image: bookingsModel
                                                ?.charterFleetDetail?.image),
                                        id: docId,
                                        hostId: bookingsModel?.hostUserUid,
                                      );
                                      try {
                                        await FbCollections.bookings
                                            .doc(bookingsModel?.id)
                                            .set(bookingsModel?.toJson());
                                        await FbCollections.bookingReviews
                                            .doc(docId)
                                            .set(reviewModel.toJson());
                                      } on Exception catch (e) {
                                        // TODO
                                        debugPrintStack();
                                        log(e.toString());
                                      }
                                      Get.back();
                                      Get.back();
                                      Helper.inSnackBar(
                                          "Success",
                                          "Submitted successfully",
                                          R.colors.themeMud);
                                    },
                                  ));
                                },
                                child: Container(
                                  height: Get.height * .055,
                                  width: Get.width * .8,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  decoration:
                                      AppDecorations.gradientButton(radius: 30),
                                  child: Center(
                                    child: Text(
                                      "GIVE RATING",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.black,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
          ));
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          subTitle,
                          style: R.textStyle.helvetica().copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 10.sp),
                        ),
                      ],
                    ),
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

  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }
}
