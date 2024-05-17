import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../utils/helper.dart';

import '../resources/resources.dart';

class DateTimePickerServices {
  static DateTime selectedStartDate = DateTime.now();
  static DateTime selectEndDate = DateTime.now();
  static TimeOfDay startTime = const TimeOfDay(hour: 00, minute: 00);
  static TimeOfDay endTime = const TimeOfDay(hour: 00, minute: 00);
  static DateTime selectedStartDateTime = DateTime.now();
  static DateTime selectedStartDateTimeDB = DateTime.now();
  static DateTime selectedEndDateTimeDB = DateTime.now();

  static Future<void> selectEndTimeFunction(
      BuildContext context, TextEditingController controller , DateTime currentTime) async {
     await  DatePicker.showTime12hPicker(
      Get.context!,
      showTitleActions: true,
      currentTime: currentTime,
      locale: LocaleType.en,
      onConfirm: (selectedTime) {
        endTime = TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute,);
        controller.text = DateFormat("dd/MM/yyyy hh:mm a").format(DateTime(selectEndDate.year,
            selectEndDate.month, selectEndDate.day, endTime.hour, endTime.minute));
        selectedEndDateTimeDB = DateTime(selectEndDate.year, selectEndDate.month,
            selectEndDate.day, endTime.hour, endTime.minute);
      },
    );

  }

  static Future<void> selectStartTimeFunction(BuildContext context,
      TextEditingController controller, DateTime initialTime) async {
    await  DatePicker.showTime12hPicker(
      Get.context!,
      showTitleActions: true,
      currentTime: initialTime,
      locale: LocaleType.en,
      onConfirm: (selectedTime) {
        startTime = TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute,);
        controller.text = DateFormat("hh:mm a").format(DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            startTime.hour,
            startTime.minute));
        selectedStartDateTime = DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            startTime.hour,
            startTime.minute);
        selectedStartDateTimeDB = DateTime(
            selectedStartDate.year,
            selectedStartDate.month,
            selectedStartDate.day,
            startTime.hour,
            startTime.minute);
      },
    );
  }


  static Future<void> selectStartDateFunction(
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch:
                        Helper.createMaterialColor(R.colors.themeMud))),
            child: child!);
      },
      context: context,
      initialDate: initialDate,
      initialDatePickerMode: DatePickerMode.day,
      keyboardType: TextInputType.datetime,
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      selectedStartDate = picked;

      controller.text = DateFormat("MM/dd/yyyy").format(selectedStartDate);
      selectedStartDateTimeDB = DateTime(
          selectedStartDate.year,
          selectedStartDate.month,
          selectedStartDate.day,
          startTime.hour,
          startTime.minute);
    }
  }

  static Future<void> selectEndDateFunction(
    DateTime lastDate,
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
            data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.fromSwatch(
                    primarySwatch:
                        Helper.createMaterialColor(R.colors.themeMud))),
            child: child!);
      },
      context: context,
      initialDate: selectedStartDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: selectedStartDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      selectEndDate = picked;
    }
    controller.text = DateFormat("MM/dd/yyyy").format(selectEndDate);
    selectedStartDateTime = DateTime(selectEndDate.year, selectEndDate.month,
        selectEndDate.day, startTime.hour, startTime.minute);
    selectedEndDateTimeDB = DateTime(selectEndDate.year, selectEndDate.month,
        selectEndDate.day, endTime.hour, endTime.minute);
  }
}

int differenceInMinutes(DateTime second, DateTime first) {
  int t = first.difference(second).inMinutes;
  debugPrint(t.toString());
  return t;
}

