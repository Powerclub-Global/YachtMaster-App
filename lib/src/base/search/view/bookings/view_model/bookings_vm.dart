// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/main.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/date_picker_services.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/stripe/stripe_service.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/src/base/base_vm.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/inbox/model/notification_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/charters_day_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/credit_card_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/taxes_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/time_slot_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/payments_methods.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/split_payment.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/yacht_reserve_payment.dart';
import 'package:yacht_master/src/base/search/view/search_see_all.dart';
import 'package:yacht_master/src/base/search/view/when_will_be_there.dart';
import 'package:yacht_master/src/base/search/view/whos_coming.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/settings/model/app_url_model.dart';
import 'package:yacht_master/src/base/yacht/model/split_payment_person_model.dart';
import 'package:yacht_master/src/base/yacht/widgets/congo_bottomSheet.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/zbot_toast.dart';

import '../../../../../../services/notification_service.dart';

class BookingsVm extends ChangeNotifier {
  int selectedTabIndex = 0;
  int selectedUserTab = 0;
  List<SplitPaymentPersonModel> splitList = [];

  ///HOLIDAY
  Set<DateTime>? selectedBookingDays;
  Set<DateTime>? availabilityDays;

  bool isSaveThisCard = false;
  // String cardNum = "";
  int selectedPaymentMethod = -1;
  int totalMembersCount = 0;
  DateTime? start;
  DateTime? end;
  int selectedPayIn = 0;
  BookingsModel bookingsModel = BookingsModel(
      durationType: CharterDayType.halfDay.index,
      schedule: BookingScheduleModel(dates: []));
  CreditCardModel creditCardModel = CreditCardModel();
  DateTime time = DateTime.now();
  DateTime? startTime;
  DateTime? endTime;
  int serviceFee = 0;
  int taxes = 0;
  int tips = 0;
  double referralAmount = 0.0;
  AppUrlModel? appUrlModel;

  List<HalfDaySlots> getDaySlots(List<DateTime> timeList, int increment) {
    int numOfSlots = 0;
    List<HalfDaySlots> resultedSlots = [];
    for (int i = 0; i < timeList.length; i = i + increment) {
      DateTime startPoint = i == 0
          ? timeList[i]
          : timeList[i].add(Duration(minutes: 40 * numOfSlots));
      DateTime endPoint = i == 0
          ? timeList[i].add(Duration(hours: increment))
          : timeList[i]
              .add(Duration(hours: increment, minutes: 40 * numOfSlots));
      String slotStart = DateFormat.jm().format(startPoint);
      String slotEnd = DateFormat.jm().format(endPoint);
      numOfSlots = numOfSlots + 1;
      if (endPoint.difference(timeList.last).inHours <= 0) {
        resultedSlots.add(HalfDaySlots(start: slotStart, end: slotEnd));
      }
    }
    notifyListeners();
    return resultedSlots;
  }

  List<String> payInTypeList = ["Full Pay", "Deposit of 25%"];
  void selectTime(bool isStartTime, DateTime currentTime,
      TextEditingController startCon, TextEditingController endCon) {
    time = DateTime.now();
    DatePicker.showTime12hPicker(
      Get.context!,
      showTitleActions: true,
      currentTime: currentTime,
      locale: LocaleType.en,
      onConfirm: (selectedTime) {
        log(selectedTime.toString());
        time = selectedTime;
        log("+++++++++++++${time.hour}");
        setTimes(time, isStartTime, startCon, endCon);
        notifyListeners();
      },
    );
  }

  setTimes(
    DateTime time,
    bool isStartTime,
    TextEditingController startCon,
    TextEditingController endCon,
  ) {
    if (isStartTime) {
      startTime = time;
      startCon.text = DateFormat('hh:mm a').format(time);
      endCon.clear();
    } else {
      endTime = time;
      log("______________${DateFormat('hh:mm a').format(startTime!)}___${DateFormat('hh:mm a').format(endTime!)}");
      bool isValid = isValidAfter(DateFormat('hh:mm a').format(startTime!),
          DateFormat('hh:mm a').format(endTime!));
      if (isValid == false) {
        endTime = null;
        Helper.inSnackBar("Error", "End Time cannot greater than start time",
            R.colors.themeMud);
      } else {
        endTime = time;
        endCon.text = DateFormat('hh:mm a').format(time);
      }
    }
    notifyListeners();
  }

