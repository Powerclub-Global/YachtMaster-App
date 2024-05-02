import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/home/widgets/bookings_widget.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/bookings_detail_customer.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/host_booking_detail.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class AllBookings extends StatefulWidget {
  static String route = "/allBookings";
  const AllBookings({Key? key}) : super(key: key);

  @override
  _AllBookingsState createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  List<String> tabsList = ["ongoing", "completed", "canceled"];
  List<String> userTab = ["host_bookings", "my_bookings"];

  bool isHost = false;
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var bookingsVm = Provider.of<BookingsVm>(context, listen: false);
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      isHost = args["isHost"];
      log("____________isHost:${isHost}");
      setState(() {});
      if (isHost == true) {
        bookingsVm.selectedUserTab = 0;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    isHost = args["isHost"];
    return Consumer2<HomeVm, BookingsVm>(
        builder: (context, provider, bookingsVm, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        body: Column(
          children: [
            h7,
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            width: 2, color: R.colors.grey.withOpacity(.40)))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: R.colors.whiteColor,
                          )),
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: Row(
                          children: List.generate(userTab.length, (index) {
                            return userTabsWidget(
                                userTab[index], index, bookingsVm);
                          }),
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox())
                  ],
                ),
              ),
            ),
            h2,
            Container(
              decoration: BoxDecoration(
                  color: R.colors.blackDull,
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(tabsList.length, (index) {
                  return tabs(tabsList[index], index, bookingsVm);
                }),
              ),
            ),
            h2,
            Expanded(
                child: bookingsVm.selectedUserTab == 1
                    ? myBookings(provider, bookingsVm)
                    : hostBookings(provider, bookingsVm)),
          ],
        ),
      );
    });
  }

  Widget myBookings(HomeVm provider, BookingsVm bookingVm) {
    if (bookingVm.selectedUserTab == 1 &&
        bookingVm.selectedTabIndex == BookingStatus.ongoing.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.ongoing.index &&
                element.createdBy == FirebaseAuth.instance.currentUser!.uid)
            .toList()
            .isEmpty) {
      return EmptyScreen(
        title: "no_ongoing_booking",
        subtitle: "no_ongoing_booking_has_been_made_yet",
        img: R.images.emptyBook,
      );
    } else if (bookingVm.selectedUserTab == 1 &&
        bookingVm.selectedTabIndex == BookingStatus.ongoing.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.ongoing.index &&
                element.createdBy == FirebaseAuth.instance.currentUser!.uid)
            .toList()
            .isNotEmpty) {
      return ListView(
        children: List.generate(
            provider.allBookings
                .where((element) =>
                    element.bookingStatus == BookingStatus.ongoing.index &&
                    element.createdBy == FirebaseAuth.instance.currentUser!.uid)
                .toList()
                .length, (index) {
          BookingsModel bookingModel = provider.allBookings
              .where((element) =>
                  element.bookingStatus == BookingStatus.ongoing.index &&
                  element.createdBy == FirebaseAuth.instance.currentUser!.uid)
              .toList()[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(BookingsDetail.route,
                    arguments: {"bookingsModel": bookingModel});
              },
              child: BookingsWidget(
                bookings: bookingModel,
                index: index,
                isBooking: true,
                isLargeView: true,
              ),
            ),
          );
        }),
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.completed.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.completed.index &&
                element.createdBy == FirebaseAuth.instance.currentUser!.uid)
            .toList()
            .isEmpty) {
      return EmptyScreen(
        title: "no_completed_booking",
        subtitle: "no_bookings_has_been_completed_yet",
        img: R.images.emptyBook,
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.completed.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.completed.index &&
                element.createdBy == FirebaseAuth.instance.currentUser!.uid)
            .toList()
            .isNotEmpty) {
      return ListView(
        children: List.generate(
            provider.allBookings
                .where((element) =>
                    element.bookingStatus == BookingStatus.completed.index &&
                    element.createdBy == FirebaseAuth.instance.currentUser!.uid)
                .toList()
                .length, (index) {
          BookingsModel bookingModel = provider.allBookings
              .where((element) =>
                  element.bookingStatus == BookingStatus.completed.index &&
                  element.createdBy == FirebaseAuth.instance.currentUser!.uid)
              .toList()[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(BookingsDetail.route,
                    arguments: {"bookingsModel": bookingModel});
              },
              child: BookingsWidget(
                bookings: bookingModel,
                index: index,
                isBooking: true,
                isLargeView: true,
              ),
            ),
          );
        }),
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.canceled.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.canceled.index &&
                element.createdBy == FirebaseAuth.instance.currentUser!.uid)
            .toList()
            .isEmpty) {
      return EmptyScreen(
        title: "no_canceled_booking",
        subtitle: "no_bookings_has_been_canceled_yet",
        img: R.images.emptyBook,
      );
    } else {
      return ListView(
        children: List.generate(
            provider.allBookings
                .where((element) =>
                    element.bookingStatus == BookingStatus.canceled.index &&
                    element.createdBy == FirebaseAuth.instance.currentUser!.uid)
                .toList()
                .length, (index) {
          BookingsModel bookingModel = provider.allBookings
              .where((element) =>
                  element.bookingStatus == BookingStatus.canceled.index &&
                  element.createdBy == FirebaseAuth.instance.currentUser!.uid)
              .toList()[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(BookingsDetail.route,
                    arguments: {"bookingsModel": bookingModel});
              },
              child: BookingsWidget(
                bookings: bookingModel,
                index: index,
                isBooking: true,
                isLargeView: true,
              ),
            ),
          );
        }),
      );
    }
  }

  Widget hostBookings(HomeVm provider, BookingsVm bookingVm) {
    if (bookingVm.selectedTabIndex == BookingStatus.ongoing.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.ongoing.index &&
                element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
            .toList()
            .isEmpty) {
      return EmptyScreen(
        title: "no_ongoing_booking",
        subtitle: "no_ongoing_booking_has_been_made_yet",
        img: R.images.emptyBook,
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.ongoing.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.ongoing.index &&
                element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
            .toList()
            .isNotEmpty) {
      return ListView(
        children: List.generate(
            provider.allBookings
                .where((element) =>
                    element.bookingStatus == BookingStatus.ongoing.index &&
                    element.hostUserUid ==
                        FirebaseAuth.instance.currentUser?.uid)
                .toList()
                .length, (index) {
          BookingsModel bookingModel = provider.allBookings
              .where((element) =>
                  element.bookingStatus == BookingStatus.ongoing.index &&
                  element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
              .toList()[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(HostBookingDetail.route,
                    arguments: {"bookingsModel": bookingModel});
              },
              child: BookingsWidget(
                bookings: bookingModel,
                index: index,
                isBooking: true,
                isLargeView: true,
              ),
            ),
          );
        }),
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.completed.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.completed.index &&
                element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
            .toList()
            .isEmpty) {
      return EmptyScreen(
        title: "no_completed_booking",
        subtitle: "no_bookings_has_been_completed_yet",
        img: R.images.emptyBook,
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.completed.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.completed.index &&
                element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
            .toList()
            .isNotEmpty) {
      return ListView(
        children: List.generate(
            provider.allBookings
                .where((element) =>
                    element.bookingStatus == BookingStatus.completed.index)
                .toList()
                .length, (index) {
          BookingsModel bookingModel = provider.allBookings
              .where((element) =>
                  element.bookingStatus == BookingStatus.completed.index)
              .toList()[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(HostBookingDetail.route,
                    arguments: {"bookingsModel": bookingModel});
              },
              child: BookingsWidget(
                bookings: bookingModel,
                index: index,
                isBooking: true,
                isLargeView: true,
              ),
            ),
          );
        }),
      );
    } else if (bookingVm.selectedTabIndex == BookingStatus.canceled.index &&
        provider.allBookings
            .where((element) =>
                element.bookingStatus == BookingStatus.canceled.index &&
                element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
            .toList()
            .isEmpty) {
      return EmptyScreen(
        title: "no_canceled_booking",
        subtitle: "no_bookings_has_been_canceled_yet",
        img: R.images.emptyBook,
      );
    } else {
      return ListView(
        children: List.generate(
            provider.allBookings
                .where((element) =>
                    element.bookingStatus == BookingStatus.canceled.index &&
                    element.hostUserUid ==
                        FirebaseAuth.instance.currentUser?.uid)
                .toList()
                .length, (index) {
          BookingsModel bookingModel = provider.allBookings
              .where((element) =>
                  element.bookingStatus == BookingStatus.canceled.index &&
                  element.hostUserUid == FirebaseAuth.instance.currentUser?.uid)
              .toList()[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: GestureDetector(
              onTap: () {
                Get.toNamed(HostBookingDetail.route,
                    arguments: {"bookingsModel": bookingModel});
              },
              child: BookingsWidget(
                bookings: bookingModel,
                index: index,
                isBooking: true,
                isLargeView: true,
              ),
            ),
          );
        }),
      );
    }
  }

  Widget tabs(String title, int index, BookingsVm bookingVm) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            bookingVm.selectedTabIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: R.colors.blackDull,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: bookingVm.selectedTabIndex == index
                    ? R.colors.themeMud
                    : Colors.transparent,
                width: 1.5),
          ),
          padding: EdgeInsets.symmetric(
            vertical: 1.h,
          ),
          child: Center(
            child: Column(
              children: [
                Text(
                  getTranslated(context, title) ?? "",
                  style: R.textStyle.helvetica().copyWith(
                      color: bookingVm.selectedTabIndex == index
                          ? R.colors.themeMud
                          : R.colors.whiteDull,
                      fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget userTabsWidget(String title, int index, BookingsVm bookingVm) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            bookingVm.selectedUserTab = index;
            bookingVm.selectedTabIndex = 0;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getTranslated(context, title) ?? "",
                style: R.textStyle.helvetica().copyWith(
                    color: bookingVm.selectedUserTab == index
                        ? R.colors.yellowDark
                        : R.colors.whiteColor,
                    fontSize: 12.sp,
                    fontWeight: bookingVm.selectedUserTab == index
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              h2,
              Divider(
                  color: bookingVm.selectedUserTab == index
                      ? R.colors.yellowDark
                      : Colors.transparent,
                  thickness: 2,
                  height: 0)
            ],
          ),
        ),
      ),
    );
  }
}
