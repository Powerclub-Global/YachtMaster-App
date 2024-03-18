import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async_foreach/async_foreach.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/date_picker_services.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/utils/date_utils.dart';

class DatePickerCalendar extends StatefulWidget {
  final int type;

  ///0, 1 SINGLE DAY 2, MULTI DAY
  final List<Timestamp>? selectedDates;
  final bool? isFilter;
  final CharterModel? charter;
  final bool? isReserve;
  final ValueChanged<bool>? onDateSelect;
  const DatePickerCalendar(this.charter, this.type, this.selectedDates,
      this.isFilter, this.isReserve, this.onDateSelect);

  @override
  DatePickerCalendarState createState() => DatePickerCalendarState();
}

class DatePickerCalendarState extends State<DatePickerCalendar> {
  // Using a `LinkedHashSet` is recommended due to equality comparison override
  List<DateTime> unAvailableDates = [];

  ///GREY
  List<DateTime> bookedDates = [];

  ///RED
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime now = DateTime.now();

  @override
  void dispose() {
    super.dispose();
  }

  var pro = Provider.of<SearchVm>(Get.context!, listen: false);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      pro.selectedBookingDays = LinkedHashSet<DateTime>(
        equals: isSameDay,
        hashCode: getHashCode,
      );
      pro.charterAvailableDates = LinkedHashSet<DateTime>(
        equals: isSameDay,
        hashCode: getHashCode,
      );

