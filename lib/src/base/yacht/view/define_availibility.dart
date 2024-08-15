import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/date_picker_services.dart';
import '../../../../services/firebase_collections.dart';
import '../../../../services/time_schedule_service.dart';
import '../../search/model/charter_model.dart';
import '../../search/model/services_model.dart';
import '../../search/view/bookings/view_model/bookings_vm.dart';
import '../../search/view_model/search_vm.dart';
import '../model/yachts_model.dart';
import '../view_model/yacht_vm.dart';
import '../widgets/availability_calendar.dart';
import '../../../../utils/date_range_picker.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/testing.dart';
import '../../../../utils/validation.dart';

class DefineAvailibility extends StatefulWidget {
  static String route = "/defineAvailability";
  const DefineAvailibility({Key? key}) : super(key: key);

  @override
  _DefineAvailibilityState createState() => _DefineAvailibilityState();
}

class _DefineAvailibilityState extends State<DefineAvailibility> {
  int selectedTab = 0;

  ///0 means calendar selected
  final formKey = GlobalKey<FormState>();
  bool isReadOnly = false;
  TextEditingController startDateCon = TextEditingController();
  TextEditingController endDateCon = TextEditingController();
  TextEditingController startTimeCon = TextEditingController();
  TextEditingController endTimeCon = TextEditingController();
  FocusNode startDateFn = FocusNode();
  FocusNode endDateFn = FocusNode();
  FocusNode startTimeFn = FocusNode();
  FocusNode endTimeFn = FocusNode();
  CharterModel? charter;
  List<DateTime> selectedDates = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var yachtVm = Provider.of<YachtVm>(context, listen: false);
      var bookingVm = Provider.of<BookingsVm>(context, listen: false);
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      charter = args["charter"];
      isReadOnly = args["isReadOnly"];
      if (isReadOnly == true) {
        startTimeCon.text = charter?.availability?.startTime ?? "10:00";
        endTimeCon.text = charter?.availability?.endTime ?? "04:00";
      }
      if (charter != null) {
        startTimeCon.text = charter?.availability?.startTime ?? "10:00";
        endTimeCon.text = charter?.availability?.endTime ?? "04:00";
      }
      setState(() {});
      log("_______________EDIT DAYS:${charter}");
    });
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    charter = args["charter"];
    isReadOnly = args["isReadOnly"];
    return Consumer3<YachtVm, SearchVm, BookingsVm>(
        builder: (context, yachtVm, provider, bookingsVm, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        appBar: GeneralAppBar.simpleAppBar(
            context, getTranslated(context, "availability") ?? ""),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                h3,
                IgnorePointer(
                  ignoring: isReadOnly,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: label(
                                    getTranslated(context, "start_date") ?? "",
                                    fs: 14)),
                            Expanded(
                                child: label(
                                    getTranslated(context, "end_date") ?? "",
                                    fs: 14)),
                          ],
                        ),
                        h1,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                focusNode: startDateFn,
                                readOnly: true,
                                keyboardType: TextInputType.datetime,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                textInputAction: TextInputAction.next,
                                onChanged: (v) {
                                  setState(() {});
                                },
                                onTap: () {
                                  endDateCon.clear();
                                  DateTimePickerServices
                                      .selectStartDateFunction(
                                          startDateCon.text.isNotEmpty
                                              ? DateFormat("MM/dd/yyyy")
                                                  .parse(startDateCon.text)
                                              : DateTime.now(),
                                          DateTime.now(),
                                          DateTime(now.year + 100),
                                          context,
                                          startDateCon);
                                },
                                onFieldSubmitted: (a) {
                                  setState(() {
                                    FocusScope.of(Get.context!)
                                        .requestFocus(endDateFn);
                                  });
                                },
                                controller: startDateCon,
                                validator: (val) =>
                                    FieldValidator.validateEmpty(val ?? ""),
                                decoration: AppDecorations.suffixTextField(
                                    "start_date",
                                    R.textStyle.helvetica().copyWith(
                                        color: startDateFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    SizedBox()),
                              ),
                            ),
                            w2,
                            Expanded(
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                focusNode: endDateFn,
                                readOnly: true,
                                keyboardType: TextInputType.datetime,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                textInputAction: TextInputAction.done,
                                onChanged: (v) {
                                  setState(() {});
                                },
                                onTap: () {
                                  if (startDateCon.text.isNotEmpty) {
                                    DateTimePickerServices
                                            .selectEndDateFunction(
                                                DateTime(now.year + 100),
                                                context,
                                                endDateCon)
                                        .then((value) {
                                      if (endDateCon.text.isNotEmpty) {
                                        selectedDates = getDaysInBetween(
                                            DateFormat("MM/dd/yyyy")
                                                .parse(startDateCon.text),
                                            DateFormat("MM/dd/yyyy")
                                                .parse(endDateCon.text));
                                        selectedDates.forEach((element) {
                                          context
                                              .read<SearchVm>()
                                              .availabilityDays
                                              ?.add(element);
                                          context.read<SearchVm>().update();
                                        });
                                      }
                                    });
                                  }
                                },
                                onFieldSubmitted: (a) {
                                  setState(() {
                                    Helper.focusOut(context);
                                  });
                                },
                                controller: endDateCon,
                                validator: (val) =>
                                    FieldValidator.validateEmpty(val ?? ""),
                                decoration: AppDecorations.suffixTextField(
                                    "end_date",
                                    R.textStyle.helvetica().copyWith(
                                        color: endDateFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    null),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                h4,
                AvailabilityCalendar(
                    charter,
                    2,
                    List.from(
                        charter?.availability?.dates?.map((e) => e.toDate()) ??
                            []),
                    isReadOnly),
                h4,
                // IgnorePointer(
                //   ignoring: isReadOnly,
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(horizontal: 6.w),
                //     child: Column(
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Expanded(
                //                 child: label(
                //                     getTranslated(context, "start_time") ?? "",
                //                     fs: 14)),
                //             Expanded(
                //                 child: label(
                //                     getTranslated(context, "end_time") ?? "",
                //                     fs: 14)),
                //           ],
                //         ),
                //         h1,
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Expanded(
                //               child: TextFormField(
                //                 textAlignVertical: TextAlignVertical.center,
                //                 focusNode: startTimeFn,
                //                 readOnly: true,
                //                 keyboardType: TextInputType.datetime,
                //                 inputFormatters: [
                //                   FilteringTextInputFormatter(RegExp("[0-9:]"),
                //                       allow: true)
                //                 ],
                //                 autovalidateMode:
                //                     AutovalidateMode.onUserInteraction,
                //                 textInputAction: TextInputAction.next,
                //                 onChanged: (v) {
                //                   setState(() {});
                //                 },
                //                 onTap: () {
                //                   endTimeCon.clear();
                //                   bookingsVm.selectTime(
                //                     true,
                //                     startTimeCon.text.isNotEmpty
                //                         ? DateFormat.jm().parse(startTimeCon.text)
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
                //                     FieldValidator.validateEmpty(val ?? ""),
                //                 decoration: AppDecorations.suffixTextField(
                //                     "start_time",
                //                     R.textStyle.helvetica().copyWith(
                //                         color: startTimeFn.hasFocus
                //                             ? R.colors.themeMud
                //                             : R.colors.charcoalColor,
                //                         fontSize: 10.sp),
                //                     SizedBox()),
                //               ),
                //             ),
                //             w2,
                //             Expanded(
                //               child: TextFormField(
                //                 textAlignVertical: TextAlignVertical.center,
                //                 focusNode: endTimeFn,
                //                 readOnly: true,
                //                 keyboardType: TextInputType.datetime,
                //                 autovalidateMode:
                //                     AutovalidateMode.onUserInteraction,
                //                 textInputAction: TextInputAction.done,
                //                 inputFormatters: [
                //                   FilteringTextInputFormatter(RegExp("[0-9:]"),
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
                //                               .parse(startTimeCon.text)
                //                               .add(Duration(minutes: 60))
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
                //                     FieldValidator.validateEmpty(val ?? ""),
                //                 decoration: AppDecorations.suffixTextField(
                //                     "end_time",
                //                     R.textStyle.helvetica().copyWith(
                //                         color: startTimeFn.hasFocus
                //                             ? R.colors.themeMud
                //                             : R.colors.charcoalColor,
                //                         fontSize: 10.sp),
                //                     SizedBox()),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: isReadOnly == true
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width * .2, vertical: Get.height * .01),
                child: GestureDetector(
                  onTap: () {
                    if (provider.availabilityDays!.isEmpty) {
                      Helper.inSnackBar("Error",
                          "Please select availability date", R.colors.themeMud);
                    } else {
                      if (isReadOnly == false) {
                        List<HalfDaySlots> fourHoursSlots = [];
                        List<HalfDaySlots> eightHoursSlots = [];
                        List<FullDaySlots> fullDaySlots = [];
                        List<DateTime> timeList = [];
                        int hourCount = 0;

                        var startTime = DateTime(
                          provider.availabilityDays!.first.year,
                          provider.availabilityDays!.first.month,
                          provider.availabilityDays!.first.day,
                          0,
                          0,
                        );
                        var endTime = DateTime(
                          provider.availabilityDays!.last.year,
                          provider.availabilityDays!.last.month,
                          provider.availabilityDays!.last.day,
                          24,
                          0,
                        );
                        bookingsVm.startTime ??= startTime;

                        bookingsVm.endTime ??= endTime;

                        for (int i = bookingsVm.startTime!.hour;
                            i <= bookingsVm.endTime!.hour;
                            i++) {
                          timeList.add(bookingsVm.startTime!
                              .add(Duration(hours: hourCount)));
                          hourCount = hourCount + 1;
                        }

                        log("____________TIME LIST:${timeList.toSet()}");
                        fourHoursSlots = bookingsVm.getDaySlots(timeList, 4);
                        eightHoursSlots = bookingsVm.getDaySlots(timeList, 8);
                        fullDaySlots = bookingsVm
                            .getDaySlots(timeList, 23)
                            .map(
                                (e) => FullDaySlots(start: e.start, end: e.end))
                            .toList();
                        fourHoursSlots
                            .map((e) =>
                                log("4 START:${e.start}_____TIME:${e.end}"))
                            .toList();
                        eightHoursSlots
                            .map((e) =>
                                log("8 START:${e.start}_____TIME:${e.end}"))
                            .toList();
                        fullDaySlots
                            .map((e) =>
                                log("Full START:${e.start}_____TIME:${e.end}"))
                            .toList();
                        log("____HALF DAY SLOT LEN:${fourHoursSlots.length} - ${eightHoursSlots.length} - ${fullDaySlots.length}");
                        yachtVm.charterModel?.availability = Availability(
                            startTime: startTimeCon.text,
                            endTime: endTimeCon.text,
                            halfDaySlots: eightHoursSlots,
                            fourHoursSlot: fourHoursSlots,
                            fullDaySlots: fullDaySlots,
                            dates: List.from(provider.availabilityDays
                                ?.map((e) => Timestamp.fromDate(e))
                                .toList() ??
                                []));
                        provider.update();
                        Get.back();
                      }
                    }
                  },
                  child: Container(
                    height: Get.height * .055,
                    decoration: AppDecorations.gradientButton(radius: 30),
                    child: Center(
                      child: Text(
                        "${getTranslated(context, "save")?.toUpperCase()}",
                        style: R.textStyle.helvetica().copyWith(
                            color: R.colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
      );
    });
  }

  List<DateTime> getDaysInBetween(DateTime sDate, DateTime eDate) {
    final daysToGenerate = eDate.difference(sDate).inDays + 1;
    return List.generate(daysToGenerate, (i) => sDate.add(Duration(days: i)));
  }

  Widget tabs(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
              color: selectedTab == index ? R.colors.themeMud : R.colors.grey,
              borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.symmetric(vertical: Get.height * .018),
          child: Text(
            getTranslated(context, title) ?? "",
            style: R.textStyle
                .helvetica()
                .copyWith(color: R.colors.black, fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
