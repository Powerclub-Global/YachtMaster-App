// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:developer';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:yacht_master/appwrite.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/inbox/model/chat_heads_model.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/model/review_model.dart';
import 'package:yacht_master/src/base/profile/view/host_profile.dart';
import 'package:yacht_master/src/base/profile/view/host_profile_others.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/charters_day_model.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/time_slot_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/payments_methods.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/tip_payment_methods.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/search_see_all.dart';
import 'package:yacht_master/src/base/search/view/see_all_host.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/widgets/charter_widget.dart';
import 'package:yacht_master/src/base/search/widgets/host_widget.dart';
import 'package:yacht_master/src/base/search/view/where_going.dart';
import 'package:yacht_master/src/base/search/widgets/yacht_widget.dart';
import 'package:yacht_master/src/base/settings/view_model/settings_vm.dart';
import 'package:yacht_master/src/base/settings/widgets/feedback_bottomsheet.dart';
import 'package:yacht_master/src/base/yacht/view/charter_detail.dart';
import 'package:yacht_master/src/base/yacht/view/rules_regulations.dart';
import 'package:yacht_master/src/base/yacht/view/service_detail.dart';
import 'package:yacht_master/src/base/yacht/view/yacht_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';

import '../../../../utils/zbot_toast.dart';
import '../../settings/view/become_a_host.dart';

