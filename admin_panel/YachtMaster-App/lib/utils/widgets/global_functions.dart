import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:yacht_master_admin/constants/enums.dart';

class GlobalFunctions {
  static getDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  static getDateDMY(DateTime dateTime) {
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }

  static getTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static getDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy hh:mm a').format(dateTime);
  }

  static UserStatus getUserStatus({required int selectedIndex}) {
    switch (selectedIndex) {
      case 1:
        {
          log("____SATTY:${selectedIndex}____true");
          return UserStatus.active;
        }
      case 2:
        return UserStatus.blocked;
      default:
        return UserStatus.active;
    }
  }

  static RequestStatus getHostStatus({required int selectedIndex}) {
    switch (selectedIndex) {
      case 0:
        {
          log("____SATTY:${selectedIndex}____true");
          return RequestStatus.notHost;
        }
      case 1:
        return RequestStatus.requestHost;
      case 2:
        return RequestStatus.host;
      default:
        return RequestStatus.all;
    }
  }

  static int getBookingStatus({required int selectedIndex}) {
    switch (selectedIndex) {
      case 1:
        {
          return BookingStatus.completed.index;
        }
      case 2:
        return BookingStatus.cancelled.index;
      default:
        return BookingStatus.ongoing.index;
    }
  }

  static int getPaymentStatus({required int selectedIndex}) {
    switch (selectedIndex) {
      case 0:
        return PaymentPayoutsStatus.pending.index;
      case 1:
        return PaymentPayoutsStatus.paid.index;
      default:
        return PaymentPayoutsStatus.pending.index;
    }
  }

  static ReportStatusType getReportStatus({required int selectedIndex}) {
    switch (selectedIndex) {
      case 1:
        return ReportStatusType.completed;
      case 2:
        return ReportStatusType.pending;
      default:
        return ReportStatusType.pending;
    }
  }

  static PostStatus getReportTypeStatus({required int selectedIndex}) {
    switch (selectedIndex) {
      case 1:
        return PostStatus.active;
      case 2:
        return PostStatus.inActive;
      case 3:
        return PostStatus.deleted;
      default:
        return PostStatus.active;
    }
  }
}
