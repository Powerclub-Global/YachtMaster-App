import 'dart:developer';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:location/location.dart' as loc;
import 'package:yacht_master/utils/permission_dialog.dart';

int getPriceFromString(String text, bool isFirst) {
  return isFirst == true
      ? int.parse(text
                  .split("-")
                  .first
                  .replaceAll("\$", "")
                  .replaceAll(",", "")
                  .replaceAll(RegExp("[a-zA-Z]"), " ")
                  .removeAllWhitespace ==
              ""
          ? "-1"
          : text
              .split("-")
              .first
              .replaceAll("\$", "")
              .replaceAll(",", "")
              .replaceAll(RegExp("[a-zA-Z]"), ""))
      : int.parse(text
                  .split("-")
                  .last
                  .replaceAll("\$", "")
                  .replaceAll(",", "")
                  .replaceAll(RegExp("[a-zA-Z]"), " ")
                  .removeAllWhitespace ==
              ""
          ? "-1"
          : text
              .split("-")
              .last
              .replaceAll("\$", "")
              .replaceAll(",", "")
              .replaceAll(RegExp("[a-zA-Z]"), ""));
}

String removeSign(var text) {
  return text.toStringAsFixed(1).toString().replaceAll("-", "");
}

double percentOfAmount(double amount, double percent) {
  return amount * (percent / 100);
}

class Helper {
  static String mapApiKey = "AIzaSyB3-PXBvW4UuH10ZRBY7kd20EFcxDZksQU";

  static Future<LatLng> getLocation() async {
    print("___GET LOC");

    loc.Location location = loc.Location();
    //await location.changeSettings(accuracy: loc.LocationAccuracy.a, interval: 1000, distanceFilter: 0);
    loc.LocationData currentLocation = await location.getLocation();
    LatLng currentPosition =
        LatLng(currentLocation.latitude!, currentLocation.longitude!);

    return currentPosition;
  }

  static Future<bool?> checkPermissionStatus(PermissionStatus status) async {
    switch (status) {
      case PermissionStatus.denied:
        if (!await Permission.location.request().isGranted) {
          Get.dialog(const PermissionDialog());
        } else {
          return true;
        }
        return false;
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.restricted:
        Get.dialog(const PermissionDialog());

        return false;
      case PermissionStatus.limited:
        Get.dialog(const PermissionDialog());

        return false;
      case PermissionStatus.permanentlyDenied:
        Get.dialog(const PermissionDialog());

        return false;
      default:
        Get.dialog(const PermissionDialog());
        return false;
    }
  }

  static void toast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        fontSize: 12.sp,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  static void inSnackBar(String title, String message, Color color) {
    Get.snackbar(title, message,
        backgroundColor: color, colorText: R.colors.whiteColor);
  }

  static focusOut(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static moveFocus(BuildContext context, FocusNode fn) {
    FocusScope.of(context).requestFocus(fn);
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  double calculatePercentage(int percent, double value) {
    log("___total:${value}");
    return value * (percent / 100);
  }
// static Widget noInternetWidget({double scale = 2}) {
  //   return Center(
  //       child: Image.asset(
  //     AppImages.noInternet,
  //     scale: scale,
  //   ));
  // }

  static String numberFormatter(double price) {
    return NumberFormat.currency(symbol: '', decimalDigits: 2).format(price);
  }
}
