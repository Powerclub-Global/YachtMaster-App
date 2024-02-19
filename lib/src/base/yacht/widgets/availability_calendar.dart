import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/date_utils.dart';


class AvailabilityCalendar extends StatefulWidget {
  int type;///0, 1 SINGLE DAY 2, MULTI DAY
  List<DateTime>? selectedDates;
  bool? isReadOnly;
  CharterModel? charter;
  AvailabilityCalendar(this.charter,this.type,this.selectedDates,this.isReadOnly);

  @override
  _AvailabilityCalendarState createState() =>
      _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {


  // Using a `LinkedHashSet` is recommended due to equality comparison override
  List<DateTime> unAvailableDates=[];///GREY
  List<DateTime> blockedDates=[];///RED
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime now=DateTime.now();

  @override
  void dispose() {
    super.dispose();
  }

  var pro=Provider.of<SearchVm>(Get.context!,listen: false);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      log("_________________NOW:${now.add(Duration(days: 10)).day}");
      pro.availabilityDays = LinkedHashSet<DateTime>(
        equals: isSameDay,
        hashCode: getHashCode,
      );
      log("______________________SELECTED:${widget.selectedDates?.length}");
      if(widget.selectedDates?.isNotEmpty==true)
      {
        widget.selectedDates?.forEach((element) {
          pro.availabilityDays?.add(element);
          pro.update();
        });
      }
      log("______________________SELECTED:${pro.availabilityDays}");
      getBookedDates();
      pro.update();
    });
    super.initState();
  }
  getBookedDates()
  {
    var homeVm=Provider.of<HomeVm>(context,listen: false);
    homeVm.allBookings.forEach((element) {
      if(element.charterFleetDetail==widget.charter?.id && element.bookingStatus==BookingStatus.ongoing.index && (element.schedule?.dates?.length??0)>1)
        {

          blockedDates=List.from(element.schedule?.dates?.map((e) => e.toDate()).toList()??[]);
          pro.availabilityDays?.removeWhere((e) => element.schedule?.dates?.contains(Timestamp.fromDate(e))==true);
          pro.update();
          setState(() {});
        }
    });
    log("____________BOOKED DATES LEN:${blockedDates.length}");
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
                fontSize: Get.width * .035,
                color: R.colors.whiteColor),
            weekdayStyle:R.textStyle.helvetica().copyWith(
                fontSize: Get.width * .035,
                color: R.colors.whiteColor),),
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
                  fontSize: Get.width * .045, color: R.colors.whiteColor,
                  fontWeight: FontWeight.bold)),
          firstDay: kFirstDay,
          lastDay: kLastDay,
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              for (DateTime d in blockedDates) {
                if (day.day == d.day &&
                    day.month == d.month &&
                    day.year == d.year) {
                  return Center(
                    child: Text(
                      '${day.day}',
                      style:R.textStyle.helveticaBold().copyWith(
                          color: R.colors.deleteColor,
                          fontSize: 12.sp
                      ),
                    ),
                  );
                }
              }
              if(widget.isReadOnly==true)
                {
                  for (DateTime d in pro.availabilityDays ?? []) {
                    if (day.day == d.day &&
                        day.month == d.month &&
                        day.year == d.year) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style:R.textStyle.helveticaBold().copyWith(
                              color: R.colors.whiteColor,
                              fontSize: 12.sp
                          ),
                        ),
                      );
                    }else{
                      return Center(
                        child: Text(
                          '${day.day}',
                          style:R.textStyle.helveticaBold().copyWith(
                              color: R.colors.greyOtp,
                              fontSize: 12.sp
                          ),
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
            return  pro.availabilityDays?.contains(day)==true;
          },

          onDaySelected:widget.isReadOnly==true?null: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            holidayDecoration:
            BoxDecoration(color: R.colors.deleteColor, shape: BoxShape.circle),
            outsideDaysVisible: false,

            defaultTextStyle: R.textStyle.helveticaBold().copyWith(
                color: R.colors.whiteColor,
                fontSize: 12.sp
            ),
            // rowDecoration: BoxDecoration(borderRadius: BorderRadius.circular(25),border: Border.all(color: AppColors.cream)),
            isTodayHighlighted: true,
            canMarkersOverflow: false,
            todayTextStyle: TextStyle(
                color:widget.isReadOnly==true? R.colors.greyOtp:R.colors.whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.bold),
            holidayTextStyle:R.textStyle.helveticaBold().copyWith(
                color: R.colors.deleteColor,
                fontSize: 12.sp
            ),
            selectedDecoration:
            BoxDecoration(color: R.colors.themeMud, shape: BoxShape.circle),
            selectedTextStyle:
            R.textStyle.helveticaBold().copyWith(
                color: R.colors.whiteColor,
                fontSize: 12.sp
            ),
            weekendTextStyle: R.textStyle.helveticaBold().copyWith(
                color: R.colors.whiteColor,
                fontSize: 12.sp
            ),
            todayDecoration:
            BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
          ),
        ),
      );
    });
  }
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      // Update values in a Set
      if (pro.availabilityDays?.contains(selectedDay)==true) {
        print("Selected day $selectedDay");
        print("///////////////////////AM I");
        pro.availabilityDays?.remove(selectedDay);
      } else {
        // DateUtil().day(DateFormat("MMMM dd,yyyy").parse(element).day) ==
        //     DateUtil().day(selectedDay.day)
        log("++++++++++++++++tyoe:${widget.type}");

        List<String> days = selectedDay.allDaysOfMonth();
        days.forEach((element) {
          if (DateFormat("yyyy-MM-dd").format(DateFormat("MMMM dd,yyyy").parse(element)) ==
              DateFormat("yyyy-MM-dd").format(selectedDay)
              &&
              DateFormat("MMMM dd,yyyy")
                  .parse(element)
                  .difference(DateTime.now())
                  .inDays >= 0
          ) {
            // log("_____________PARSE ${DateFormat("yyyy-MM-dd").format(DateFormat("MMMM dd,yyyy").parse(element))}");
            if(
            !blockedDates.map((e) =>  DateFormat("yyyy-MM-dd").format(e)).toList().contains(DateFormat("yyyy-MM-dd").format(DateFormat("MMMM dd,yyyy").parse(element)))
                &&
                !unAvailableDates.map((e) =>  DateFormat("yyyy-MM-dd").format(e)).toList().contains(DateFormat("yyyy-MM-dd").format(DateFormat("MMMM dd,yyyy").parse(element))))
            {
              if(widget.type==2)
              {
                pro.availabilityDays?.add(DateFormat("MMMM dd,yyyy").parse(element));
              }
              else{
                pro.availabilityDays?.clear();
                pro.availabilityDays?.add(DateFormat("MMMM dd,yyyy").parse(element));
              }
            }
          }

        });

        // log("____SELECTED:${provider.availabilityDays.toList()[0]}");

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