class SearchScreen extends StatefulWidget {
  static String route = "/searchScreen";
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchCon = TextEditingController();
  TextEditingController locationCon = TextEditingController();
  TextEditingController startDateCon = TextEditingController();
  TextEditingController endDateCon = TextEditingController();
  TextEditingController cityCon = TextEditingController();
  TextEditingController startTimeCon = TextEditingController();
  FocusNode startTimeFn = FocusNode();
  TextEditingController endTimeCon = TextEditingController();
  FocusNode endTimeFn = FocusNode();
  List<CharterModel> featuredCharters = [];
  String? picLink;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var searchVm = Provider.of<SearchVm>(context, listen: false);
    var bookingVm = Provider.of<BookingsVm>(context, listen: false);
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    var yachtVm = Provider.of<YachtVm>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {});
      yachtVm.allCharters
          .where((element) =>
              homeVm.allBookings
                  .where(
                      (bookin) => bookin.charterFleetDetail?.id == element.id)
                  .toList()
                  .length ==
              10)
          .toList();
      searchVm.adultsCount = 0;
      searchVm.childrenCount = 0;
      searchVm.infantsCount = 0;
      searchVm.petsCount = 0;
      bookingVm.totalMembersCount = 0;
      searchVm.notifyListeners();
      var pendingReviews = await FbCollections.bookings.get();
      List<BookingsModel> pendingReviewsList = pendingReviews.docs
          .map((e) => BookingsModel.fromJson(e.data() as Map<String, dynamic>))
          .toList()
          .where((element) =>
              element.createdBy == appwrite.user.$id &&
              element.bookingStatus == BookingStatus.completed.index &&
              element.paymentDetail?.paymentStatus ==
                  PaymentStatus.giveRating.index)
          .toList();
      log("LENGTH OF THE REVIEWS : ${pendingReviewsList.length}");
      if (pendingReviewsList.isNotEmpty) {
        SplitPaymentModel? firstSlpliter;
        BookingsModel bookingsModel = pendingReviewsList.first;
        Get.bottomSheet(
          FeedbackSheet(
            bookingsModel: bookingsModel,
            submitCallBack: (
              rat,
              desc,
              tipAmount,
            ) async {
              log("____________RATING:${rat}____:${desc}____${bookingsModel?.id}");
              firstSlpliter?.paymentStatus = PaymentStatus.ratingDone.index;
              if (bookingsModel?.paymentDetail?.splitPayment?.every((element) =>
                      element.paymentStatus ==
                      PaymentStatus.ratingDone.index) ==
                  true) {
                bookingsModel?.paymentDetail?.paymentStatus =
                    PaymentStatus.ratingDone.index;
              }
              setState(() {});
              String docId = Timestamp.now().millisecondsSinceEpoch.toString();
              ReviewModel reviewModel = ReviewModel(
                bookingId: bookingsModel?.id,
                userId: appwrite.user.$id,
                rating: rat,
                description: desc,
                createdAt: Timestamp.now(),
                charterFleetDetail: CharterFleetDetail(
                    id: bookingsModel?.charterFleetDetail?.id,
                    location: bookingsModel?.charterFleetDetail?.location,
                    name: bookingsModel?.charterFleetDetail?.name,
                    image: bookingsModel?.charterFleetDetail?.image),
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
                  "Success", "Submitted successfully", R.colors.themeMud);
              if (tipAmount > 1.0) {
                Get.toNamed(PaymentMethods.route, arguments: {
                  "isDeposit": bookingsModel.paymentDetail?.payInType ==
                          PayType.fullPay.index
                      ? false
                      : true,
                  "bookingsModel": bookingsModel,
                  "isCompletePayment": true,
                  "isTip": true,
                  "userPaidAmount": tipAmount,
                });
              }
            },
          ),
          isScrollControlled: true,
        );
      }
    });
    searchVm.selectedCharterDayType = searchVm.charterDayList[0];
  }

  @override
  Widget build(BuildContext context) {
    final Size windowSize = MediaQueryData.fromView(View.of(context)).size;
    return Consumer5<HomeVm, SettingsVm, YachtVm, SearchVm, BookingsVm>(builder:
        (context, homeVm, settingsVm, yachtVm, provider, bookingVm, _) {
      log("LEN:${yachtVm.allHosts.length}");
      return SafeArea(
        child: Scaffold(
          backgroundColor: R.colors.black,
          body: SingleChildScrollView(
            child: Column(
              children: [
                h1,
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: R.colors.blackDull),
                  margin: EdgeInsets.symmetric(
                    horizontal: Get.width * .03,
                  ),
                  child: TextFormField(
                    controller: searchCon,
                    onTap: () {
                      Get.toNamed(WhereGoing.route);
                    },
                    cursorColor: Colors.white,
                    readOnly: true,
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: R.colors.whiteColor, fontSize: 16.sp),
                    decoration: InputDecoration(
                        prefixIcon: Image.asset(
                          R.images.search,
                          scale: 7,
                        ),
                        hintText: "${getTranslated(context, "search")}...",
                        hintStyle: R.textStyle.helvetica().copyWith(
                            color: R.colors.lightGrey,
                            fontSize: 13.sp,
                            height: 1.4),
                        border: InputBorder.none),
                  ),
                ),
                h2,
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: R.colors.blackDull),
                  child: Form(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                        colors: [
                                      Colors.transparent,
                                      R.colors.black.withOpacity(.30),
                                      R.colors.black.withOpacity(.70),
                                    ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)
                                    .createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      topLeft: Radius.circular(16)),
                                  child: AspectRatio(
                                      aspectRatio: 810 / 293,
                                      child: Image.asset(
                                          'assets/images/search_back.png'))),
                            ),
                            Text(
                              getTranslated(context, "book_your_yacht") ?? "",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: Colors.white, fontSize: 15.sp),
                            ),
                            SizedBox(
                                width: Get.width,
                                child: Divider(
                                  color: R.colors.grey.withOpacity(.70),
                                  height: 0,
                                ))
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Get.width * .03,
                              vertical: Get.height * .02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  right: Get.width * .03,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    PopupMenuButton(
                                      offset: Offset(windowSize.width / 5, 20),
                                      elevation: 2,
                                      color: R.colors.black,
                                      itemBuilder: (BuildContext context) =>
                                          provider.charterDayList
                                              .map((e) => PopupMenuItem(
                                                    value: provider
                                                        .charterDayList
                                                        .indexOf(e),
                                                    child: Text(
                                                      "${e.title.split("C").first}",
                                                      style: R.textStyle
                                                          .helveticaBold()
                                                          .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 11.sp,
                                                              height: 1.2),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ))
                                              .toList(),
                                      onSelected: (int index) {
                                        log("______________INDEX:${index}");
                                        provider.selectedCharterDayType =
                                            provider.charterDayList[index];
                                        provider.update();
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            R.images.repeat,
                                            height: Get.height * .017,
                                          ),
                                          w2,
                                          Text(
                                            "${provider.selectedCharterDayType!.title.split("C").first}",
                                            style: R.textStyle
                                                .helveticaBold()
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 11.sp,
                                                    height: 1.2),
                                          ),
                                          w2,
                                          Image.asset(
                                            R.images.dropDown,
                                            height: Get.height * .006,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      offset: Offset(windowSize.width / 5, 20),
                                      elevation: 2,
                                      color: R.colors.black,
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry>[
                                        PopupMenuItem(
                                          value: 0,
                                          child: tiles(
                                              "adults", "ages_13_or_above", 0),
                                        ),
                                        PopupMenuItem(
                                          value: 1,
                                          child: tiles(
                                              "children", "ages_2_to_12", 1),
                                        ),
                                        PopupMenuItem(
                                          value: 2,
                                          child: tiles("infants", "under_2", 2),
                                        ),
                                        PopupMenuItem(
                                          value: 3,
                                          child: tiles("pets", "policy", 3,
                                              isUrl: false),
                                        ),
                                        PopupMenuItem(
                                            value: -1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    "${getTranslated(context, "cancel")}",
                                                    style: R.textStyle
                                                        .helvetica()
                                                        .copyWith(
                                                            color: R.colors
                                                                .whiteDull,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                                w7,
                                                GestureDetector(
                                                  onTap: () {
                                                    bookingVm
                                                            .totalMembersCount =
                                                        provider.adultsCount +
                                                            provider
                                                                .childrenCount +
                                                            provider
                                                                .infantsCount +
                                                            provider.petsCount;
                                                    provider.update();
                                                    if (bookingVm
                                                            .totalMembersCount ==
                                                        0) {
                                                      Helper.inSnackBar(
                                                          "Error",
                                                          "Please select members",
                                                          R.colors.themeMud);
                                                    } else {
                                                      Get.back();
                                                    }
                                                  },
                                                  child: Text(
                                                    "${getTranslated(context, "done").toString().capitalize}",
                                                    style: R.textStyle
                                                        .helvetica()
                                                        .copyWith(
                                                            color: R.colors
                                                                .themeMud,
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                      onSelected: (index) {},
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                            R.images.peopleFill,
                                            height: Get.height * .017,
                                          ),
                                          w2,
                                          Text(
                                            "${bookingVm.totalMembersCount}",
                                            style: R.textStyle
                                                .helveticaBold()
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 11.sp,
                                                    height: 1.2),
                                          ),
                                          w2,
                                          Image.asset(
                                            R.images.dropDown,
                                            height: Get.height * .006,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              h2,
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: R.colors.blackLight),
                                child: TextFormField(
                                  cursorColor: Colors.white,
                                  controller: cityCon,
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 11.sp),
                                  decoration: AppDecorations.greyTextField(
                                      "city",
                                      prefixIcon: Container(
                                          height: 11,
                                          width: 11,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: R.colors.whiteDull),
                                              shape: BoxShape.circle,
                                              color: Colors.transparent),
                                          padding: EdgeInsets.all(1.5),
                                          child: Container(
                                            height: 9,
                                            width: 9,
                                            decoration: BoxDecoration(
                                                color: R.colors.whiteDull,
                                                shape: BoxShape.circle),
                                          ))),
                                ),
                              ),
                              h1,
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: R.colors.blackLight),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        readOnly: true,
                                        cursorColor: Colors.white,
                                        controller: startDateCon,
                                        style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.whiteColor,
                                            fontSize: 11.sp),
                                        decoration:
                                            AppDecorations.greyTextField(
                                                "start_date",
                                                prefixIcon: Image.asset(
                                                    R.images.fillCal)),
                                        onTap: () {
                                          endDateCon.clear();
                                          provider.pickDate(
                                            true,
                                            startDateCon.text.isNotEmpty
                                                ? DateFormat("EEE, MMM dd yyyy")
                                                    .parse(startDateCon.text)
                                                : provider.pickedDate ?? now,
                                            DateTime.now(),
                                            DateTime(2050),
                                            context,
                                            startDateCon,
                                            endDateCon,
                                          );
                                        },
                                      ),
                                    ),
                                    if (provider.selectedCharterDayType!.type !=
                                        CharterDayType.multiDay.index)
                                      SizedBox()
                                    else
                                      Container(
                                        width: 2,
                                        color: R.colors.grey.withOpacity(.40),
                                        height: 20,
                                      ),
                                    if (provider.selectedCharterDayType!.type !=
                                        CharterDayType.multiDay.index)
                                      SizedBox()
                                    else
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          textAlign: TextAlign.center,
                                          cursorColor: Colors.white,
                                          controller: endDateCon,
                                          style: R.textStyle
                                              .helvetica()
                                              .copyWith(
                                                  color: R.colors.whiteColor,
                                                  fontSize: 11.sp),
                                          decoration:
                                              AppDecorations.greyTextField(
                                                  "end_date"),
                                          onTap: () {
                                            provider.pickDate(
                                              false,
                                              endDateCon.text.isEmpty
                                                  ? DateFormat(
                                                          "EEE, MMM dd yyyy")
                                                      .parse(startDateCon.text)
                                                      .add(Duration(days: 1))
                                                  : DateFormat(
                                                          "EEE, MMM dd yyyy")
                                                      .parse(endDateCon.text),
                                              DateFormat("EEE, MMM dd yyyy")
                                                  .parse(startDateCon.text)
                                                  .add(Duration(days: 1)),
                                              DateTime(2050),
                                              context,
                                              startDateCon,
                                              endDateCon,
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              h1,
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: R.colors.blackLight),
                                child: TextFormField(
                                  cursorColor: Colors.white,
                                  focusNode: startTimeFn,
                                  readOnly: true,
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize: 11.sp),
                                  textInputAction: TextInputAction.next,
                                  onTap: () {
                                    endTimeCon.clear();
                                    bookingVm.selectTime(
                                      true,
                                      startTimeCon.text.isNotEmpty
                                          ? DateFormat.jm()
                                              .parse(startTimeCon.text)
                                          : bookingVm.time,
                                      startTimeCon,
                                      endTimeCon,
                                    );
                                  },
                                  controller: startTimeCon,
                                  validator: (val) =>
                                      FieldValidator.validateEmpty(val ?? ""),
                                  decoration:
                                      AppDecorations.greyTextField("start_time",
                                          prefixIcon: Icon(
                                            Icons.timelapse,
                                            color: R.colors.whiteDull,
                                            size: 13,
                                          )),
                                ),
                              ),
                              h2,
                              Center(
                                child: GestureDetector(
                                  onTap: () async {
                                    if (provider.selectedCharterDayType ==
                                        null) {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Please select charter type",
                                          R.colors.themeMud);
                                    } else if (bookingVm.totalMembersCount ==
                                        0) {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Please select guests count",
                                          R.colors.themeMud);
                                    } else if (cityCon.text.isEmpty) {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Please enter city name",
                                          R.colors.themeMud);
                                    } else if (provider
                                                .selectedCharterDayType!.type !=
                                            CharterDayType.multiDay.index &&
                                        startDateCon.text.isEmpty) {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Please select start date",
                                          R.colors.themeMud);
                                    } else if (provider
                                                .selectedCharterDayType!.type ==
                                            CharterDayType.multiDay.index &&
                                        startDateCon.text.isEmpty &&
                                        endDateCon.text.isEmpty) {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Please select start and end dates",
                                          R.colors.themeMud);
                                    } else if (startTimeCon.text.isEmpty) {
                                      Helper.inSnackBar(
                                          "Error",
                                          "Please select start time",
                                          R.colors.themeMud);
                                    } else {
                                      var bookingsVm = Provider.of<BookingsVm>(
                                          context,
                                          listen: false);
                                      bookingsVm.bookingsModel = BookingsModel(
                                          schedule:
                                              BookingScheduleModel(dates: []));
                                      provider.selectedCity = cityCon.text;
                                      log("________________START DATE:${provider.startDate}____END:${provider.endDate}");
                                      List<DateTime> days = provider.endDate ==
                                              null
                                          ? [provider.startDate ?? now]
                                          : List.from(provider.startDate
                                                  ?.getDays(
                                                      provider.startDate ?? now,
                                                      provider.endDate!) ??
                                              []);
                                      log("________________DAYS:${days}");
                                      provider.selectedBookingDays =
                                          days.toSet();
                                      log("________________SELECTE DAT:${provider.selectedBookingDays}");
                                      bookingsVm.bookingsModel.totalGuest =
                                          bookingVm.totalMembersCount;
                                      bookingsVm.selectedPaymentMethod = -1;
                                      bookingsVm.bookingsModel.durationType =
                                          provider.selectedCharterDayType?.type;

                                      bookingsVm.bookingsModel.schedule
                                          ?.dates = List.from(provider
                                              .selectedBookingDays
                                              ?.toList()
                                              .map((e) => Timestamp.fromDate(e))
                                              .toList() ??
                                          []);
                                      bookingsVm.update();
                                      bookingsVm.bookingsModel.schedule
                                          ?.startTime = startTimeCon.text;
                                      if (provider
                                              .selectedCharterDayType?.type ==
                                          CharterDayType.halfDay.index) {
                                        DateTime endTime = bookingVm.startTime!
                                            .add(Duration(hours: 4));
                                        endTimeCon.text = DateFormat('hh:mm a')
                                            .format(endTime);
                                        bookingsVm.bookingsModel.schedule
                                            ?.endTime = endTimeCon.text;
                                      } else if (provider
                                              .selectedCharterDayType?.type ==
                                          CharterDayType.fullDay.index) {
                                        DateTime endTime = bookingVm.startTime!
                                            .add(Duration(hours: 8));
                                        endTimeCon.text = DateFormat('hh:mm a')
                                            .format(endTime);
                                        bookingsVm.bookingsModel.schedule
                                            ?.endTime = endTimeCon.text;
                                      }

                                      bookingsVm.update();
                                      Get.toNamed(SearchSeeAll.route,
                                          arguments: {
                                            "isReserve": true,
                                            "index": 0,
                                            "seeAllType": -1
                                          })?.then((value) {
                                        bookingVm.totalMembersCount = 0;
                                        cityCon.clear();
                                        startDateCon.clear();
                                        endDateCon.clear();
                                        startTimeCon.clear();
                                        provider.adultsCount = 0;
                                        provider.childrenCount = 0;
                                        provider.infantsCount = 0;
                                        provider.petsCount = 0;
                                        bookingVm.totalMembersCount = 0;
                                        provider.notifyListeners();
                                        bookingVm.update();
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: Get.height * .053,
                                    width: Get.width * .8,
                                    decoration: AppDecorations.gradientButton(
                                        radius: 30),
                                    child: Center(
                                      child: Text(
                                        "${getTranslated(context, "explore")?.toUpperCase()}",
                                        style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.black,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                h2,
                if (yachtVm.allCharters.isEmpty &&
                    yachtVm.allServicesList.isEmpty &&
                    yachtVm.allHosts.isEmpty &&
                    yachtVm.hostYachts.isEmpty)
                  SizedBox(
                    height: Get.height * .5,
                    child: EmptyScreen(
                      title: "no_result",
                      subtitle: "no_result_has_been_found_yet",
                      img: R.images.emptyResult,
                    ),
                  )
                else
                  Column(
                    children: [
                      if (yachtVm.allCharters.isNotEmpty) ...[
                        GeneralWidgets.seeAllWidget(context, "feat_charters",
                            onTap: () {
                          Get.toNamed(SearchSeeAll.route, arguments: {
                            "isReserve": false,
                            "index": 0,
                            "seeAllType": SeeAllType.charter.index
                          });
                        }),
                        h2,
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  yachtVm.allCharters.length > 3
                                      ? 3
                                      : yachtVm.allCharters.length, (index) {
                                CharterModel charterModel =
                                    yachtVm.allCharters[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        bookingVm.bookingsModel =
                                            BookingsModel();
                                        bookingVm.bookingsModel.durationType =
                                            CharterDayType.halfDay.index;
                                        provider.selectedCharterDayType =
                                            CharterDayModel(
                                                "Half Day Charter",
                                                "4 Hours",
                                                R.images.v2,
                                                CharterDayType.halfDay.index);
                                        bookingVm.totalMembersCount = 0;
                                        provider.adultsCount = 0;
                                        provider.childrenCount = 0;
                                        provider.infantsCount = 0;
                                        provider.petsCount = 0;
                                        provider.selectedBookingTime =
                                            TimeSlotModel("", "");
                                        provider.selectedBookingDays?.clear();
                                        bookingVm.splitList.clear();
                                        provider.update();
                                        bookingVm.update();
                                        Get.toNamed(CharterDetail.route,
                                            arguments: {
                                              "yacht": charterModel,
                                              "isReserve": false,
                                              "index": index,
                                              "isEdit":
                                                  charterModel.createdBy ==
                                                          appwrite.user.$id
                                                      ? true
                                                      : false
                                            });
                                      },
                                      child: CharterWidget(
                                        charter: charterModel,
                                        width: Get.width * .6,
                                        height: Get.height * .17,
                                        isSmall: true,
                                        isShowStar: true,
                                        isFav: yachtVm.userFavouritesList.any(
                                            (element) =>
                                                element.favouriteItemId ==
                                                    charterModel.id &&
                                                element.type ==
                                                    FavouriteType
                                                        .charter.index),
                                        isFavCallBack: () async {
                                          FavouriteModel favModel =
                                              FavouriteModel(
                                                  creaatedAt: Timestamp.now(),
                                                  favouriteItemId:
                                                      charterModel.id,
                                                  id: charterModel.id,
                                                  type: FavouriteType
                                                      .charter.index);
                                          if (yachtVm.userFavouritesList.any(
                                              (element) =>
                                                  element.id ==
                                                  charterModel.id)) {
                                            yachtVm.userFavouritesList
                                                .removeAt(index);
                                            yachtVm.update();
                                            await FbCollections.user
                                                .doc(appwrite.user.$id)
                                                .collection("favourite")
                                                .doc(charterModel.id)
                                                .delete();
                                          } else {
                                            await FbCollections.user
                                                .doc(appwrite.user.$id)
                                                .collection("favourite")
                                                .doc(charterModel.id)
                                                .set(favModel.toJson());
                                          }
                                          provider.update();
                                        },
                                      )),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                      h2,
                      if (yachtVm.allCharters
                          .where((element) => element.location!.city!
                              .toLowerCase()
                              .contains("miami".toLowerCase()))
                          .isNotEmpty) ...[
                        GeneralWidgets.seeAllWidget(context, "miami",
                            onTap: () {
                          Get.toNamed(SearchSeeAll.route, arguments: {
                            "isReserve": false,
                            "index": 0,
                            "seeAllType": SeeAllType.charter.index
                          });
                        }),
                        h2,
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  yachtVm.allCharters
                                              .where((element) => element
                                                  .location!.city!
                                                  .toLowerCase()
                                                  .contains(
                                                      "miami".toLowerCase()))
                                              .length >
                                          3
                                      ? 3
                                      : yachtVm.allCharters
                                          .where((element) => element
                                              .location!.city!
                                              .toLowerCase()
                                              .contains("miami".toLowerCase()))
                                          .length, (index) {
                                CharterModel charterModel = yachtVm.allCharters
                                    .where((element) => element.location!.city!
                                        .toLowerCase()
                                        .contains("miami".toLowerCase()))
                                    .toList()[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        bookingVm.bookingsModel =
                                            BookingsModel();
                                        bookingVm.bookingsModel.durationType =
                                            CharterDayType.halfDay.index;
                                        provider.selectedCharterDayType =
                                            CharterDayModel(
                                                "Half Day Charter",
                                                "4 Hours",
                                                R.images.v2,
                                                CharterDayType.halfDay.index);
                                        bookingVm.totalMembersCount = 0;
                                        provider.adultsCount = 0;
                                        provider.childrenCount = 0;
                                        provider.infantsCount = 0;
                                        provider.petsCount = 0;
                                        provider.selectedBookingTime =
                                            TimeSlotModel("", "");
                                        provider.selectedBookingDays?.clear();
                                        bookingVm.splitList.clear();
                                        provider.update();
                                        bookingVm.update();
                                        Get.toNamed(CharterDetail.route,
                                            arguments: {
                                              "yacht": charterModel,
                                              "isReserve": false,
                                              "index": index,
                                              "isEdit":
                                                  charterModel.createdBy ==
                                                          appwrite.user.$id
                                                      ? true
                                                      : false
                                            });
                                      },
                                      child: CharterWidget(
                                        charter: charterModel,
                                        width: Get.width * .6,
                                        height: Get.height * .17,
                                        isSmall: true,
                                        isShowStar: true,
                                        isFav: yachtVm.userFavouritesList.any(
                                            (element) =>
                                                element.favouriteItemId ==
                                                    charterModel.id &&
                                                element.type ==
                                                    FavouriteType
                                                        .charter.index),
                                        isFavCallBack: () async {
                                          FavouriteModel favModel =
                                              FavouriteModel(
                                                  creaatedAt: Timestamp.now(),
                                                  favouriteItemId:
                                                      charterModel.id,
                                                  id: charterModel.id,
                                                  type: FavouriteType
                                                      .charter.index);
                                          if (yachtVm.userFavouritesList.any(
                                              (element) =>
                                                  element.id ==
                                                  charterModel.id)) {
                                            yachtVm.userFavouritesList
                                                .removeAt(index);
                                            yachtVm.update();
                                            await FbCollections.user
                                                .doc(appwrite.user.$id)
                                                .collection("favourite")
                                                .doc(charterModel.id)
                                                .delete();
                                          } else {
                                            await FbCollections.user
                                                .doc(appwrite.user.$id)
                                                .collection("favourite")
                                                .doc(charterModel.id)
                                                .set(favModel.toJson());
                                          }
                                          provider.update();
                                        },
                                      )),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                      h2,
                      if (yachtVm.allCharters
                          .where((element) => element.location!.city!
                              .toLowerCase()
                              .contains("dubai".toLowerCase()))
                          .isNotEmpty) ...[
                        GeneralWidgets.seeAllWidget(context, "dubai",
                            onTap: () {
                          Get.toNamed(SearchSeeAll.route, arguments: {
                            "isReserve": false,
                            "index": 0,
                            "seeAllType": SeeAllType.charter.index
                          });
                        }),
                        h2,
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  yachtVm.allCharters
                                              .where((element) => element
                                                  .location!.city!
                                                  .toLowerCase()
                                                  .contains(
                                                      "dubai".toLowerCase()))
                                              .length >
                                          3
                                      ? 3
                                      : yachtVm.allCharters
                                          .where((element) => element
                                              .location!.city!
                                              .toLowerCase()
                                              .contains("dubai".toLowerCase()))
                                          .length, (index) {
                                CharterModel charterModel = yachtVm.allCharters
                                    .where((element) => element.location!.city!
                                        .toLowerCase()
                                        .contains("dubai".toLowerCase()))
                                    .toList()[index];
                                return Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                      onTap: () {
                                        bookingVm.bookingsModel =
                                            BookingsModel();
                                        bookingVm.bookingsModel.durationType =
                                            CharterDayType.halfDay.index;
                                        provider.selectedCharterDayType =
                                            CharterDayModel(
                                                "Half Day Charter",
                                                "4 Hours",
                                                R.images.v2,
                                                CharterDayType.halfDay.index);
                                        bookingVm.totalMembersCount = 0;
                                        provider.adultsCount = 0;
                                        provider.childrenCount = 0;
                                        provider.infantsCount = 0;
                                        provider.petsCount = 0;
                                        provider.selectedBookingTime =
                                            TimeSlotModel("", "");
                                        provider.selectedBookingDays?.clear();
                                        bookingVm.splitList.clear();
                                        provider.update();
                                        bookingVm.update();
                                        Get.toNamed(CharterDetail.route,
                                            arguments: {
                                              "yacht": charterModel,
                                              "isReserve": false,
                                              "index": index,
                                              "isEdit":
                                                  charterModel.createdBy ==
                                                          appwrite.user.$id
                                                      ? true
                                                      : false
                                            });
                                      },
                                      child: CharterWidget(
                                        charter: charterModel,
                                        width: Get.width * .6,
                                        height: Get.height * .17,
                                        isSmall: true,
                                        isShowStar: true,
                                        isFav: yachtVm.userFavouritesList.any(
                                            (element) =>
                                                element.favouriteItemId ==
                                                    charterModel.id &&
                                                element.type ==
                                                    FavouriteType
                                                        .charter.index),
                                        isFavCallBack: () async {
                                          FavouriteModel favModel =
                                              FavouriteModel(
                                                  creaatedAt: Timestamp.now(),
                                                  favouriteItemId:
                                                      charterModel.id,
                                                  id: charterModel.id,
                                                  type: FavouriteType
                                                      .charter.index);
                                          if (yachtVm.userFavouritesList.any(
                                              (element) =>
                                                  element.id ==
                                                  charterModel.id)) {
                                            yachtVm.userFavouritesList
                                                .removeAt(index);
                                            yachtVm.update();
                                            await FbCollections.user
                                                .doc(appwrite.user.$id)
                                                .collection("favourite")
                                                .doc(charterModel.id)
                                                .delete();
                                          } else {
                                            await FbCollections.user
                                                .doc(appwrite.user.$id)
                                                .collection("favourite")
                                                .doc(charterModel.id)
                                                .set(favModel.toJson());
                                          }
                                          provider.update();
                                        },
                                      )),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                      h2,

                      // if (yachtVm.allServicesList.isEmpty)
                      //   SizedBox()
                      // else
                      //   Padding(
                      //       padding: EdgeInsets.only(
                      //         left: Get.width * .03,
                      //         right: Get.width * .03,
                      //       ),
                      //       child: SizedBox(
                      //         height: Get.height * .29,
                      //         child: SingleChildScrollView(
                      //           scrollDirection: Axis.horizontal,
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: List.generate(
                      //                 yachtVm.allServicesList.length > 3
                      //                     ? 3
                      //                     : yachtVm.allServicesList.length,
                      //                 (index) {
                      //               ServiceModel service =
                      //                   yachtVm.allServicesList[index];
                      //               return GestureDetector(
                      //                 onTap: () {
                      //                   Get.toNamed(ServiceDetail.route,
                      //                       arguments: {
                      //                         "service": service,
                      //                         "isHostView": service.createdBy ==
                      //                                 FirebaseAuth.instance
                      //                                     .currentUser?.uid
                      //                             ? true
                      //                             : false,
                      //                         "index": index
                      //                       });
                      //                 },
                      //                 child: Padding(
                      //                   padding: EdgeInsets.only(right: 10),
                      //                   child: HostWidget(
                      //                     service: service,
                      //                     width: Get.width * .3,
                      //                     height: Get.height * .2,
                      //                     isShowRating: false,
                      //                     isShowStar: true,
                      //                     isFav: yachtVm.userFavouritesList.any(
                      //                         (element) =>
                      //                             element.favouriteItemId ==
                      //                                 service.id &&
                      //                             element.type ==
                      //                                 FavouriteType
                      //                                     .service.index),
                      //                     isFavCallBack: () async {
                      //                       FavouriteModel favModel =
                      //                           FavouriteModel(
                      //                               creaatedAt: Timestamp.now(),
                      //                               favouriteItemId: service.id,
                      //                               id: service.id,
                      //                               type: FavouriteType
                      //                                   .service.index);
                      //                       if (yachtVm.userFavouritesList.any(
                      //                           (element) =>
                      //                               element.id == service.id)) {
                      //                         yachtVm.userFavouritesList
                      //                             .removeAt(index);
                      //                         yachtVm.update();
                      //                         await FbCollections.user
                      //                             .doc(FirebaseAuth.instance
                      //                                 .currentUser?.uid)
                      //                             .collection("favourite")
                      //                             .doc(service.id)
                      //                             .delete();
                      //                       } else {
                      //                         await FbCollections.user
                      //                             .doc(FirebaseAuth.instance
                      //                                 .currentUser?.uid)
                      //                             .collection("favourite")
                      //                             .doc(service.id)
                      //                             .set(favModel.toJson());
                      //                       }
                      //                       provider.update();
                      //                     },
                      //                   ),
                      //                 ),
                      //               );
                      //             }),
                      //           ),
                      //         ),
                      //       )),
                      // if (yachtVm.allHosts.isNotEmpty) ...[
                      //   h2,
                      //   GeneralWidgets.seeAllWidget(context, "superhosts",
                      //       onTap: () {
                      //     Get.toNamed(
                      //       SeeAllHost.route,
                      //     );
                      //   }),
                      //   h2,
                      //   if (yachtVm.allHosts.isEmpty)
                      //     SizedBox()
                      //   else
                      //     Padding(
                      //       padding: EdgeInsets.symmetric(
                      //         horizontal: Get.width * .03,
                      //       ),
                      //       child: SingleChildScrollView(
                      //         scrollDirection: Axis.horizontal,
                      //         child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: List.generate(
                      //                 yachtVm.allHosts.length > 3
                      //                     ? 3
                      //                     : yachtVm.allHosts.length, (index) {
                      //               UserModel user = yachtVm.allHosts[index];
                      //               return host(
                      //                 user,
                      //                 index,
                      //                 yachtVm.userFavouritesList.any(
                      //                     (element) =>
                      //                         element.favouriteItemId ==
                      //                             user.uid &&
                      //                         element.type ==
                      //                             FavouriteType.host.index),
                      //                 () async {
                      //                   FavouriteModel favModel =
                      //                       FavouriteModel(
                      //                           creaatedAt: Timestamp.now(),
                      //                           favouriteItemId: user.uid,
                      //                           id: user.uid,
                      //                           type: FavouriteType.host.index);
                      //                   if (yachtVm.userFavouritesList.any(
                      //                       (element) =>
                      //                           element.id == user.uid)) {
                      //                     yachtVm.userFavouritesList
                      //                         .removeAt(index);
                      //                     yachtVm.update();
                      //                     await FbCollections.user
                      //                         .doc(FirebaseAuth
                      //                             .instance.currentUser?.uid)
                      //                         .collection("favourite")
                      //                         .doc(user.uid)
                      //                         .delete();
                      //                   } else {
                      //                     await FbCollections.user
                      //                         .doc(FirebaseAuth
                      //                             .instance.currentUser?.uid)
                      //                         .collection("favourite")
                      //                         .doc(user.uid)
                      //                         .set(favModel.toJson());
                      //                   }
                      //                   provider.update();
                      //                 },
                      //               );
                      //             })),
                      //       ),
                      //     ),
                      // ],
                      h2,
                      if (yachtVm.allYachts.isEmpty)
                        SizedBox()
                      else
                        GeneralWidgets.seeAllWidget(context, "yacht_for_sale",
                            onTap: () {
                          Get.toNamed(SearchSeeAll.route, arguments: {
                            "isReserve": false,
                            "index": 3,
                            "seeAllType": SeeAllType.yacht.index
                          });
                        }),
                      h2,
                      if (yachtVm.allYachts.isEmpty)
                        SizedBox()
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                                yachtVm.allYachts.length > 3
                                    ? 3
                                    : yachtVm.allYachts.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  Get.toNamed(YachtDetail.route, arguments: {
                                    "yacht": yachtVm.allYachts[index],
                                    "isEdit":
                                        yachtVm.allYachts[index].createdBy ==
                                                appwrite.user.$id
                                            ? true
                                            : false,
                                    "index": -1
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: YachtWidget(
                                    yacht: yachtVm.allYachts[index],
                                    width: Get.width * .6,
                                    height: Get.height * .17,
                                    isSmall: true,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                h2,
                Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(.20),
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(
                        horizontal: Get.width * .05,
                        vertical: Get.height * .03),
                    margin: EdgeInsets.symmetric(horizontal: Get.width * .05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: Get.width * .5,
                          child: Text(
                            getTranslated(
                                    context, "have_questions_about_hosting") ??
                                "",
                            style: R.textStyle.helvetica().copyWith(
                                color: Colors.white,
                                fontSize: 18.sp,
                                height: 1.3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        h1,
                        Text(
                          getTranslated(context, "yacht_master") ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.themeMud,
                              fontSize: 18.sp,
                              fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                        h2,
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              AuthVm authVm =
                                  Provider.of(context, listen: false);
                              if (authVm.userModel?.requestStatus ==
                                  RequestStatus.requestHost) {
                                ZBotToast.showToastError(
                                    message:
                                        "Please wait your request to be host in process");
                              } else if (authVm.userModel?.requestStatus ==
                                  RequestStatus.host) {
                                Get.toNamed(HostProfile.route);
                              } else {
                                Get.toNamed(BecomeHost.route);
                              }
                            },
                            child: Container(
                              height: Get.height * .053,
                              width: Get.width * .8,
                              decoration:
                                  AppDecorations.gradientButton(radius: 30),
                              child: Center(
                                child: Text(
                                  getTranslated(
                                          context,
                                          context
                                                      .read<AuthVm>()
                                                      .userModel
                                                      ?.requestStatus ==
                                                  RequestStatus.host
                                              ? "host_profile"
                                              : "become_a_host")
                                      .toString(),
                                  // "${getTranslated(context, "chat_with_super_host")?.toUpperCase()}",
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.black,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                h3,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${getTranslated(context, "support")?.toUpperCase()}",
                              style: R.textStyle.helvetica().copyWith(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3),
                              textAlign: TextAlign.center,
                            ),
                            h1P5,
                            supportWidget(
                                "help_center", "get_support", 5, settingsVm),
                            supportWidget("health_and_safety",
                                "covid_responses", 7, settingsVm),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${getTranslated(context, "policy")?.toUpperCase()}",
                              style: R.textStyle.helvetica().copyWith(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3),
                              textAlign: TextAlign.center,
                            ),
                            h1P5,
                            // supportWidget("giving_back", "how_to_donate_with_us", 6,settingsVm),
                            supportWidget("refund_policy",
                                "how_you_are_protected", 8, settingsVm),
                            supportWidget("cancellation_options",
                                "learn_our_policy", 9, settingsVm),

                            // supportWidget("explore_resources", "tips_and_tricks", 10,settingsVm),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                h7
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget supportWidget(
      String title, String subtitle, int index, SettingsVm settingsVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(RulesRegulations.route, arguments: {
              "appBarTitle": settingsVm.allContent
                      .where((element) => element.type == index)
                      .first
                      .title ??
                  "",
              "title": "",
              "desc": settingsVm.allContent
                      .where((element) => element.type == index)
                      .first
                      .content ??
                  "",
              "textStyle": R.textStyle
                  .helvetica()
                  .copyWith(color: R.colors.whiteDull, fontSize: 14.sp)
            });
          },
          child: Text(
            getTranslated(context, title) ?? "",
            style: R.textStyle
                .helveticaBold()
                .copyWith(color: Colors.white, fontSize: 12.sp, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ),
        h0P5,
        Text(
          getTranslated(context, subtitle) ?? "",
          style: R.textStyle
              .helvetica()
              .copyWith(color: Colors.white, fontSize: 11.sp, height: 1.3),
          textAlign: TextAlign.center,
        ),
        h1,
      ],
    );
  }

  Widget host(UserModel user, int index, bool isFav, Function() isFavCallBack) {
    return GestureDetector(
      onTap: () {
        user.uid == appwrite.user.$id
            ? Get.toNamed(HostProfile.route)
            : Get.toNamed(HostProfileOthers.route, arguments: {"host": user});
      },
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Container(
                  height: Get.height * .2,
                  width: Get.width * .3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: R.colors.whiteColor),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: user.imageUrl == ""
                          ? Image.network(
                              R.images.dummyDp,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              user.imageUrl ?? R.images.dummyDp,
                              fit: BoxFit.cover,
                            )),
                ),
                h1P5,
                Text(
                  user.firstName ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold),
                ),
                h1,
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Padding(
                //       padding: EdgeInsets.only(top: 4, right: 2),
                //       child: Text(
                //         "4.2",
                //         style: R.textStyle.helvetica().copyWith(
                //             color: R.colors.yellowDark,
                //             fontSize: 9.sp,
                //             fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //     Icon(
                //       Icons.star,
                //       color: R.colors.yellowDark,
                //       size: 17,
                //     )
                //   ],
                // ),
              ],
            ),
          ),
          if (user.uid == appwrite.user.$id)
            SizedBox()
          else
            Positioned(
                top: 1,
                right: 3.w,
                child: GestureDetector(
                  onTap: isFavCallBack,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: AppDecorations.favDecoration(),
                    child: Icon(
                        isFav == false ? Icons.star_border_rounded : Icons.star,
                        size: 30,
                        color: isFav == false
                            ? R.colors.whiteColor
                            : R.colors.yellowDark),
                  ),
                ))
        ],
      ),
    );
  }

  Widget tiles(String title, String subTitle, int index, {bool isUrl = true}) {
    return Consumer<SearchVm>(builder: (context, provider, _) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${getTranslated(context, title)}",
                style: R.textStyle
                    .helveticaBold()
                    .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
              ),
              h1,
              GestureDetector(
                onTap: index == 3
                    ? () {
                        Get.toNamed(RulesRegulations.route, arguments: {
                          "appBarTitle": "bringing_a_service_animal",
                          "title": "",
                          "desc": AppDummyData.mediumLongText,
                          "textStyle": R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteDull, fontSize: 13.sp)
                        });
                      }
                    : null,
                child: Text(
                  getTranslated(context, subTitle) ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: isUrl == false
                          ? R.colors.themeMud
                          : R.colors.whiteColor,
                      fontSize: 7.sp,
                      decoration: isUrl == false
                          ? TextDecoration.underline
                          : TextDecoration.none),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  switch (index) {
                    case 0:
                      {
                        if (provider.adultsCount > 0) {
                          provider.adultsCount--;
                        }
                      }
                      break;
                    case 1:
                      {
                        if (provider.childrenCount > 0) {
                          provider.childrenCount--;
                        }
                        break;
                      }

                    case 2:
                      {
                        if (provider.infantsCount > 0) {
                          provider.infantsCount--;
                        }
                        break;
                      }

                    case 3:
                      {
                        if (provider.petsCount > 0) {
                          provider.petsCount--;
                        }
                        break;
                      }
                  }
                  provider.update();
                },
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.remove,
                    size: 15,
                  ),
                ),
              ),
              SizedBox(
                width: Get.width * .1,
                child: Center(
                  child: Text(
                    index == 0
                        ? "${provider.adultsCount}"
                        : index == 1
                            ? "${provider.childrenCount}"
                            : index == 2
                                ? "${provider.infantsCount}"
                                : "${provider.petsCount}",
                    style: R.textStyle
                        .helveticaBold()
                        .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  switch (index) {
                    case 0:
                      {
                        if (provider.adultsCount < 50) {
                          provider.adultsCount++;
                        }
                        break;
                      }
                    case 1:
                      {
                        log("____________________________________2");
                        if (provider.childrenCount < 50) {
                          provider.childrenCount++;
                        }
                        break;
                      }

                    case 2:
                      {
                        if (provider.infantsCount < 50) {
                          provider.infantsCount++;
                        }
                        break;
                      }

                    case 3:
                      {
                        if (provider.petsCount < 50) {
                          provider.petsCount++;
                        }
                        break;
                      }
                  }
                  provider.update();
                },
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.add,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Future<ChatHeadModel?> createChatHead(InboxVm chatVm, YachtVm yachtVm) async {
    ChatHeadModel? chatHeadModel;
    List<String> tempSort = [
      appwrite.user.$id ?? "",
      yachtVm.allHosts.first.uid ?? ""
    ];
    tempSort.sort();
    ChatHeadModel chatData = ChatHeadModel(
      createdAt: Timestamp.now(),
      lastMessageTime: Timestamp.now(),
      lastMessage: "",
      createdBy: appwrite.user.$id,
      id: tempSort.join('_'),
      status: 0,
      peerId: yachtVm.allHosts.first.uid ?? "",
      users: tempSort,
    );
    chatHeadModel = await chatVm.createChatHead(chatData);
    setState(() {});
    return chatHeadModel;
  }
}
