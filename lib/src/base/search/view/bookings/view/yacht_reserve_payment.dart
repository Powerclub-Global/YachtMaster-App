import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../../../appwrite.dart';
import '../../../../../../constant/enums.dart';
import '../../../../../../localization/app_localization.dart';
import '../../../../../../resources/decorations.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../services/firebase_collections.dart';
import '../../../../../../services/time_schedule_service.dart';
import '../../../model/charter_model.dart';
import '../view_model/bookings_vm.dart';
import '../../when_will_be_there.dart';
import '../../whos_coming.dart';
import '../../../../settings/view_model/settings_vm.dart';
import '../../../../widgets/agreement_sheet.dart';
import '../../../../widgets/exit_sheet.dart';
import '../../../../widgets/tip_sheet.dart';
import '../../../../yacht/view/rules_regulations.dart';
import '../../../../yacht/widgets/congo_bottomSheet.dart';
import '../../../../../../utils/general_app_bar.dart';
import '../../../../../../utils/heights_widths.dart';
import '../../../../../../utils/helper.dart';

class YachtReservePayment extends StatefulWidget {
  static String route = "/yachtReservePayment";

  const YachtReservePayment({Key? key}) : super(key: key);

  @override
  _YachtReservePaymentState createState() => _YachtReservePaymentState();
}

class _YachtReservePaymentState extends State<YachtReservePayment> {
  CharterModel? charter;

  int isSplit = 1;
  String price = "0.00";
  double totalPriceAndServiceFee = 0.0;
  double grandTotal = 0.0;
  bool isLoading = false;
  double? tip;
  int _selectedIndex = 0;
  double? temp;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  ///0 yes,1 no
  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    charter = args["yacht"];

