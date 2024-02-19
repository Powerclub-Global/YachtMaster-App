import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/date_picker_services.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/charters_day_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/time_slot_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings_dialog.dart';
import 'package:yacht_master/src/base/search/view/time_picker_sheet.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/utils/date_range_picker.dart';
import 'package:yacht_master/utils/extensions.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:location/location.dart' as locations;

import '../../../../utils/validation.dart';

class WhenWillBeThere extends StatefulWidget {
  static String route = "/whenWillBeThere";

  @override
  _WhenWillBeThereState createState() => _WhenWillBeThereState();
}

class _WhenWillBeThereState extends State<WhenWillBeThere> {
  final formKey = GlobalKey<FormState>();
  List<CharterDayModel> charterDayList = [];
  TextEditingController startTimeCon = TextEditingController();
  TextEditingController startTime2Con = TextEditingController();
  FocusNode startTimeFn = FocusNode();

  TextEditingController endTimeCon = TextEditingController();
  FocusNode endTimeFn = FocusNode();
  DateTime now = DateTime.now();
  bool isReserve = false;
  bool isSelectTime = false;
  CharterModel? charter;
  BookingsModel? bookingsModel;
  bool isLoading = false;

  int selectedTab = 0;

  ///0 means calendar selected

  locations.LocationData? locationData;
  locations.Location location = new locations.Location();
  bool? _serviceEnabled;
  locations.PermissionStatus? _permissionGranted;
  String city = "";
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var provider = Provider.of<SearchVm>(context, listen: false);
      var bookingVm = Provider.of<BookingsVm>(context, listen: false);
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        isReserve = args["isReserve"];
        charter = args["yacht"];
        bookingsModel = args["bookingsModel"];
        isSelectTime = args["isSelectTime"];
        city = args["cityModel"];
      });
      log("_____________CHARTER:${charter}");
      log("_____________isFILTER:${isReserve}");
      if (isReserve) {
        city = city;
        log("CITY:${city}");
      } else {
        await getCity(LatLng(charter?.location?.lat ?? 31.456471,
            charter?.location!.long ?? -80.139739819));
      }

      if (bookingVm.bookingsModel.durationType != null) {
        setState(() {
          provider.selectedCharterDayType = provider.charterDayList[
              provider.charterDayList.indexWhere((element) =>
                  element.type == bookingVm.bookingsModel.durationType)];
        });
      } else {
        setState(() {
          provider.selectedCharterDayType = provider.charterDayList[0];
        });
      }
      if (bookingsModel != null) {
        setState(() {
          startTimeCon.text = bookingsModel?.schedule?.startTime ?? "";
          endTimeCon.text = bookingsModel?.schedule?.endTime ?? "";
        });
      }
      addCharterPriceTypeData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    bookingsModel = args["bookingsModel"];
    isReserve = args["isReserve"];
    isSelectTime = args["isSelectTime"];
    charter = args["yacht"];

    return Consumer2<SearchVm, BookingsVm>(
        builder: (context, provider, bookingsVm, _) {
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: Scaffold(
          backgroundColor: R.colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            titleSpacing: 0,
            leading: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: R.colors.whiteColor,
                  size: 20,
                )),
            title: Text(
                isSelectTime == true
                    ? "Select Time"
                    : bookingsModel != null && isSelectTime == false
                        ? "Update"
                        : getTranslated(context, "search") ?? "",
                style: R.textStyle
                    .helvetica()
                    .copyWith(color: Colors.grey, fontSize: 14.sp)),
          ),
          body: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                Helper.focusOut(context);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  h3,
                  Text(getTranslated(context, "when_will_be_you_there") ?? "",
                      style: R.textStyle
                          .helveticaBold()
                          .copyWith(color: Colors.white, fontSize: 16.sp)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // if (isEdit==true) SizedBox(height: 4.h,) else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              h2P5,
                              Text(
                                city,
                                style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteDull,
                                      fontSize: 14.sp,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              h2,
                              label(getTranslated(context, "duration") ?? "",
                                  fs: 14),
                              h1P5,
                              Container(
                                decoration: BoxDecoration(
                                    color: R.colors.blackDull,
                                    borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h, horizontal: 2.w),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(
                                        charterDayList.length,
                                        (index) {
                                      return dayTypeTabs(
                                          charterDayList[index],
                                          provider,
                                          index);
                                    })),
                              ),
                              h2,
                            ],
                          ),
                          label(getTranslated(context, "date") ?? "", fs: 14),
                          h1P5,
                          Container(
                              decoration: BoxDecoration(
                                  color: R.colors.blackDull,
                                  borderRadius: BorderRadius.circular(16)),
                              padding: EdgeInsets.symmetric(
                                horizontal: Get.width * .01,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DatePickerCalendar(
                                      charter,
                                      provider.selectedCharterDayType?.type ??
                                          0,
                                      List.from(
                                          bookingsModel?.schedule?.dates ?? []),
                                      (isReserve == true &&
                                              isSelectTime == false)
                                          ? true
                                          : false,
                                      isReserve, (val) {
                                    if (val) {
                                      startTimeCon.clear();
                                      startTime2Con.clear();
                                      endTimeCon.clear();
                                      setState(() {});
                                    }
                                  }),
                                ],
                              )),
                          h2,
                          label(getTranslated(context, "start_time") ?? "",
                              fs: 14),
                          h1P5,
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            focusNode: startTimeFn,
                            readOnly: true,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              FilteringTextInputFormatter(RegExp("[0-9:]"),
                                  allow: true)
                            ],
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) {
                              setState(() {});
                            },
                            onTap: () {
                              endTimeCon.clear();
                              startTimeCon.clear();
                              Get.bottomSheet(TimePickerSheet(
                                selectedDate: DateTimePickerServices.selectedStartDateTimeDB,
                                onDateSelect: (selectedTime){
                                  if(selectedTime != null){
                                    DateTimePickerServices.startTime = TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute,);
                                    startTime2Con.text = DateFormat("hh:mm a").format(DateTime(
                                        DateTimePickerServices.selectedStartDate.year,
                                        DateTimePickerServices.selectedStartDate.month,
                                        DateTimePickerServices.selectedStartDate.day,
                                        DateTimePickerServices.startTime.hour,
                                        DateTimePickerServices.startTime.minute));
                                    DateTimePickerServices.selectedStartDateTime = DateTime(
                                        DateTimePickerServices.selectedStartDate.year,
                                        DateTimePickerServices.selectedStartDate.month,
                                        DateTimePickerServices.selectedStartDate.day,
                                        DateTimePickerServices.startTime.hour,
                                        DateTimePickerServices.startTime.minute);
                                    DateTimePickerServices.selectedStartDateTimeDB = DateTime(
                                        DateTimePickerServices.selectedStartDate.year,
                                        DateTimePickerServices.selectedStartDate.month,
                                        DateTimePickerServices.selectedStartDate.day,
                                        DateTimePickerServices.startTime.hour,
                                        DateTimePickerServices.startTime.minute);
                                    if (startTime2Con.text.isNotEmpty) {
                                      startTimeCon.text =
                                          DateFormat("dd/MM/yyyy hh:mm a").format(
                                              DateTimePickerServices
                                                  .selectedStartDateTimeDB);
                                      if (selectedTab == 0) {
                                        DateTimePickerServices
                                            .selectedEndDateTimeDB =
                                            DateTimePickerServices
                                                .selectedStartDateTimeDB
                                                .add(Duration(hours: 4));
                                        endTimeCon.text =
                                            DateFormat("dd/MM/yyyy hh:mm a").format(
                                                DateTimePickerServices
                                                    .selectedEndDateTimeDB);
                                      } else if (selectedTab == 1) {
                                        DateTimePickerServices
                                            .selectedEndDateTimeDB =
                                            DateTimePickerServices
                                                .selectedStartDateTimeDB
                                                .add(Duration(hours: 8));
                                        endTimeCon.text =
                                            DateFormat("dd/MM/yyyy hh:mm a").format(
                                                DateTimePickerServices
                                                    .selectedEndDateTimeDB);
                                      } else if (selectedTab == 2) {
                                        DateTimePickerServices
                                            .selectedEndDateTimeDB =
                                            DateTimePickerServices
                                                .selectedStartDateTimeDB
                                                .add(Duration(hours: 24));
                                        endTimeCon.text =
                                            DateFormat("dd/MM/yyyy hh:mm a").format(
                                                DateTimePickerServices
                                                    .selectedEndDateTimeDB);
                                      }
                                      setState(() {});
                                    }
                                  }
                                },
                              ),isDismissible: false,enableDrag: false);

                              // DateTimePickerServices.selectStartTimeFunction(
                              //         context,
                              //         startTime2Con,
                              //         DateTimePickerServices
                              //             .selectedStartDateTimeDB)
                              //     .then((value) {
                              //   if (startTime2Con.text.isNotEmpty) {
                              //     startTimeCon.text =
                              //         DateFormat("dd/MM/yyyy hh:mm a").format(
                              //             DateTimePickerServices
                              //                 .selectedStartDateTimeDB);
                              //     if (selectedTab == 0) {
                              //       DateTimePickerServices
                              //               .selectedEndDateTimeDB =
                              //           DateTimePickerServices
                              //               .selectedStartDateTimeDB
                              //               .add(Duration(hours: 4));
                              //       endTimeCon.text =
                              //           DateFormat("dd/MM/yyyy hh:mm a").format(
                              //               DateTimePickerServices
                              //                   .selectedEndDateTimeDB);
                              //     } else if (selectedTab == 1) {
                              //       DateTimePickerServices
                              //               .selectedEndDateTimeDB =
                              //           DateTimePickerServices
                              //               .selectedStartDateTimeDB
                              //               .add(Duration(hours: 8));
                              //       endTimeCon.text =
                              //           DateFormat("dd/MM/yyyy hh:mm a").format(
                              //               DateTimePickerServices
                              //                   .selectedEndDateTimeDB);
                              //     } else if (selectedTab == 2) {
                              //       DateTimePickerServices
                              //               .selectedEndDateTimeDB =
                              //           DateTimePickerServices
                              //               .selectedStartDateTimeDB
                              //               .add(Duration(hours: 24));
                              //       endTimeCon.text =
                              //           DateFormat("dd/MM/yyyy hh:mm a").format(
                              //               DateTimePickerServices
                              //                   .selectedEndDateTimeDB);
                              //     }
                              //     setState(() {});
                              //   }
                              // });
                            },
                            onFieldSubmitted: (a) {
                              setState(() {
                                FocusScope.of(Get.context!).unfocus();
                              });
                            },
                            controller: startTime2Con,
                            validator: (val) =>
                                FieldValidator.validateEmpty(val ?? ""),
                            decoration: AppDecorations.suffixTextField(
                                "start_time",
                                R.textStyle.helvetica().copyWith(
                                    color: startTimeFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                null),
                          ),
                          h1P5,
                          if (endTimeCon.text.isNotEmpty)
                            Text(
                              "${getTranslated(context, "end_time_will_be")} ${endTimeCon.text}",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.whiteColor, fontSize: 12.sp),
                            ),
                          // if (isReserve == true && isSelectTime == false)
                          //   Column(
                          //     children: [
                          //       h2,
                          //       label(
                          //           getTranslated(context, "start_time") ?? "",
                          //           fs: 14),
                          //       h1P5,
                          //       TextFormField(
                          //         textAlignVertical: TextAlignVertical.center,
                          //         focusNode: startTimeFn,
                          //         readOnly: true,
                          //         keyboardType: TextInputType.datetime,
                          //         inputFormatters: [
                          //           FilteringTextInputFormatter(
                          //               RegExp("[0-9:]"),
                          //               allow: true)
                          //         ],
                          //         autovalidateMode:
                          //             AutovalidateMode.onUserInteraction,
                          //         textInputAction: TextInputAction.next,
                          //         onChanged: (v) {
                          //           setState(() {});
                          //         },
                          //         onTap: () {
                          //           endTimeCon.clear();
                          //           bookingsVm.selectTime(
                          //             true,
                          //             startTimeCon.text.isNotEmpty
                          //                 ? DateFormat.jm()
                          //                     .parse(startTimeCon.text)
                          //                 : bookingsVm.time,
                          //             startTimeCon,
                          //             endTimeCon,
                          //           );
                          //         },
                          //         onFieldSubmitted: (a) {
                          //           setState(() {
                          //             FocusScope.of(Get.context!)
                          //                 .requestFocus(endTimeFn);
                          //           });
                          //         },
                          //         controller: startTimeCon,
                          //         validator: (val) =>
                          //             FieldValidator.validateEmpty(val ?? ""),
                          //         decoration: AppDecorations.suffixTextField(
                          //             "start_time",
                          //             R.textStyle.helvetica().copyWith(
                          //                 color: startTimeFn.hasFocus
                          //                     ? R.colors.themeMud
                          //                     : R.colors.charcoalColor,
                          //                 fontSize: 10.sp),
                          //             SizedBox()),
                          //       ),
                          //     ],
                          //   )
                          // else
                          //   Column(
                          //     children: [
                          //       h2,
                          //       label(
                          //           getTranslated(context, "start_time") ?? "",
                          //           fs: 14),
                          //       h1P5,
                          //       if (provider.selectedCharterDayType?.type ==
                          //           CharterDayType.halfDay.index)
                          //         SingleChildScrollView(
                          //           scrollDirection: Axis.horizontal,
                          //           child: Row(
                          //             children: List.generate(
                          //                 charter?.availability?.halfDaySlots
                          //                         ?.length ??
                          //                     0, (index) {
                          //               String start = charter?.availability
                          //                       ?.halfDaySlots?[index].start ??
                          //                   "0";
                          //               String end = charter?.availability
                          //                       ?.halfDaySlots?[index].end ??
                          //                   "0";
                          //               return timeDurationTabs(
                          //                   provider, start, end, index);
                          //             }),
                          //           ),
                          //         )
                          //       else if (provider
                          //               .selectedCharterDayType?.type ==
                          //           CharterDayType.fullDay.index)
                          //         SingleChildScrollView(
                          //           scrollDirection: Axis.horizontal,
                          //           child: Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.start,
                          //             children: List.generate(
                          //                 charter?.availability?.fullDaySlots
                          //                         ?.length ??
                          //                     0, (index) {
                          //               String start = charter?.availability
                          //                       ?.fullDaySlots?[index].start ??
                          //                   "0";
                          //               String end = charter?.availability
                          //                       ?.fullDaySlots?[index].end ??
                          //                   "0";
                          //               return timeDurationTabs(
                          //                   provider, start, end, index);
                          //             }),
                          //           ),
                          //         )
                          //       else
                          //         Row(
                          //           crossAxisAlignment:
                          //               CrossAxisAlignment.start,
                          //           children: [
                          //             Expanded(
                          //               child: TextFormField(
                          //                 textAlignVertical:
                          //                     TextAlignVertical.center,
                          //                 focusNode: startTimeFn,
                          //                 readOnly: true,
                          //                 keyboardType: TextInputType.datetime,
                          //                 inputFormatters: [
                          //                   FilteringTextInputFormatter(
                          //                       RegExp("[0-9:]"),
                          //                       allow: true)
                          //                 ],
                          //                 autovalidateMode: AutovalidateMode
                          //                     .onUserInteraction,
                          //                 textInputAction: TextInputAction.next,
                          //                 onChanged: (v) {
                          //                   setState(() {});
                          //                 },
                          //                 onTap: () {
                          //                   endTimeCon.clear();
                          //                   bookingsVm.selectTime(
                          //                     true,
                          //                     startTimeCon.text.isNotEmpty
                          //                         ? DateFormat.jm()
                          //                             .parse(startTimeCon.text)
                          //                         : bookingsVm.time,
                          //                     startTimeCon,
                          //                     endTimeCon,
                          //                   );
                          //                 },
                          //                 onFieldSubmitted: (a) {
                          //                   setState(() {
                          //                     FocusScope.of(Get.context!)
                          //                         .requestFocus(endTimeFn);
                          //                   });
                          //                 },
                          //                 controller: startTimeCon,
                          //                 validator: (val) =>
                          //                     FieldValidator.validateEmpty(
                          //                         val ?? ""),
                          //                 decoration:
                          //                     AppDecorations.suffixTextField(
                          //                         "start_time",
                          //                         R
                          //                             .textStyle
                          //                             .helvetica()
                          //                             .copyWith(
                          //                                 color: startTimeFn
                          //                                         .hasFocus
                          //                                     ? R.colors
                          //                                         .themeMud
                          //                                     : R.colors
                          //                                         .charcoalColor,
                          //                                 fontSize: 10.sp),
                          //                         SizedBox()),
                          //               ),
                          //             ),
                          //             w2,
                          //             Expanded(
                          //               child: TextFormField(
                          //                 textAlignVertical:
                          //                     TextAlignVertical.center,
                          //                 focusNode: endTimeFn,
                          //                 readOnly: true,
                          //                 keyboardType: TextInputType.datetime,
                          //                 autovalidateMode: AutovalidateMode
                          //                     .onUserInteraction,
                          //                 textInputAction: TextInputAction.done,
                          //                 inputFormatters: [
                          //                   FilteringTextInputFormatter(
                          //                       RegExp("[0-9:]"),
                          //                       allow: true)
                          //                 ],
                          //                 onChanged: (v) {
                          //                   setState(() {});
                          //                 },
                          //                 onTap: () {
                          //                   bookingsVm.selectTime(
                          //                       false,
                          //                       endTimeCon.text.isEmpty
                          //                           ? DateFormat.jm()
                          //                               .parse(
                          //                                   startTimeCon.text)
                          //                               .add(Duration(
                          //                                   minutes: 60))
                          //                           : DateFormat.jm()
                          //                               .parse(endTimeCon.text),
                          //                       startTimeCon,
                          //                       endTimeCon);
                          //                 },
                          //                 onFieldSubmitted: (a) {
                          //                   setState(() {
                          //                     Helper.focusOut(context);
                          //                   });
                          //                 },
                          //                 controller: endTimeCon,
                          //                 validator: (val) =>
                          //                     FieldValidator.validateEmpty(
                          //                         val ?? ""),
                          //                 decoration:
                          //                     AppDecorations.suffixTextField(
                          //                         "end_time",
                          //                         R
                          //                             .textStyle
                          //                             .helvetica()
                          //                             .copyWith(
                          //                                 color: startTimeFn
                          //                                         .hasFocus
                          //                                     ? R.colors
                          //                                         .themeMud
                          //                                     : R.colors
                          //                                         .charcoalColor,
                          //                                 fontSize: 10.sp),
                          //                         SizedBox()),
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //     ],
                          //   ),
                          h3P5,
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                if (formKey.currentState!.validate()) {
                                  // startLoader();
                                  bool check = checkAvailability();
                                  if(check){
                                    print("CAN DO BOOKING");
                                    await bookingsVm.onClickWhenWillBeThere(
                                        city,
                                        charter,
                                        isSelectTime,
                                        isReserve,
                                        bookingsModel,
                                        startTimeCon,
                                        endTimeCon,
                                        context);
                                  }else{
                                    Get.dialog(BookingsDialog(charter: charter!));
                                  }
                                  // stopLoader();
                                }
                              },
                              child: Container(
                                height: Get.height * .055,
                                width: Get.width * .75,
                                decoration:
                                    AppDecorations.gradientButton(radius: 30),
                                child: Center(
                                  child: Text(
                                    bookingsModel != null &&
                                            isSelectTime == false
                                        ? "Update"
                                        : "${getTranslated(context, "next")?.toUpperCase()}",
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
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget dayTypeTabs(CharterDayModel charter, SearchVm provider, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          selectedTab = charter.type;
          startTimeCon.clear();
          startTime2Con.clear();
          endTimeCon.clear();
          setState(() {});
          provider.selectedBookingDays?.clear();
          startTimeCon.clear();
          endTimeCon.clear();
          provider.selectedBookingTime = null;
          provider.selectedCharterDayType = charter;
          provider.update();
        },
        child: Container(
          decoration: BoxDecoration(
            color: R.colors.blackDull,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: provider.selectedCharterDayType == charter
                    ? R.colors.themeMud
                    : Colors.transparent,
                width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 1.h,
          ),
          child: Center(
            child: Text(
              index == 0
                  ? "${charter.title.split("C").first} (4h)"
                  : index == 1
                      ? "${charter.title.split("C").first} (8h)"
                      : charter.title.split("C").first,
              style: R.textStyle.helvetica().copyWith(
                  color: provider.selectedCharterDayType == charter
                      ? R.colors.themeMud
                      : R.colors.whiteDull,
                  fontSize: 11.sp),
            ),
          ),
        ),
      ),
    );
  }

  Widget timeDurationTabs(
    SearchVm provider,
    String start,
    String end,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        provider.selectedBookingTime = TimeSlotModel(start, end);
        provider.update();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: provider.selectedBookingTime?.startTime == start &&
                      provider.selectedBookingTime?.endTime == end
                  ? R.colors.themeMud
                  : R.colors.whiteColor,
              width: 1.5),
        ),
        padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.w),
        margin: EdgeInsets.only(right: 2.w),
        child: Center(
          child: Text(
            "$start - $end",
            style: R.textStyle.helvetica().copyWith(
                color: provider.selectedBookingTime?.startTime == start &&
                        provider.selectedBookingTime?.endTime == end
                    ? R.colors.themeMud
                    : R.colors.whiteColor,
                fontSize: 11.sp),
          ),
        ),
      ),
    );
  }

  ///FUNCYIONS

  Future<bool> enableBackgroundMode() async {
    bool _bgModeEnabled = await location.isBackgroundModeEnabled();
    log("_________________________IS BACKGROUND MODE ENABLE:${_bgModeEnabled}");
    if (_bgModeEnabled) {
      return true;
    } else {
      try {
        await location.enableBackgroundMode();
      } catch (e) {
        log(e.toString());
      }
      try {
        _bgModeEnabled = await location.enableBackgroundMode();
      } catch (e) {
        log(e.toString());
      }
      log("++++++++++++++++++BG${_bgModeEnabled}"); //True!
      return _bgModeEnabled;
    }
  }

  getMyLoc() async {
    log("__________________________________IN GET MY LOC");
    await enableBackgroundMode();
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      log("_________________________________SERVICE NOT ENABLED");
      stopLoader();
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == locations.PermissionStatus.denied) {
      log("_________________________________permission NOT ENABLED");
      stopLoader();
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted != locations.PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    log("__________________________________IN GET MY LOC:${locationData?.latitude}");

    log("my lat ${locationData!.latitude} my lng ${locationData!.longitude}");
  }

  getCity(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    var first = placemarks.first;
    log("\ncomplete Address: $first");
    city = first.locality ?? "";
    setState(() {});
  }

  startLoader() {
    setState(() {
      isLoading = true;
    });
  }

  stopLoader() {
    setState(() {
      isLoading = false;
    });
  }

  bool checkAvailability() {
    bool proceed = false;
    bool isFirst = true;
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    if(homeVm.allBookings
        .where((element) => element.charterFleetDetail?.id == charter?.id && element.bookingStatus == 0).toList().isEmpty){
      proceed = true;
      return proceed;
    }else{
      homeVm.allBookings
          .where((element) => element.charterFleetDetail?.id == charter?.id && element.bookingStatus == 0)
          .forEach((element) {
        if ((!(DateTimePickerServices.selectedStartDateTimeDB.isBetween(
            element.schedule!.dates!.first.toDate(),
            element.schedule!.dates!.last.toDate()) ??
            true) &&
            !(DateTimePickerServices.selectedEndDateTimeDB.isBetween(
                element.schedule!.dates!.first.toDate(),
                element.schedule!.dates!.last.toDate()) ??
                true)) || (!(element.schedule!.dates!.first.toDate().isBetween(
            DateTimePickerServices.selectedStartDateTimeDB,
            DateTimePickerServices.selectedEndDateTimeDB) ??
            true) && !(element.schedule!.dates!.last.toDate().isBetween(
            DateTimePickerServices.selectedStartDateTimeDB,
            DateTimePickerServices.selectedEndDateTimeDB) ??
            true))) {
          if(isFirst) {
            proceed = true;
          }
        } else {
          isFirst = false;
          proceed = false;
        }
      });
    }

    return proceed;
  }

  void addCharterPriceTypeData() {
    if ((charter?.priceFourHours ?? 0) != 0) {
      charterDayList.add(context.read<SearchVm>().charterDayList[0]);
    }
    if ((charter?.priceHalfDay ?? 0) != 0) {
      charterDayList.add(context.read<SearchVm>().charterDayList[1]);
    }
    if ((charter?.priceFullDay ?? 0) != 0) {
      charterDayList.add(context.read<SearchVm>().charterDayList[2]);
    }
    selectedTab = context.read<SearchVm>().selectedCharterDayType?.type ?? 0;
  }
}