  Future<void> fetchTaxes() async {
    log("/////////////////////IN FETCH Taxes");
    try {
      TaxesModel? taxesModel;
      QuerySnapshot snapshot = await FbCollections.taxes.get();
      if (snapshot.docs.isNotEmpty) {
        taxesModel = TaxesModel.fromJson(snapshot.docs.first.data());
        serviceFee = taxesModel.serviceFee ?? 0;
        taxes = taxesModel.taxes ?? 0;
        tips = taxesModel.tip ?? 0;
        referralAmount = taxesModel.referralAmount ?? 0.0;
        notifyListeners();
      }
      log("__________TAXES Data ${taxesModel?.taxes}");
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> fetchAppUrls() async {
    log("/////////////////////IN FETCH APP URLS");
    try {
      appUrlModel = null;
      QuerySnapshot snapshot = await FbCollections.settings.get();
      if (snapshot.docs.isNotEmpty) {
        appUrlModel = AppUrlModel.fromJson(snapshot.docs.first.data());
        notifyListeners();
      }
      log("__________APP URL Data ${appUrlModel?.is_enable_permission_dialog}");
    } catch (e) {
      debugPrintStack();
      log(e.toString());
    }
  }

  Future<List<String>?> fetchAllUsers(String charterHost) async {
    log("/////////////////////IN FETCH Users");
    List<String> allUsers = [];
    try {
      QuerySnapshot snapshot = await FbCollections.user
          .where("status", isEqualTo: UserStatus.active.index)
          .where("uid", isNotEqualTo: charterHost)
          .get();
      if (snapshot.docs.isNotEmpty == true) {
        snapshot.docs.forEach((element) {
          UserModel userModel = UserModel.fromJson(element.data());
          allUsers.add(userModel.email ?? "");
        });
        notifyListeners();
      }
      log("YACHT USERS ${allUsers.length}");
      return allUsers;
    } catch (e) {
      debugPrintStack();
      log(e.toString());
      return null;
    }
  }

  onClickBookCharter(
      bool isReserve, CharterModel? charter, BuildContext context) async {
    var provider = Provider.of<SearchVm>(context, listen: false);
    if (isReserve == true) {
      log("_____________CHARTER:${charter?.name}");
      Get.toNamed(WhenWillBeThere.route, arguments: {
        "cityModel": charter?.location?.city,
        "yacht": charter,
        "isReserve": true,
        "isSelectTime": true,
        "bookingsModel": bookingsModel,
      });
      // Get.toNamed(YachtReservePayment.route,
      //     arguments: {"yacht": charter});
    } else {
      bookingsModel = BookingsModel();
      bookingsModel.charterFleetDetail = CharterFleetDetail(
          id: charter?.id,
          location: charter?.location?.adress,
          name: charter?.name,
          image: charter?.images?.first);
      bookingsModel.durationType = provider.selectedCharterDayType?.type;
      provider.selectedCharterDayType = CharterDayModel("Half Day Charter",
          "4 Hours", R.images.v2, CharterDayType.halfDay.index);
      provider.update();
      provider.update();
      DocumentSnapshot? charterDoc;
      try {
        charterDoc = await FbCollections.charterFleet
            .doc(bookingsModel.charterFleetDetail?.id)
            .get();
      } on Exception catch (e) {
        // TODO
        debugPrintStack();
        log(e.toString());
      }
      CharterModel charterFromDb = CharterModel.fromJson(charterDoc?.data());
      Get.toNamed(WhenWillBeThere.route, arguments: {
        "yacht": charterFromDb,
        "isReserve": isReserve,
        "isSelectTime": false,
        "bookingsModel": null,
        "cityModel": "",
      });
    }
  }

  TimeOfDay convertToTimOfDay(String givenTime) {
    String splitHr = givenTime.substring(0, 2);
    String splitMin = givenTime.substring(3, 5);
    String splitAmPm = givenTime.substring(5);
    log("____________H:${splitHr}_____M:${splitMin}____AMPM:$splitAmPm");
    TimeOfDay resultedTime;
    if (splitAmPm.removeAllWhitespace == "AM") {
      //am case
      if (splitHr == "12") {
        //if 12AM then time is 00
        resultedTime = TimeOfDay(hour: 0, minute: int.parse(splitMin));
      } else {
        resultedTime =
            TimeOfDay(hour: int.parse(splitHr), minute: int.parse(splitMin));
      }
    } else {
      //pm case
      if (splitHr == "12") {
//if 12PM means as it is available
        resultedTime =
            TimeOfDay(hour: int.parse(splitHr), minute: int.parse(splitMin));
      } else {
//add +12 to conv time to 24hr format
        resultedTime = TimeOfDay(
            hour: int.parse(splitHr) + 12, minute: int.parse(splitMin));
      }
    }
    return resultedTime;
  }

  bool isValidBetween(String openTime, String closedTime, String selected) {
    log("___________OPEN :${openTime}_____CLOSE:${closedTime}_____SELECTED:$selected");
    TimeOfDay openTimeOfDay = convertToTimOfDay(openTime);
    TimeOfDay endTimeOfDay = convertToTimOfDay(closedTime);
    TimeOfDay selectedTimeOfDay = convertToTimOfDay(selected);
    int nowInMinutes = selectedTimeOfDay.hour * 60 + selectedTimeOfDay.minute;
    int openTimeInMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
    int closeTimeInMinutes = endTimeOfDay.hour * 60 + endTimeOfDay.minute;
    log("__________OPEN:${openTimeInMinutes}____CLOSE:${closeTimeInMinutes}_____selece:$nowInMinutes");
    //handling day change ie pm to am
    if ((closeTimeInMinutes - openTimeInMinutes) < 0) {
      log("_____-IN WRONG TIME");
      closeTimeInMinutes = closeTimeInMinutes + 1440;
      if (nowInMinutes >= 0 && nowInMinutes < openTimeInMinutes) {
        nowInMinutes = nowInMinutes + 1440;
      }
      if (openTimeInMinutes <= nowInMinutes &&
          nowInMinutes <= closeTimeInMinutes) {
        return true;
      }
    } else if (openTimeInMinutes <= nowInMinutes &&
        nowInMinutes <= closeTimeInMinutes) {
      log("_____-IN CORRECT TIME");
      return true;
    }

    return false;
  }

  bool isValidAfter(String openTime, String selected) {
    log("___________OPEN :${openTime}_______SELECTED:$selected");
    TimeOfDay openTimeOfDay = convertToTimOfDay(openTime);
    TimeOfDay selectedTimeOfDay = convertToTimOfDay(selected);
    log("__________________CONV OPN:${openTimeOfDay}_____$selectedTimeOfDay");
    int nowInMinutes = selectedTimeOfDay.hour * 60 + selectedTimeOfDay.minute;
    int openTimeInMinutes = openTimeOfDay.hour * 60 + openTimeOfDay.minute;
    log("__________OPEN:${openTimeInMinutes}______$nowInMinutes");
    if (openTimeInMinutes <= nowInMinutes) {
      log("_____-IN CORRECT TIME");
      return true;
    }
    return false;
  }

  onClickWhenWillBeThere(
      String city,
      CharterModel? charter,
      bool isSelectTime,
      bool isReserve,
      BookingsModel? bookingModel,
      TextEditingController startTimeCon,
      TextEditingController endTimeCon,
      BuildContext context) {
    var provider = Provider.of<SearchVm>(context, listen: false);
    log("________${charter?.name ?? ""}___is reserve:${isReserve}___isSelectTime:$isSelectTime");

    if (isReserve == true && isSelectTime == false) {
      log("____________IF ISRESERVE TRUE");
      if (provider.selectedBookingDays?.isEmpty == true ||
          provider.selectedBookingDays == null) {
        Helper.inSnackBar("Error", "Please select date", R.colors.themeMud);
      } else {
        bookingsModel.schedule = BookingScheduleModel(dates: []);
        selectedPaymentMethod = -1;
        bookingsModel.durationType = provider.selectedCharterDayType?.type;
        bookingsModel.schedule?.dates = [
          Timestamp.fromDate(DateTimePickerServices.selectedStartDateTimeDB),
          Timestamp.fromDate(DateTimePickerServices.selectedEndDateTimeDB),
        ];
        bookingsModel.schedule?.startTime = startTimeCon.text;
        startTime = DateTime.parse(startTimeCon.text);
        log(startTime.toString());
        if (provider.selectedCharterDayType?.type ==
            CharterDayType.halfDay.index) {
          //log(startTimeCon);
          DateTime endTime = startTime!.add(Duration(hours: 4));
          endTimeCon.text = DateFormat('hh:mm a').format(endTime);
          bookingsModel.schedule?.endTime = endTimeCon.text;
        } else if (provider.selectedCharterDayType?.type ==
            CharterDayType.fullDay.index) {
          DateTime endTime = startTime!.add(Duration(hours: 8));
          endTimeCon.text = DateFormat('hh:mm a').format(endTime);
          bookingsModel.schedule?.endTime = endTimeCon.text;
        }
        update();
        log("____________FILTER BOOKING DATES:${bookingsModel.schedule?.dates?.length}");
        Get.toNamed(WhosComing.route, arguments: {
          "cityModel": city,
          "charter": charter,
          "isReserve": isReserve,
          "bookingsModel": null,
          "isEdit": false
        });
      }
      update();
      provider.update();
    } else {
      if (provider.selectedBookingDays?.isEmpty == true ||
          provider.selectedBookingDays == null) {
        Helper.inSnackBar("Error", "Please select date", R.colors.themeMud);
      } /*else if (provider.selectedCharterDayType?.type == CharterDayType.multiDay.index &&
          provider.selectedBookingDays?.length == 1) {
        Helper.inSnackBar("Error", "Please select multiple days for multi day charter", R.colors.themeMud);
      } */
      else if ((provider.selectedCharterDayType?.type ==
                  CharterDayType.halfDay.index ||
              provider.selectedCharterDayType?.type ==
                  CharterDayType.fullDay.index) &&
          provider.selectedBookingTime == "") {
        Helper.inSnackBar("Error", "Please select time", R.colors.themeMud);
      } else if ((provider.selectedCharterDayType?.type ==
              CharterDayType.multiDay.index) &&
          startTimeCon.text.isEmpty &&
          endTimeCon.text.isEmpty) {
        Helper.inSnackBar(
            "Error", "Please select start and end time", R.colors.themeMud);
      } else {
        bookingsModel.schedule = BookingScheduleModel(dates: []);
        selectedPaymentMethod = -1;
        bookingsModel.durationType = provider.selectedCharterDayType?.type;
        // bookingsModel.multiDays=provider.selectedBookingDays?.length;
        // provider.selectedBookingDays?.forEach((element) {
        //   bookingsModel.schedule?.dates?.add(Timestamp.fromDate(element));
        // });
        bookingsModel.schedule?.dates = [
          Timestamp.fromDate(DateTimePickerServices.selectedStartDateTimeDB),
          Timestamp.fromDate(DateTimePickerServices.selectedEndDateTimeDB),
        ];
        update();
        log("____________END DATE:${bookingsModel.schedule?.dates?.length}");
        print("STAGE 2 ${startTimeCon.text}");
        provider.selectedBookingTime = TimeSlotModel(
            DateFormat("hh:mm a")
                .format(DateTimePickerServices.selectedStartDateTimeDB),
            DateFormat("hh:mm a")
                .format(DateTimePickerServices.selectedEndDateTimeDB));
        print("STAGE 3 ${provider.selectedBookingTime?.startTime}");
        bookingsModel.schedule?.startTime =
            provider.selectedBookingTime?.startTime ?? "";
        bookingsModel.schedule?.endTime =
            provider.selectedBookingTime?.endTime ?? "";
        // }
        update();
        log("/////////////////BOOKING STARET:${provider.selectedBookingTime?.startTime}:  _${provider.selectedBookingTime?.endTime}");
        bool isNotAvailable = false;
        if (bookingsModel.durationType != CharterDayType.multiDay.index) {
          isNotAvailable = checkSlotAvailability(
              bookingsModel.schedule?.dates?.first.toDate() ?? now,
              (provider.selectedBookingTime?.startTime ?? "").formateHM(),
              (provider.selectedBookingTime?.endTime ?? "").formateHM(),
              context);
        }
        if ((bookingsModel.durationType ==
                CharterDayType.multiDay
                    .index /*&&
                isValidBetween(charter?.availability?.startTime ?? "", charter?.availability?.endTime ?? "",
                    bookingsModel.schedule?.startTime ?? "") &&
                isValidBetween(charter?.availability?.startTime ?? "", charter?.availability?.endTime ?? "",
                    bookingsModel.schedule?.endTime ?? "") */
            ) ||
            (bookingsModel.durationType ==
                CharterDayType.halfDay
                    .index /*&&
                isNotAvailable == false  &&
                charter?.availability?.halfDaySlots?.any((element) =>
                        (element.start ?? "").formateHM() ==
                            (provider.selectedBookingTime?.startTime ?? "").formateHM() &&
                        (element.end ?? "").formateHM() == (provider.selectedBookingTime?.endTime ?? "").formateHM()) ==
                    true */
            ) ||
            (bookingsModel.durationType ==
                CharterDayType.fullDay
                    .index /* &&
                isNotAvailable == false  &&
                charter?.availability?.fullDaySlots?.any((element) =>
                        (element.start ?? "").formateHM() ==
                            (provider.selectedBookingTime?.startTime ?? "").formateHM() &&
                        (element.end ?? "").formateHM() == (provider.selectedBookingTime?.endTime ?? "").formateHM()) ==
                    true */
            )) {
          if (isSelectTime == true) {
            Get.toNamed(YachtReservePayment.route,
                arguments: {"yacht": charter});
          } else if (bookingModel != null && isSelectTime == false) {
            Get.back();
          } else {
            isSelectTime == true
                ? Get.toNamed(YachtReservePayment.route,
                    arguments: {"yacht": charter})
                : Get.toNamed(WhosComing.route, arguments: {
                    "cityModel": city,
                    "charter": charter,
                    "isReserve": isReserve,
                    "bookingsModel": null,
                    "isEdit": false
                  });
          }
        } else {
          Helper.inSnackBar("Error", "Selected Time slot is not available",
              R.colors.themeMud);
        }
      }
      update();
      provider.update();
    }
  }

  checkSlotAvailability(DateTime selectedDate, String selectedStart,
      String selectedEnd, BuildContext context) {
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    bool isNotAvailable = false;
    homeVm.allBookings.forEach((element) {
      if (DateFormat.yMd()
                  .format(element.schedule?.dates?.first.toDate() ?? now) ==
              DateFormat.yMd().format(selectedDate) &&
          (element.schedule?.startTime ?? "").formateHM() ==
              (selectedStart).formateHM() &&
          (element.schedule?.endTime ?? "").formateHM() ==
              (selectedEnd).formateHM() &&
          element.bookingStatus == BookingStatus.ongoing.index) {
        isNotAvailable = true;
      }
    });
    update();
    return isNotAvailable;
  }

  onClickWhosComing(int guestCap, BookingsModel? bookedModel, bool? isReserve,
      BuildContext context) async {
    var provider = Provider.of<SearchVm>(context, listen: false);
    totalMembersCount =
        provider.adultsCount + provider.childrenCount + provider.infantsCount;
    if (totalMembersCount == 0) {
      Helper.inSnackBar("Error", "Please select members", R.colors.themeMud);
    } else {
      bookingsModel.totalGuest = totalMembersCount;
      update();
      provider.update();
      if (bookedModel == null) {
        log("________GEUST:${bookingsModel.totalGuest}____ISRESERVCE:$isReserve");

        if (isReserve == false) {
          if (guestCap < totalMembersCount) {
            Helper.inSnackBar(
                "Error",
                "Cannot select members more than the charter guest capacity",
                R.colors.themeMud);
          } else {
            DocumentSnapshot charterDoc = await FbCollections.charterFleet
                .doc(bookingsModel.charterFleetDetail?.id)
                .get();
            CharterModel charter = CharterModel.fromJson(charterDoc.data());
            Get.toNamed(YachtReservePayment.route,
                arguments: {"yacht": charter});
          }
        } else {
          Get.toNamed(SearchSeeAll.route, arguments: {
            "isReserve": isReserve,
            "index": 0,
            "seeAllType": -1
          });
        }
      } else {
        Get.back();
      }
    }
    update();
    provider.update();
  }

  onClickCharterConfirmPay(
      double totalPrice, String price, int isSplit, CharterModel? charter) {
    if (selectedPayIn == -1) {
      Helper.inSnackBar("Error", "Please select pay in", R.colors.themeMud);
    } else {
      bookingsModel.priceDetaill = PriceDetaill();
      bookingsModel.paymentDetail = PaymentDetail();
      bookingsModel.paymentDetail?.paymentMethod = -1;
      bookingsModel.priceDetaill?.totalPrice = totalPrice;
      bookingsModel.priceDetaill?.subTotal = double.parse(price);
      bookingsModel.paymentDetail?.payInType = selectedPayIn;
      bookingsModel.paymentDetail?.isSplit = isSplit == 1 ? false : true;
      update();

      if (isSplit == SplitType.yes.index &&
          (bookingsModel.totalGuest ?? 0) <= 1) {
        Helper.inSnackBar(
            "Error",
            "For split payment guests should be more than 1",
            R.colors.themeMud);
      } else if (isSplit == SplitType.yes.index &&
          selectedPayIn == PayType.fullPay.index) {
        Get.toNamed(SplitPayment.route,
            arguments: {"isDeposit": false, "charter": charter});
      } else if (isSplit == SplitType.yes.index &&
          selectedPayIn == PayType.deposit.index) {
        Get.toNamed(SplitPayment.route,
            arguments: {"isDeposit": true, "charter": charter});
      } else {
        log("______${bookingsModel.priceDetaill?.totalPrice}________Payment method:${bookingsModel.paymentDetail?.paymentMethod}");

        Get.toNamed(PaymentMethods.route, arguments: {
          "isDeposit": selectedPayIn == PayType.fullPay.index ? false : true,
          "bookingsModel": bookingsModel,
          "isCompletePayment": false
        });
      }
    }
  }

  onClickPaymentMethods(
      String? screenShotUrl,
      BuildContext context,
      bool? isCompletePayment,
      double splitAmount,
      double userPaidAmount) async {
    bookingsModel.paymentDetail?.paymentMethod = selectedPaymentMethod;
    if (bookingsModel.paymentDetail?.paymentMethod == -1) {
      Helper.inSnackBar(
          "Error", "Please select payment method", R.colors.themeMud);
    } else {
      double finalPaidAmount = bookingsModel.paymentDetail?.payInType ==
                  PayType.deposit.index &&
              bookingsModel.paymentDetail?.isSplit == true
          ? splitAmount
          : bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                  bookingsModel.paymentDetail?.isSplit == true
              ? splitAmount
              : bookingsModel.paymentDetail?.payInType ==
                          PayType.deposit.index &&
                      bookingsModel.paymentDetail?.isSplit == false
                  ? percentOfAmount(splitAmount, 25)
                  : userPaidAmount;
      bookingsModel.paymentDetail?.paidAmount = finalPaidAmount;
      if (selectedPaymentMethod == PaymentMethodEnum.card.index) {
        await onPayWithCard(screenShotUrl, context, isCompletePayment,
            splitAmount, userPaidAmount, finalPaidAmount);
      } else if (selectedPaymentMethod == PaymentMethodEnum.crypto.index) {
        await onPaymentSuccess(screenShotUrl, context, isCompletePayment,
            splitAmount, userPaidAmount, finalPaidAmount);
      } else if (selectedPaymentMethod == PaymentMethodEnum.appStore.index) {
        await onPaymentSuccess(screenShotUrl, context, isCompletePayment,
            splitAmount, userPaidAmount, finalPaidAmount);
      } else if (selectedPaymentMethod == PaymentMethodEnum.wallet.index) {
        Helper.inSnackBar(
            "Error", "Payment method not available", R.colors.themeMud);
      }
    }
  }

  onPayWithCard(
      String? screenShotUrl,
      BuildContext context,
      bool? isCompletePayment,
      double splitAmount,
      double userPaidAmount,
      double amountToPay) async {
    print("Starting payments now");
    StripeService stripe = StripeService();
    // CardDetails _card = CardDetails(
    //     number: creditCardModel.cardNum,
    //     expirationYear: int.parse(creditCardModel.expiryDate?.split("/")[1] ?? "0"),
    //     expirationMonth: int.parse(creditCardModel.expiryDate?.split("/")[0] ?? "0"),
    //     cvc: creditCardModel.cvc);
    BillingDetails billing = BillingDetails(
      email: context.read<AuthVm>().userModel?.email ?? "",
    );
    ZBotToast.loadingShow();
    try {
      print((amountToPay * 100).toStringAsFixed(0));
      PaymentIntents intents = PaymentIntents();
      await stripe.handlePayPress(
          billingDetails: billing,
          customerID: context.read<AuthVm>().userModel?.stripeCustomerID ?? "",
          userEmail: context.read<AuthVm>().userModel?.email ?? "",
          userName: context.read<AuthVm>().userModel?.firstName ?? "",
          price: (amountToPay * 100).toStringAsFixed(0),
          secretKey: secretKey ?? "",
          isSubscription: false,
          isCardAvailable: false,
          onPaymentSuccess: () async {
            bookingsModel.paymentDetail?.paymentIntents ??= [];
            bookingsModel.paymentDetail?.paymentIntents?.add(intents);
            print("I am here and i am logging success of this payment");
            log("I am here and i am logging success of this payment");
            await onPaymentSuccess(screenShotUrl, context, isCompletePayment,
                splitAmount, userPaidAmount, amountToPay);
          },
          getCustomerID: (customerID) {
            context.read<AuthVm>().userModel?.stripeCustomerID = customerID;
          },
          paymentDetails: (paymentIntent) async {
            intents = PaymentIntents(
                paymentIntentId: paymentIntent.id,
                paymentStatus: paymentIntent.status,
                userId: context.read<AuthVm>().userModel?.uid);
          },
          onError: (error) {
            print("Payment error is thereee and nowwwww lets ");
            print(error);
            ZBotToast.loadingClose();
            ZBotToast.showToastError(message: 'Error: $error');
          });
    } catch (e) {
      ZBotToast.loadingClose();
      if (e.toString().contains("Your card number is incorrect.")) {
        ZBotToast.showToastError(
            message: 'Error: Your card number is incorrect.');
      }
      log("ERROR:$e");

      rethrow;
    }
  }

  onPaymentSuccess(
      String? screenShotUrl,
      BuildContext context,
      bool? isCompletePayment,
      double splitAmount,
      double userPaidAmount,
      double finalPaidAmount) async {
    print("Your payment was success");
    var baseVm = Provider.of<BaseVm>(context, listen: false);
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    var authVm = Provider.of<AuthVm>(context, listen: false);
    var searchVm = Provider.of<SearchVm>(context, listen: false);
    SplitPaymentModel? splitPerson;
    DocumentSnapshot charter = await FbCollections.charterFleet
        .doc(bookingsModel.charterFleetDetail?.id)
        .get();
    if (bookingsModel.paymentDetail?.isSplit == true) {
      splitPerson = bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first;
    }
    if (selectedPaymentMethod == PaymentMethodEnum.card.index) {
      bookingsModel.paymentDetail?.currentUserCardNum = creditCardModel.cardNum;
      splitPerson?.currentUserCardNum = creditCardModel.cardNum;
    }
    creditCardModel = CreditCardModel();
    update();
    String? docID = isCompletePayment == true
        ? bookingsModel.id
        : Timestamp.now().millisecondsSinceEpoch.toString();

    if (isCompletePayment == true) {
      print("Your payment was success less");
      completePaymentFunction(screenShotUrl, context);
    } else {
      bookingsModel.bookingStatus = BookingStatus.ongoing.index;
      bookingsModel.paymentDetail?.cryptoScreenShot = screenShotUrl;
      bookingsModel.paymentDetail?.cryptoReceiverEmail =
          appUrlModel?.adminCryptoEmail ?? "";
      if (bookingsModel.paymentDetail?.isSplit == true) {
        splitPerson?.paymentMethod = selectedPaymentMethod;
        splitPerson?.cryptoReceiverEmail = appUrlModel?.adminCryptoEmail ?? "";
        splitPerson?.cryptoScreenShot = screenShotUrl;
      }
      bookingsModel.createdAt = Timestamp.now();
      bookingsModel.createdBy = FirebaseAuth.instance.currentUser?.uid;
      bookingsModel.paymentDetail
          ?.paymentType = bookingsModel.paymentDetail?.isSplit == false &&
              bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
          ? PaymentType.payInApp.index
          : -1;
      bookingsModel.paymentDetail?.paymentStatus =
          bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                  bookingsModel.paymentDetail?.isSplit == true
              ? PaymentStatus.confirmBooking.index
              : bookingsModel.paymentDetail?.payInType ==
                          PayType.deposit.index &&
                      bookingsModel.paymentDetail?.isSplit == false
                  ? PaymentStatus.payInAppOrCash.index
                  : bookingsModel.paymentDetail?.isSplit == false &&
                          bookingsModel.paymentDetail?.payInType ==
                              PayType.fullPay.index
                      ? PaymentStatus.markAsComplete.index
                      : (bookingsModel.paymentDetail?.isSplit == true &&
                              bookingsModel.paymentDetail?.payInType ==
                                  PayType.fullPay.index)
                          ? PaymentStatus.payInAppOrCash.index
                          : PaymentStatus.confirmBooking.index;
      bookingsModel.paymentDetail?.splitPayment?.first.paymentType =
          bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
              ? PaymentType.payInApp.index
              : -1;
      bookingsModel.paymentDetail?.splitPayment?.first.depositStatus =
          DepositStatus.twentyFivePaid.index;
      bookingsModel.paymentDetail?.splitPayment?.first.remainingDeposit = 0;
      bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount =
          bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                  bookingsModel.paymentDetail?.isSplit == true
              ? 0
              : percentOfAmount(
                  ((bookingsModel.priceDetaill?.totalPrice ?? 0.0) -
                      percentOfAmount(
                          (bookingsModel.priceDetaill?.totalPrice ?? 0.0),
                          double.parse(splitPerson?.percentage ?? "0"))),
                  double.parse(splitPerson?.percentage ?? "0"));
      bookingsModel.paymentDetail?.splitPayment?.first.amount =
          bookingsModel.paymentDetail?.paidAmount;
      bookingsModel.paymentDetail?.splitPayment?.first.paymentStatus =
          bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                  bookingsModel.paymentDetail?.isSplit == true
              ? PaymentStatus.confirmBooking.index
              : PaymentStatus.markAsComplete.index;
      bookingsModel.priceDetaill?.tip = double.parse(tips.toString());
      bookingsModel.hostUserUid = charter.get("created_by");
      bookingsModel.priceDetaill?.serviceFee =
          double.parse(serviceFee.toString());
      bookingsModel.priceDetaill?.taxes = double.parse(taxes.toString());
      bookingsModel.paymentDetail?.remainingAmount =
          (bookingsModel.priceDetaill?.totalPrice ?? 0.0) - finalPaidAmount;
      bookingsModel.id = docID;

      if (bookingsModel.paymentDetail?.isSplit == false) {
        bookingsModel.paymentDetail?.splitPayment = [];
      }
      // homeVm.previousBookings.add(bookingsModel);
      homeVm.update();
    }
    try {
      await authVm.updateUserWallet(authVm.wallet?.amount);
      await FbCollections.user.doc(authVm.userModel!.uid).update({
        "stripe_customer_id": authVm.userModel?.stripeCustomerID ?? "",
        "is_card_saved": isSaveThisCard,
      });
      await FbCollections.bookings.doc(docID).set(bookingsModel.toJson());
      DocumentSnapshot hostDoc =
          await FbCollections.user.doc(charter.get("created_by")).get();
      UserModel hostUser = UserModel.fromJson(hostDoc.data());
      await sendNotificationOnBooking(context, docID!, charter);
      // print(charter.get("images")[0]);
      // print(charter.get("location")["adress"]);
      // print(DateFormat('dd/MM/yyyy').format(bookingsModel.schedule!.dates![0].toDate()));
      // // print(bookingsModel.schedule!.startTime);
      // print(bookingsModel.totalGuest);
      await FbCollections.mail.add({
        "to": [hostUser.email],
        "message": {
          "subject": "Booking Update",
          "text": "Your Booking for ${charter.get("name")} has been confirmed",
          "html": '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fixing Gmail’s dark mode issues with CSS Blend Modes</title>
    <style>
        u + .body .gmail-blend-screen { background:#000; mix-blend-mode:screen; }
        u + .body .gmail-blend-difference { background:#000; mix-blend-mode:difference; }
        p{
          color: #ffffff;
        }
        h5{
          color: #ffffff;
        }
        h1 {
          font-size: 60px;
          border-bottom: 3px solid #ffd700;
          color: #ffffff;
        }
        .bg-complementary {
          background-color: #ffd700;
        }
        body {
          padding: 20px;
          background-color: #000000;
          color: #ffffff;
        }
        .container {
          padding: 20px;
        }
        .golden-container {
          padding: 10px;
          box-sizing: border-box;
          margin-bottom: 20px;
          border: 3px solid #ffd700;
          border-radius: 10px;
          background-color: transparent;
          display: grid;
        }
        .image-container {
          padding: 0;
        }
        .image-container img {
          width: 100%;
          height: auto;
          display: block;
        }
        .text-container {
          padding: 10px;
        }
        .text-container h3 {
          padding-bottom: 1px;
          color: #ffffff;
        }
        h3{
          border-bottom: 2px solid #ffd700;
          width: 35%;
        }
    </style>
</head>
<body class="body">
    <div style="background:#000; color:#fff;">
        <div class="gmail-blend-screen">
            <div class="gmail-blend-difference">
                <html>
                  <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                    
                  </head>
                  <body>
                    <div class="container">
                      <div class="card my-10">
                        <div class="card-body">
                          <h1 class="h3 mb-1">Booking Details</h1>
                          <h5 class="text-teal-700" style="margin-top: 0;">Here are the Details of your latest booking on the YachtMaster App</h5>
                          <div class="space-y-3">
                            <div class="bg-complementary rounded golden-container">
                              <div class="image-container">
                                <img src="${charter.get("images")[0]}" alt="Yacht Image">
                              </div>
                              <div class="text-container" >
                                <h3 class="text-lg font-semibold mb-1">${charter.get("name")}</h3>
                                <p>${charter.get("location")["adress"]}</p>
                              </div>
                            </div>
                            <div class="bg-complementary rounded golden-container">
                              <div class="text-container">
                                <h3 class="text-lg font-semibold mb-1">Renter Details</h3>
                                <p><strong>Name:</strong> ${authVm.userModel!.firstName} ${authVm.userModel!.lastName}</p>
                                <p><strong>Email ID:</strong> ${authVm.userModel!.email}</p>
                                <p><strong>Phone Number:</strong> ${authVm.userModel!.phoneNumber}</p>
                              </div>
                            </div>
                            <div class="bg-complementary rounded golden-container">
                              <div class="text-container">
                                <h3 class="text-lg font-semibold mb-1">Booking Information</h3>
                                <p><strong>Start Date and Time:</strong> ${DateFormat('dd/MM/yyyy').format(bookingsModel.schedule!.dates![0].toDate())} ${bookingsModel.schedule!.startTime}</p>
                                <p><strong>End Date and Time:</strong> ${DateFormat('dd/MM/yyyy').format(bookingsModel.schedule!.dates![1].toDate())} ${bookingsModel.schedule!.endTime}</p>
                                <p><strong>Number of Guests:</strong> ${bookingsModel.totalGuest}</p>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </body>
                </html>
            </div>
        </div>
    </div>
</body>
</html>
''',
        }
      });
      await FbCollections.mail.add({
        "to": [authVm.userModel!.email],
        "message": {
          "subject": "Booking Update",
          "text": "Your Booking for ${charter.get("name")} has been confirmed",
          "html": '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fixing Gmail’s dark mode issues with CSS Blend Modes</title>
    <style>
        u + .body .gmail-blend-screen { background:#000; mix-blend-mode:screen; }
        u + .body .gmail-blend-difference { background:#000; mix-blend-mode:difference; }
        p{
          color: #ffffff;
        }
        h5{
          color: #ffffff;
        }
        h1 {
          font-size: 60px;
          border-bottom: 3px solid #ffd700;
          color: #ffffff;
        }
        .bg-complementary {
          background-color: #ffd700;
        }
        body {
          padding: 20px;
          background-color: #000000;
          color: #ffffff;
        }
        .container {
          padding: 20px;
        }
        .golden-container {
          padding: 10px;
          box-sizing: border-box;
          margin-bottom: 20px;
          border: 3px solid #ffd700;
          border-radius: 10px;
          background-color: transparent;
          display: grid;
        }
        .image-container {
          padding: 0;
        }
        .image-container img {
          width: 100%;
          height: auto;
          display: block;
        }
        .text-container {
          padding: 10px;
        }
        .text-container h3 {
          padding-bottom: 1px;
          color: #ffffff;
        }
        h3{
          border-bottom: 2px solid #ffd700;
          width: 35%;
        }
    </style>
</head>
<body class="body">
    <div style="background:#000; color:#fff;">
        <div class="gmail-blend-screen">
            <div class="gmail-blend-difference">
                <html>
                  <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                    
                  </head>
                  <body>
                    <div class="container">
                      <div class="card my-10">
                        <div class="card-body">
                          <h1 class="h3 mb-1">Booking Details</h1>
                          <h5 class="text-teal-700" style="margin-top: 0;">Here are the Details of your latest booking on the YachtMaster App</h5>
                          <div class="space-y-3">
                            <div class="bg-complementary rounded golden-container">
                              <div class="image-container">
                                <img src="${charter.get("images")[0]}" alt="Yacht Image">
                              </div>
                              <div class="text-container" >
                                <h3 class="text-lg font-semibold mb-1">${charter.get("name")}</h3>
                                <p>${charter.get("location")["adress"]}</p>
                              </div>
                            </div>
                            <div class="bg-complementary rounded golden-container">
                              <div class="text-container">
                                <h3 class="text-lg font-semibold mb-1">Host Details</h3>
                                <p><strong>Name:</strong> ${hostUser.firstName} ${hostUser.lastName}</p>
                                <p><strong>Email ID:</strong> ${hostUser.email}</p>
                                <p><strong>Phone Number:</strong> ${hostUser.phoneNumber}</p>
                              </div>
                            </div>
                            <div class="bg-complementary rounded golden-container">
                              <div class="text-container">
                                <h3 class="text-lg font-semibold mb-1">Booking Information</h3>
                                <p><strong>Start Date and Time:</strong> ${DateFormat('dd/MM/yyyy').format(bookingsModel.schedule!.dates![0].toDate())} ${bookingsModel.schedule!.startTime}</p>
                                <p><strong>End Date and Time:</strong> ${DateFormat('dd/MM/yyyy').format(bookingsModel.schedule!.dates![1].toDate())} ${bookingsModel.schedule!.endTime}</p>
                                <p><strong>Number of Guests:</strong> ${bookingsModel.totalGuest}</p>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </body>
                </html>
            </div>
        </div>
    </div>
</body>
</html>
''',
        }
      });
    } on Exception catch (e) {
      debugPrintStack();
      log(e.toString());
    }
    baseVm.selectedPage = -1;
    baseVm.isHome = true;
    splitList.clear();
    searchVm.selectedBookingDays?.clear();
    searchVm.selectedBookingTime = null;
    searchVm.selectedCharterDayType = searchVm.charterDayList[0];
    totalMembersCount = 0;
    selectedPayIn = 0;
    selectedPaymentMethod = -1;
    update();
    baseVm.update();
    searchVm.update();
    if (selectedPaymentMethod == PaymentMethodEnum.card.index) {
      Get.bottomSheet(Congoratulations(
          getTranslated(
                  context, "your_booking_has_been_confirmed_successfully") ??
              "", () {
        Timer(Duration(seconds: 2), () async {
          await authVm.cancleStreams();
          Get.offAllNamed(BaseView.route);
        });
      }));
    } else if (selectedPaymentMethod == PaymentMethodEnum.appStore.index) {
      Timer(Duration(seconds: 2), () {
        Get.back();
        Get.bottomSheet(Congoratulations(
            getTranslated(
                    context, "your_booking_has_been_confirmed_successfully") ??
                "", () {
          Timer(Duration(seconds: 2), () async {
            await authVm.cancleStreams();
            Get.offAllNamed(BaseView.route);
          });
        }));
      });
    } else {
      Get.bottomSheet(Congoratulations(
          getTranslated(context,
                  "your_booking_has_been_confirmed_successfully_crypto") ??
              "", () {
        Timer(Duration(seconds: 2), () async {
          await authVm.cancleStreams();
          Get.offAllNamed(BaseView.route);
        });
      }));
    }
  }

  Future<bool> sendNotification(
      NotificationModel notificationData, String userFCM,
      {bool isSchedule = false,
      DateTime? scheduleTime24Hr,
      DateTime? scheduleTime2Hr}) async {
    bool proceed = false;
    try {
      if (isSchedule) {
        log("____2HR:${scheduleTime2Hr}____${scheduleTime24Hr?.difference(DateTime.now())}");
        scheduleTime24Hr == null
            ? null
            : await NotificationService().scheduleNotification(
                title: notificationData.title ?? "",
                body: notificationData.text,
                scheduledNotificationDateTime: scheduleTime24Hr);
        scheduleTime2Hr == null
            ? null
            : await NotificationService().scheduleNotification(
                title: notificationData.title ?? "",
                body: notificationData.text,
                scheduledNotificationDateTime: scheduleTime2Hr);
      } else {
        await NotificationService.sendNotification(
            fcmToken: userFCM,
            title: notificationData.title ?? "",
            body: "${notificationData.text}");
      }
      proceed = true;
    } catch (e) {
      log(e.toString());
    }
    notifyListeners();
    return proceed;
  }

  sendNotificationOnBooking(
      BuildContext context, String docID, DocumentSnapshot charter) async {
    var authVm = Provider.of<AuthVm>(context, listen: false);
    log("_____IN SEND NOTI");
    DocumentReference ref = FbCollections.notifications.doc();
    DocumentReference refHost = FbCollections.notifications.doc();
    NotificationModel notificationModel = bookingsModel
                .paymentDetail?.isSplit ==
            true
        ? NotificationModel(
            bookingId: docID,
            id: ref.id,
            sender: FirebaseAuth.instance.currentUser?.uid,
            createdAt: Timestamp.now(),
            isSeen: false,
            type: NotificationReceiverType.person.index,
            hostUserId: charter.get("created_by"),
            title: charter.get("name"),
            text:
                "${authVm.userModel?.firstName ?? ""} have made the Split Payment for booking in ${payInTypeList[bookingsModel.paymentDetail?.payInType ?? 0]} at ${DateFormat("hh:mm a").format(bookingsModel.createdAt?.toDate() ?? now)} on ${DateFormat("dd MMM,yyyy").format(bookingsModel.createdAt?.toDate() ?? now)}",
            receiver: bookingsModel.paymentDetail?.splitPayment
                ?.where((element) =>
                    element.userUid != FirebaseAuth.instance.currentUser?.uid)
                .toList()
                .map((e) => e.userUid)
                .toList())
        : NotificationModel(
            bookingId: docID,
            id: ref.id,
            sender: FirebaseAuth.instance.currentUser?.uid,
            createdAt: Timestamp.now(),
            isSeen: false,
            type: NotificationReceiverType.host.index,
            hostUserId: charter.get("created_by"),
            title: "Booking Alert!",
            text:
                "${authVm.userModel?.firstName ?? ""} you have 1 minute left in starting your booking for charter ${charter.get("name")}",
            receiver: [
                FirebaseAuth.instance.currentUser?.uid,
              ]);
    NotificationModel notificationModelHost = NotificationModel(
        bookingId: docID,
        id: refHost.id,
        sender: FirebaseAuth.instance.currentUser?.uid,
        createdAt: Timestamp.now(),
        isSeen: false,
        type: NotificationReceiverType.host.index,
        hostUserId: charter.get("created_by"),
        title: charter.get("name"),
        text:
            "${authVm.userModel?.firstName ?? ""} have made the booking in ${payInTypeList[bookingsModel.paymentDetail?.payInType ?? 0]} at ${DateFormat("hh:mm a").format(bookingsModel.createdAt?.toDate() ?? now)} on ${DateFormat("dd MMM,yyyy").format(bookingsModel.createdAt?.toDate() ?? now)}",
        receiver: [charter.get("created_by")]);
    await ref.set(notificationModel.toJson());
    await refHost.set(notificationModelHost.toJson());

    ///PUSH NOTIFICATION TO HOST
    await sendNotification(
        notificationModelHost,
        context
                .read<BaseVm>()
                .allUsers
                .firstWhereOrNull((e) => e.uid == charter.get("created_by"))
                ?.fcm ??
            "");

    ///SCHEDULE NOTIFICATION TO CUSTOMER
    int bookingStartHour =
        int.parse(bookingsModel.schedule?.startTime?.split(":").first ?? "");
    int bookingStartMin = int.parse(
        bookingsModel.schedule?.startTime?.split(" ").first.split(":").last ??
            "");
    int bookingYear =
        bookingsModel.schedule?.dates?.first.toDate().year ?? 2023;
    int bookingMonth = bookingsModel.schedule?.dates?.first.toDate().month ?? 1;
    int bookingDay = bookingsModel.schedule?.dates?.first.toDate().day ?? 1;
    int? bookingRemainingHrs = DateTime(bookingYear, bookingMonth, bookingDay,
            bookingStartHour, bookingStartMin)
        .difference(DateTime.now())
        .inHours;
    DateTime? scheduleTime2Hr;
    DateTime? scheduleTime24Hr;
    if (bookingRemainingHrs < 2) {
      scheduleTime2Hr = DateTime.now().add(Duration(
          hours: bookingRemainingHrs > 2 ? bookingRemainingHrs - 2 : 1));
    } else {
      scheduleTime24Hr = DateTime.now().add(Duration(
          hours: bookingRemainingHrs > 24 ? bookingRemainingHrs - 24 : 24));
      scheduleTime2Hr = DateTime.now().add(Duration(
          hours: bookingRemainingHrs > 2 ? bookingRemainingHrs - 2 : 1));
    }

    if (bookingsModel.paymentDetail?.isSplit == true) {
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid != FirebaseAuth.instance.currentUser?.uid)
          .toList()
          .forEach((element) async {
        ///PUSH NOTIFICATION TO SPLIT CUSTOMERS
        await sendNotification(
            notificationModel,
            context
                    .read<BaseVm>()
                    .allUsers
                    .firstWhereOrNull((e) => e.uid == element.userUid)
                    ?.fcm ??
                "");
      });
    }

    ///PUSH NOTIFICATION TO  CUSTOMER
    await sendNotification(
        notificationModel, context.read<AuthVm>().userModel?.fcm ?? "",
        isSchedule: true,
        scheduleTime2Hr: scheduleTime2Hr,
        scheduleTime24Hr: scheduleTime24Hr);
  }

  void completePaymentFunction(String? screenShotUrl, BuildContext context) {
    var baseVm = Provider.of<BaseVm>(context, listen: false);
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    if (bookingsModel.paymentDetail?.isSplit == true) {
      if (bookingsModel.paymentDetail?.splitPayment
              ?.where((element) =>
                  element.userUid == FirebaseAuth.instance.currentUser?.uid)
              .first
              .depositStatus ==
          DepositStatus.nothingPaid.index) {
        bookingsModel.paymentDetail?.paidAmount = bookingsModel
                .paymentDetail?.paidAmount +
            bookingsModel.paymentDetail?.splitPayment
                ?.where((element) =>
                    element.userUid == FirebaseAuth.instance.currentUser?.uid)
                .first
                .remainingDeposit;
        bookingsModel.paymentDetail?.remainingAmount = bookingsModel
                .paymentDetail?.remainingAmount -
            bookingsModel.paymentDetail?.splitPayment
                ?.where((element) =>
                    element.userUid == FirebaseAuth.instance.currentUser?.uid)
                .first
                .remainingDeposit;
      } else if (bookingsModel.paymentDetail?.splitPayment
              ?.where((element) =>
                  element.userUid == FirebaseAuth.instance.currentUser?.uid)
              .first
              .depositStatus ==
          DepositStatus.twentyFivePaid.index) {
        bookingsModel.paymentDetail?.paidAmount = bookingsModel
                .paymentDetail?.paidAmount +
            bookingsModel.paymentDetail?.splitPayment
                ?.where((element) =>
                    element.userUid == FirebaseAuth.instance.currentUser?.uid)
                .first
                .remainingAmount;
        bookingsModel.paymentDetail?.remainingAmount = bookingsModel
                .paymentDetail?.remainingAmount -
            bookingsModel.paymentDetail?.splitPayment
                ?.where((element) =>
                    element.userUid == FirebaseAuth.instance.currentUser?.uid)
                .first
                .remainingAmount;
      }
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .paymentType = PaymentType.payInApp.index;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .amount = bookingsModel.paymentDetail?.payInType ==
              PayType.fullPay.index
          ? bookingsModel.paymentDetail?.splitPayment
              ?.where((element) =>
                  element.userUid == FirebaseAuth.instance.currentUser?.uid)
              .first
              .amount
          : bookingsModel.paymentDetail?.splitPayment
                      ?.where((element) =>
                          element.userUid ==
                          FirebaseAuth.instance.currentUser?.uid)
                      .first
                      .depositStatus ==
                  DepositStatus.nothingPaid.index
              ? bookingsModel.paymentDetail?.splitPayment
                  ?.where((element) =>
                      element.userUid == FirebaseAuth.instance.currentUser?.uid)
                  .first
                  .remainingDeposit
              : bookingsModel.paymentDetail?.splitPayment
                      ?.where((element) =>
                          element.userUid ==
                          FirebaseAuth.instance.currentUser?.uid)
                      .first
                      .amount +
                  bookingsModel.paymentDetail?.splitPayment
                      ?.where((element) =>
                          element.userUid ==
                          FirebaseAuth.instance.currentUser?.uid)
                      .first
                      .remainingAmount;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .remainingAmount = bookingsModel.paymentDetail?.splitPayment
                  ?.where((element) =>
                      element.userUid == FirebaseAuth.instance.currentUser?.uid)
                  .first
                  .depositStatus ==
              DepositStatus.twentyFivePaid.index
          ? 0.0
          : bookingsModel.paymentDetail?.splitPayment
              ?.where((element) =>
                  element.userUid == FirebaseAuth.instance.currentUser?.uid)
              .first
              .remainingAmount;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .remainingDeposit = 0.0;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .depositStatus = bookingsModel.paymentDetail?.splitPayment
                  ?.where((element) =>
                      element.userUid == FirebaseAuth.instance.currentUser?.uid)
                  .first
                  .depositStatus ==
              DepositStatus.twentyFivePaid.index
          ? DepositStatus.fullPaid.index
          : DepositStatus.twentyFivePaid.index;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .paymentStatus = PaymentStatus.payInAppOrCash.index;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .paymentMethod = selectedPaymentMethod;
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .cryptoReceiverEmail = appUrlModel?.adminCryptoEmail ?? "";
      bookingsModel.paymentDetail?.splitPayment
          ?.where((element) =>
              element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first
          .cryptoScreenShot = screenShotUrl;
    } else {
      bookingsModel.paymentDetail?.paymentType = PaymentType.payInApp.index;
      bookingsModel.paymentDetail?.paidAmount =
          bookingsModel.paymentDetail?.paidAmount +
              bookingsModel.paymentDetail?.remainingAmount;
      bookingsModel.paymentDetail?.remainingAmount = 0.0;
      bookingsModel.paymentDetail?.paymentStatus =
          PaymentStatus.payInAppOrCash.index;
    }
    homeVm.update();
    baseVm.selectedPage = -1;
    baseVm.isHome = true;
    baseVm.update();
  }

  Future<CharterModel?> getCharterFromDb(String docId) async {
    try {
      DocumentSnapshot doc = await FbCollections.charterFleet.doc(docId).get();
      CharterModel charterModel = CharterModel.fromJson(doc.data());
      return charterModel;
    } on Exception catch (e) {
      debugPrintStack();
      log(e.toString());
      return null;
    }
  }

  update() {
    notifyListeners();
  }
}