      if (widget.charter != null) {
        _focusedDay = widget.charter!.availability!.dates!.first.toDate();
      }
      if (widget.isFilter == false) {
        log("hereeee");
        if (widget.selectedDates?.isNotEmpty == true) {
          widget.selectedDates?.forEach((element) {
            pro.selectedBookingDays?.add(element.toDate());
            pro.update();
          });
        }
        log("______________________SELECTED:${pro.selectedBookingDays}");
        await widget.charter!.availability!.dates!
            .asyncForEach((element) async {
          if (DateTime.now().difference(element.toDate()).inHours < 24 &&
              DateFormat("MM-dd-yyyy").format(DateTime.now()) !=
                  DateFormat("MM-dd-yyyy").format(element.toDate())) {
            print("ADDING ${element.toDate().toString()}");
            pro.charterAvailableDates?.add(element.toDate());
          }
        });
        List<String> days = now.allDaysOfMonth();
        days.forEach((e) {
          print("DATE $e");
          pro.charterAvailableDates?.where((element) {
            log("____YEAR:${element.difference(DateFormat("MMMM dd,yyyy").parse(e)).inDays}");
            return true;
          }).toList();

          if (pro.charterAvailableDates
                      ?.where((element) =>
                          element
                              .difference(DateFormat("MMMM dd,yyyy").parse(e))
                              .inDays !=
                          0)
                      .isNotEmpty ==
                  true &&
              widget.isReserve == false) {
            pro.charterAvailableDates
                ?.where((element) => element.isAfter(DateTime.now()))
                .forEach((i) {
              if (!unAvailableDates.contains(i)) {
                unAvailableDates.add(i);
              }
            });
            // print("ADD ${pro.charterAvailableDates?.firstWhere((element) => element.difference(DateFormat("MMMM dd,yyyy").parse(e)).inDays!=0)}");
            // if(!unAvailableDates.contains(pro.charterAvailableDates?.firstWhere((element) => element.difference(DateFormat("MMMM dd,yyyy").parse(e)).inDays!=0)??now)) {
            //   unAvailableDates.add(pro.charterAvailableDates?.firstWhere((element) => element.difference(DateFormat("MMMM dd,yyyy").parse(e)).inDays!=0)??now);
            // }
          }
        });
        log("___UNAV:${unAvailableDates.map((e) => e.toString())}");
        getBookedDates();
      }
      pro.update();
    });

    super.initState();
  }

  getBookedDates() {
    var homeVm = Provider.of<HomeVm>(context, listen: false);
    homeVm.allBookings.forEach((element) {
      if (element.charterFleetDetail?.id == widget.charter?.id &&
          element.bookingStatus == BookingStatus.ongoing.index &&
          (element.schedule?.dates?.length ?? 0) > 1) {
        bookedDates = List.from(
            element.schedule?.dates?.map((e) => e.toDate()).toList() ?? []);
        pro.charterAvailableDates?.removeWhere((e) =>
            element.schedule?.dates?.contains(Timestamp.fromDate(e)) == true);
        pro.update();
        setState(() {});
      }
    });
    log("____________BOOKED DATES LEN:${bookedDates.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchVm>(builder: (context, dashProvider, _) {
      return Container(
        width: Get.width,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: TableCalendar(
          daysOfWeekStyle: DaysOfWeekStyle(
            weekendStyle: R.textStyle.helvetica().copyWith(
                fontSize: Get.width * .035, color: R.colors.whiteColor),
            weekdayStyle: R.textStyle.helvetica().copyWith(
                fontSize: Get.width * .035, color: R.colors.whiteColor),
          ),
          headerVisible: true,
          headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              formatButtonDecoration: BoxDecoration(
                  color: R.colors.whiteColor,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: R.colors.whiteColor,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: R.colors.whiteColor,
              ),
              titleTextStyle: R.textStyle.helvetica().copyWith(
                  fontSize: Get.width * .045,
                  color: R.colors.whiteColor,
                  fontWeight: FontWeight.bold)),
          firstDay: DateTime.now(),
          lastDay: kLastDay,
          focusedDay: DateTime.now(),
          calendarFormat: _calendarFormat,
          currentDay: DateTime.now(),
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              for (DateTime d in bookedDates) {
                if (day.day == d.day &&
                    day.month == d.month &&
                    day.year == d.year) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style: R.textStyle.helveticaBold().copyWith(
                          color: R.colors.deleteColor, fontSize: 12.sp),
                    ),
                  );
                }
              }

              if (pro.charterAvailableDates != null) {
                for (DateTime d in pro.charterAvailableDates!) {
                  if (day.day == d.day &&
                      day.month == d.month &&
                      day.year == d.year) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: R.textStyle.helveticaBold().copyWith(
                            color: R.colors.whiteColor, fontSize: 12.sp),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: R.textStyle
                            .helveticaBold()
                            .copyWith(color: R.colors.greyOtp, fontSize: 12.sp),
                      ),
                    );
                  }
                }
              }
              return null;
            },
          ),
          selectedDayPredicate: (day) {
            // Use values from Set to mark multiple days as selected
            return pro.selectedBookingDays?.contains(day) == true;
          },
          holidayPredicate: (day) {
            // Use values from Set to mark multiple days as selected
            return pro.charterAvailableDates?.contains(day) == true;
          },
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            log("${focusedDay}");
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            holidayDecoration: BoxDecoration(
                color: Colors.transparent, shape: BoxShape.circle),
            outsideDaysVisible: false,

            defaultTextStyle: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 12.sp),
            // rowDecoration: BoxDecoration(borderRadius: BorderRadius.circular(25),border: Border.all(color: AppColors.cream)),
            isTodayHighlighted: false,
            canMarkersOverflow: false,
            todayTextStyle: TextStyle(
                color: R.colors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.bold),
            holidayTextStyle: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 12.sp),
            selectedDecoration:
                BoxDecoration(color: R.colors.themeMud, shape: BoxShape.circle),
            selectedTextStyle: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 12.sp),

            weekendTextStyle: R.textStyle
                .helveticaBold()
                .copyWith(color: R.colors.whiteColor, fontSize: 12.sp),
            todayDecoration: BoxDecoration(
                color: Colors.transparent, shape: BoxShape.circle),
          ),
        ),
      );
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (pro.selectedBookingDays?.contains(selectedDay) == true) {
        pro.selectedBookingDays?.remove(selectedDay);
      } else {
        // DateUtil().day(DateFormat("MMMM dd,yyyy").parse(element).day) ==
        //     DateUtil().day(selectedDay.day)
        List<String> days = selectedDay.allDaysOfMonth();
        days.forEach((element) {
          if (DateFormat("yyyy-MM-dd")
                      .format(DateFormat("MMMM dd,yyyy").parse(element)) ==
                  DateFormat("yyyy-MM-dd").format(selectedDay) &&
              DateFormat("MMMM dd,yyyy")
                      .parse(element)
                      .difference(DateTime.now())
                      .inDays >=
                  0) {
            // log("_____________PARSE ${DateFormat("yyyy-MM-dd").format(DateFormat("MMMM dd,yyyy").parse(element))}");
            if (widget.isReserve ==
                    false && /*!bookedDates
                    .map((e) => DateFormat("yyyy-MM-dd").format(e))
                    .toList()
                    .contains(DateFormat("yyyy-MM-dd")
                        .format(DateFormat("MMMM dd,yyyy").parse(element))) &&*/
                unAvailableDates
                    .map((e) => DateFormat("yyyy-MM-dd").format(e))
                    .toList()
                    .contains(DateFormat("yyyy-MM-dd")
                        .format(DateFormat("MMMM dd,yyyy").parse(element)))) {
              // if (widget.type == 2) {
              //   pro.selectedBookingDays
              //       ?.add(DateFormat("MMMM dd,yyyy").parse(element));
              // } else {
              pro.selectedBookingDays?.clear();
              pro.selectedBookingDays
                  ?.add(DateFormat("MMMM dd,yyyy").parse(element));
              DateTimePickerServices.selectedStartDate =
                  DateFormat("MMMM dd,yyyy").parse(element);
              widget.onDateSelect!(true);
              // }
            } else if (widget.isReserve == true &&
                !bookedDates
                    .map((e) => DateFormat("yyyy-MM-dd").format(e))
                    .toList()
                    .contains(DateFormat("yyyy-MM-dd")
                        .format(DateFormat("MMMM dd,yyyy").parse(element))) &&
                !unAvailableDates
                    .map((e) => DateFormat("yyyy-MM-dd").format(e))
                    .toList()
                    .contains(DateFormat("yyyy-MM-dd")
                        .format(DateFormat("MMMM dd,yyyy").parse(element)))) {
              // if (widget.type == 2) {
              //   pro.selectedBookingDays
              //       ?.add(DateFormat("MMMM dd,yyyy").parse(element));
              // } else {
              pro.selectedBookingDays?.clear();
              pro.selectedBookingDays
                  ?.add(DateFormat("MMMM dd,yyyy").parse(element));
              DateTimePickerServices.selectedStartDate =
                  DateFormat("MMMM dd,yyyy").parse(element);
              widget.onDateSelect!(true);
              // }
            }
          }
        });

        // log("____SELECTED:${provider.selectedBookingDays.toList()[0]}");
      }
    });
  }
}

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
