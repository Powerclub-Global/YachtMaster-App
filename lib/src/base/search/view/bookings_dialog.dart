import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/date_picker_services.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/utils/extensions.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class BookingsDialog extends StatefulWidget {
  final CharterModel charter;
  const BookingsDialog({super.key, required this.charter});

  @override
  State<BookingsDialog> createState() => _BookingsDialogState();
}

class _BookingsDialogState extends State<BookingsDialog> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeVm>(builder: (context, homeVm, _) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: R.colors.black,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: R.colors.black.withOpacity(0.16),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                h2,
                Text(
                  "This Charter is already booked on the following dates and time",
                  textAlign: TextAlign.center,
                  style: R.textStyle.helveticaBold().copyWith(
                        fontSize: 14.sp,
                        color: R.colors.whiteColor,
                      ),
                ),
                h2,
                ListView(
                  shrinkWrap: true,
                  children: List.generate(
                      homeVm.allBookings
                          .where((element) =>
                              element.charterFleetDetail?.id ==
                              widget.charter.id && element.bookingStatus == 0)
                          .length,
                      (index) => bookingWidget(homeVm.allBookings
                          .where((element) =>
                              element.charterFleetDetail?.id ==
                              widget.charter.id && element.bookingStatus == 0)
                          .toList()[index]
                          .schedule!)),
                ),
                h2,
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => R.colors.blackDull.withOpacity(0.05)),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    "Back",
                    style: R.textStyle.helveticaBold().copyWith(),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget bookingWidget(BookingScheduleModel bookings) {
    if ((DateTimePickerServices.selectedStartDateTimeDB.add(Duration(days:  2)).isBetween(
                bookings.dates!.first.toDate(),
                bookings.dates!.first.toDate().add(Duration(days: 2))) ??
            true) &&
        (DateTimePickerServices.selectedStartDateTimeDB.add(Duration(days: 2)).isBetween(
            bookings.dates!.last.toDate(),
            bookings.dates!.last.toDate().add(Duration(days: 2))) ??
            true) ||
        (DateTimePickerServices.selectedEndDateTimeDB.add(Duration(days: 2)).isBetween(
            bookings.dates!.first.toDate(),
            bookings.dates!.first.toDate().add(Duration(days: 2))) ??
            true) &&
        (DateTimePickerServices.selectedEndDateTimeDB.add(Duration(days: 2)).isBetween(
                bookings.dates!.last.toDate(),
                bookings.dates!.last.toDate().add(Duration(days: 2))) ??
            true)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          "• ${DateFormat("dd/MM/yyyy hh:mm a").format(bookings.dates!.first.toDate())} - ${DateFormat("dd/MM/yyyy hh:mm a").format(bookings.dates!.last.toDate())}",
          style: R.textStyle
              .helvetica()
              .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