    return Consumer<BookingsVm>(builder: (context, provider, _) {
      if (grandTotal != 0.0) {
        temp = grandTotal;
      }
      price = provider.bookingsModel.durationType ==
              CharterDayType.halfDay.index
          ? "${charter?.priceFourHours?.toStringAsFixed(1)}"
          : provider.bookingsModel.durationType == CharterDayType.fullDay.index
              ? "${charter?.priceHalfDay?.toStringAsFixed(1)}"
              : "${charter?.priceFullDay?.toStringAsFixed(1)}";
      if (provider.bookingsModel.durationType ==
              CharterDayType.multiDay.index &&
          provider.bookingsModel.schedule?.dates?.isNotEmpty == true) {
        totalPriceAndServiceFee = (double.parse(price.replaceAll(",", "")) *
                (provider.bookingsModel.schedule?.dates?.length ?? 0)) +
            provider.serviceFee;
        grandTotal = double.parse(((totalPriceAndServiceFee +
                Helper().calculatePercentage(
                    provider.taxes, totalPriceAndServiceFee) +
                Helper().calculatePercentage(
                    provider.tips, totalPriceAndServiceFee))
            .toStringAsFixed(1)));
      } else {
        totalPriceAndServiceFee =
            double.parse(price.replaceAll(",", "")) + provider.serviceFee;
        grandTotal = double.parse(((totalPriceAndServiceFee +
                Helper().calculatePercentage(
                    provider.taxes, totalPriceAndServiceFee) +
                Helper().calculatePercentage(
                    provider.tips, totalPriceAndServiceFee))
            .toStringAsFixed(1)));
      }
      tip ??= Helper().calculatePercentage(10, totalPriceAndServiceFee);
      if (temp != null) {
        grandTotal = temp!;
      }

      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: Consumer<SettingsVm>(builder: (context, settingsVm, _) {
          return Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(
                context, getTranslated(context, "confirm_and_pay") ?? ""),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
                child: Column(
                  children: [
                    h1,
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl:
                                  charter?.images?.first ?? R.images.serviceUrl,
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
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                charter?.name ?? "",
                                style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.whiteColor,
                                    fontSize: 15.sp),
                              ),
                              h0P5,
                              FutureBuilder(
                                  future: FbCollections.user
                                      .doc(charter?.createdBy)
                                      .get(),
                                  builder: (context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          hostSnap) {
                                    if (!hostSnap.hasData) {
                                      return SizedBox();
                                    } else {
                                      return Text(
                                        hostSnap.data?.get("first_name"),
                                        style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.whiteDull,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold),
                                      );
                                    }
                                  }),
                              h0P5,
                              Text(
                                charter?.location?.adress ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    h3,
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
                            () {
                              Get.toNamed(WhenWillBeThere.route, arguments: {
                                "cityModel": null,
                                "yacht": charter,
                                "isReserve": false,
                                "isSelectTime": false,
                                "bookingsModel": provider.bookingsModel
                              });
                            },
                            "date",
                            provider.bookingsModel.schedule?.dates != null &&
                                    provider.bookingsModel.schedule?.dates
                                            ?.length ==
                                        1
                                ? (provider.bookingsModel.schedule?.dates?.first
                                            .toDate() ??
                                        DateTime.now())
                                    .formateDateMDY()
                                : "${(provider.bookingsModel.schedule?.dates?.first.toDate() ?? DateTime.now()).formateDateMDY()} - ${(provider.bookingsModel.schedule?.dates?.last.toDate() ?? DateTime.now()).formateDateMDY()}",
                          ),
                          tiles(() {
                            Get.toNamed(WhenWillBeThere.route, arguments: {
                              "cityModel": null,
                              "yacht": charter,
                              "isReserve": false,
                              "isSelectTime": false,
                              "bookingsModel": provider.bookingsModel
                            });
                          }, "time",
                              "${provider.bookingsModel.schedule?.startTime} - ${provider.bookingsModel.schedule?.endTime}"),
                          tiles(() {
                            Get.toNamed(WhosComing.route, arguments: {
                              "cityModel": null,
                              "yacht": charter,
                              "isReserve": false,
                              "bookingsModel": provider.bookingsModel,
                              "isEdit": true
                            });
                          }, "guests", "${provider.bookingsModel.totalGuest}",
                              isDivider: false),
                        ],
                      ),
                    ),
                    h3,
                    Text(
                      "${getTranslated(context, "price_detail")}",
                      style: R.textStyle.helvetica().copyWith(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    h3,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sub Total",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor, fontSize: 14.sp),
                        ),
                        Text(
                          "\$${double.parse(price).toStringAsFixed(2)}",
                          style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontSize: 15.sp,
                              ),
                        ),
                      ],
                    ),
                    h1P5,
                    if (provider.bookingsModel.durationType ==
                            CharterDayType.multiDay.index &&
                        provider.bookingsModel.schedule?.dates?.isNotEmpty ==
                            true)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Days",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor, fontSize: 14.sp),
                          ),
                          Text(
                            "${provider.bookingsModel.schedule?.dates?.length}",
                            style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 15.sp,
                                ),
                          ),
                        ],
                      )
                    else
                      SizedBox(),
                    h1P5,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Service Fee",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor, fontSize: 14.sp),
                        ),
                        Text(
                          "\$${double.parse(provider.serviceFee.toStringAsFixed(1)).toStringAsFixed(2)}",
                          style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontSize: 15.sp,
                              ),
                        ),
                      ],
                    ),
                    h1P5,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, "taxes") ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor, fontSize: 14.sp),
                        ),
                        Text(
                          "\$${Helper().calculatePercentage(provider.taxes, totalPriceAndServiceFee).toStringAsFixed(2)}",
                          style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontSize: 15.sp,
                              ),
                        ),
                      ],
                    ),
                    h1P5,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, "tip") ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor, fontSize: 14.sp),
                        ),
                        Text(
                          "\$${tip!.toStringAsFixed(2)}",
                          style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontSize: 15.sp,
                              ),
                        ),
                      ],
                    ),
                    h1P5,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, "total") ?? "",
                          style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.whiteColor, fontSize: 14.5.sp),
                        ),
                        Text(
                          ///TOTAL=SUBTOTAL+ 7% OF TAX+ 13% OF TIPS
                          "\$${grandTotal.toStringAsFixed(2)}",
                          style: R.textStyle.helveticaBold().copyWith(
                                color: R.colors.yellowDark,
                                fontSize: 15.sp,
                              ),
                        ),
                      ],
                    ),
                    h3,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "  How much do you want to Tip?",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.sp),
                        ),
                        SizedBox(),
                      ],
                    ),
                    h2,
                    Container(
                      // color: Colors.white,
                      decoration: BoxDecoration(
                          color: R.colors.blackDull,
                          borderRadius: BorderRadius.circular(30)),
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: _selectedIndex == 0
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: TextButton(
                              child: Text(
                                "\$${Helper().calculatePercentage(10, totalPriceAndServiceFee).toStringAsFixed(2)}",
                                style: TextStyle(color: Colors.amber),
                              ),
                              onPressed: () {
                                tip = Helper().calculatePercentage(
                                    10, totalPriceAndServiceFee);
                                _selectedIndex = 0;
                                grandTotal = double.parse(
                                    ((totalPriceAndServiceFee +
                                            Helper().calculatePercentage(
                                                provider.taxes,
                                                totalPriceAndServiceFee) +
                                            tip!)
                                        .toStringAsFixed(1)));
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: _selectedIndex == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: TextButton(
                                child: Text(
                                  "\$${Helper().calculatePercentage(15, totalPriceAndServiceFee).toStringAsFixed(2)}",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                onPressed: () {
                                  tip = Helper().calculatePercentage(
                                      15, totalPriceAndServiceFee);
                                  _selectedIndex = 1;
                                  grandTotal = double.parse(
                                      ((totalPriceAndServiceFee +
                                              Helper().calculatePercentage(
                                                  provider.taxes,
                                                  totalPriceAndServiceFee) +
                                              tip!)
                                          .toStringAsFixed(1)));
                                  log(tip.toString());
                                  setState(() {});
                                }),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: _selectedIndex == 2
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: TextButton(
                                child: Text(
                                  "\$${Helper().calculatePercentage(20, totalPriceAndServiceFee).toStringAsFixed(2)}",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                onPressed: () {
                                  tip = Helper().calculatePercentage(
                                      20, totalPriceAndServiceFee);
                                  _selectedIndex = 2;
                                  grandTotal = double.parse(
                                      ((totalPriceAndServiceFee +
                                              Helper().calculatePercentage(
                                                  provider.taxes,
                                                  totalPriceAndServiceFee) +
                                              tip!)
                                          .toStringAsFixed(1)));
                                  setState(() {});
                                }),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: _selectedIndex == 3
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: TextButton(
                                child: Text(
                                  'Other',
                                  style: TextStyle(color: Colors.amber),
                                ),
                                onPressed: () {
                                  _selectedIndex = 3;
                                  Get.bottomSheet(TipAmountSheet(
                                    yesCallBack: (value) {
                                      tip = double.parse(value);
                                      grandTotal = double.parse(
                                          ((totalPriceAndServiceFee +
                                                  Helper().calculatePercentage(
                                                      provider.taxes,
                                                      totalPriceAndServiceFee) +
                                                  tip!)
                                              .toStringAsFixed(1)));
                                      setState(() {});
                                    },
                                  ));
                                }),
                          ),
                        ],
                      ),
                    ),
                    h3,
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
                          h1,
                          Text(
                            getTranslated(context, "pay_in") ?? "",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp),
                          ),
                          h3,
                          Column(children: [
                            payIn(
                              provider,
                              "full_pay",
                              0,
                              grandTotal.toStringAsFixed(2),
                            ),
                            payIn(provider, "deposit_of_25", 1,
                                (grandTotal * (25 / 100)).toStringAsFixed(2)),
                          ])
                        ],
                      ),
                    ),
                    h3,
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
                          h1,
                          Text(
                            getTranslated(context, "split_payment") ?? "",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp),
                          ),
                          h3,
                          Column(
                            children: [
                              splitPaymentRadio("yes", 0),
                              splitPaymentRadio("no", 1),
                            ],
                          )
                        ],
                      ),
                    ),
                    h3,
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
                          h1,
                          Text(
                            getTranslated(context, "cancellation_policy") ?? "",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp),
                          ),
                          h1P5,
                          Text(
                            getTranslated(context,
                                    "this_reservation_is_non_refundable") ??
                                "",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteDull,
                                fontSize: 14.5.sp,
                                height: 1.25),
                          ),
                          h2,
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RulesRegulations.route, arguments: {
                                "appBarTitle": settingsVm.allContent
                                        .where((element) =>
                                            element.type ==
                                            AppContentType
                                                .cancellationPolicy.index)
                                        .first
                                        .title ??
                                    "",
                                "title": "",
                                "desc": settingsVm.allContent
                                        .where((element) =>
                                            element.type ==
                                            AppContentType
                                                .cancellationPolicy.index)
                                        .first
                                        .content ??
                                    "",
                                "textStyle": R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 14.sp)
                              });
                            },
                            child: Text(
                              getTranslated(context, "cancellation_policy") ??
                                  "",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.themeMud,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    ),
                    h3,
                    Text(
                      getTranslated(context, "by_selection_the_button_below") ??
                          "",
                      style: R.textStyle.helvetica().copyWith(
                            color: R.colors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                    ),
                    h1,
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text:
                              "${getTranslated(context, "hosts_yacht_rules")}",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.yellowDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              decoration: TextDecoration.underline,
                              height: 1.4),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(RulesRegulations.route, arguments: {
                                "title":
                                    charter?.yachtRules?.title ?? "Not Added",
                                "desc": charter?.yachtRules?.description ??
                                    "Not Added",
                                "appBarTitle":
                                    "${getTranslated(context, "hosts_yacht_rules")}",
                                "textStyle": R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 13.sp)
                              });
                            },
                        ),
                        TextSpan(
                          text: ", ${getTranslated(context, "and")} ",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              height: 1.4),
                        ),
                        TextSpan(
                          text: getTranslated(context,
                                  "yacht_masters_health_and_safety_requirements") ??
                              "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.yellowDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              decoration: TextDecoration.underline,
                              height: 1.4),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(RulesRegulations.route, arguments: {
                                "title":
                                    charter?.healthSafety?.title ?? "Not Added",
                                "desc": charter?.healthSafety?.description ??
                                    "Not Added",
                                "appBarTitle": getTranslated(context,
                                        "yacht_masters_health_and_safety_requirements") ??
                                    "",
                                "textStyle": R.textStyle.helvetica().copyWith(
                                    color: R.colors.whiteDull, fontSize: 13.sp)
                              });
                            },
                        ),
                        TextSpan(
                          text: ".",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                              height: 1.4),
                        ),
                      ]),
                    ),
                    h5,
                    GestureDetector(
                      onTap: () async {
                        Get.bottomSheet(
                            AgreementBottomSheet(
                              isBooking: true,
                              yesCallBack: () async {
                                await db
                                    .collection("users")
                                    .doc(appwrite.user.$id)
                                    .collection("agreements")
                                    .add(charter!.toJson());
                                startLoader();
                                await provider.onClickCharterConfirmPay(
                                    grandTotal, price, isSplit, charter, tip!);
                                stopLoader();
                              },
                            ),
                            barrierColor: R.colors.grey.withOpacity(.20));
                      },
                      child: Container(
                        height: Get.height * .065,
                        width: Get.width * .8,
                        decoration: AppDecorations.gradientButton(radius: 30),
                        child: Center(
                          child: Text(
                            "${getTranslated(context, "confirm_&_pay")?.toUpperCase()}",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    h4,
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget splitPaymentRadio(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isSplit = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(bottom: Get.height * .017),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  padding: EdgeInsets.all(2),
                  child: Container(
                    height: 13,
                    width: 13,
                    decoration: BoxDecoration(
                        color: isSplit == index
                            ? R.colors.whiteColor
                            : Colors.transparent,
                        shape: BoxShape.circle),
                  ),
                ),
                w3,
                Text(
                  getTranslated(context, title) ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget payIn(BookingsVm provider, String title, int index, String price) {
    return GestureDetector(
      onTap: () {
        setState(() {
          provider.selectedPayIn = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(bottom: Get.height * .017),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white)),
                  padding: EdgeInsets.all(2),
                  child: Container(
                    height: 13,
                    width: 13,
                    decoration: BoxDecoration(
                        color: provider.selectedPayIn == index
                            ? R.colors.whiteColor
                            : Colors.transparent,
                        shape: BoxShape.circle),
                  ),
                ),
                w3,
                Text(
                  getTranslated(context, title) ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: R.colors.whiteColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "\$ ${price}",
              style: R.textStyle.helvetica().copyWith(
                  color: R.colors.whiteColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget tiles(Function() callBack, String title, String subTitle,
      {bool isDivider = true}) {
    return GestureDetector(
      onTap: callBack,
      child: Column(
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
                    h2,
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
                Image.asset(
                  R.images.edit,
                  height: Get.height * .017,
                )
              ],
            ),
          ),
          if (isDivider == false)
            SizedBox()
          else
            Container(
              margin: EdgeInsets.only(top: Get.height * .01),
              width: Get.width,
              child: Divider(
                color: R.colors.grey.withOpacity(.30),
                thickness: 2,
              ),
            )
        ],
      ),
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
