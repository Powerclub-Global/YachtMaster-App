import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';
import '../../../../resources/resources.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';

class TimePickerSheet extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime?> onDateSelect;
  const TimePickerSheet({super.key, required this.selectedDate, required this.onDateSelect});

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  DateTime? selectedTime;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectedTime = widget.selectedDate;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5.0,
        sigmaY: 5.0,
      ),
      child: Container(
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: Get.width * .07),
        decoration: BoxDecoration(
          color: R.colors.black,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            h1,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                            (states) => R.colors.blackDull.withOpacity(0.05)),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    "Cancel",
                    style: R.textStyle.helveticaBold().copyWith(color: R.colors.greyColor),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                            (states) => R.colors.blackDull.withOpacity(0.05)),
                  ),
                  onPressed: () {
                    widget.onDateSelect(selectedTime);
                    Get.back();
                  },
                  child: Text(
                    "Save",
                    style: R.textStyle.helveticaBold().copyWith(color: R.colors.themeMud),
                  ),
                )
              ],
            ),
            h3,
            TimePickerSpinner(
              locale: const Locale('en', ''),
              time: selectedTime,
              is24HourMode: false,
              isShowSeconds: false,
              itemHeight: 40,
              normalTextStyle: R.textStyle.helvetica(),
              minutesInterval: 30,
              highlightedTextStyle: R.textStyle.helveticaBold().copyWith(color: R.colors.themeMud),
              isForce2Digits: true,
              onTimeChange: (time) {
                selectedTime = time;
              },
            ),
            h1,
          ],
        ),
      ),
    );
  }
}
