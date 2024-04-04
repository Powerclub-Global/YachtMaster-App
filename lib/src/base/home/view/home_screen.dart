import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:get/get.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/home/view/help_center.dart';
import 'package:yacht_master/src/base/home/view/previous_bookings.dart';
import 'package:yacht_master/src/base/home/widgets/bookings_widget.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/bookings_detail_customer.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/host_booking_detail.dart';
import 'package:yacht_master/src/base/search/view/where_going.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class HomeView extends StatefulWidget {
  static String route = "/homeView";
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeVm>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  centerTitle: true,
                  // shape: ContinuousRectangleBorder(
                  //     borderRadius: BorderRadius.only(
                  //         bottomLeft: Radius.circular(47), bottomRight: Radius.circular(47))),
                  backgroundColor: R.colors.black,
                  expandedHeight: 220.sp,
                  // collapsedHeight: Get.height*.6,
                  floating: true,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        h9,
                        h2,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(R.images.cover,
                                        height: 168.sp)),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(WhereGoing.route);
                                  },
                                  child: Container(
                                    height: Get.height * .065,
                                    width: Get.width * .8,
                                    margin: EdgeInsets.only(
                                        bottom: Get.height * .015),
                                    decoration: AppDecorations.gradientButton(
                                        radius: 30),
                                    child: Center(
                                      child: Text(
                                        "${getTranslated(context, "start_search")?.toUpperCase()}",
                                        style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.black,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: provider.allBookings
                    .where((element) =>
                        element.createdBy ==
                            FirebaseAuth.instance.currentUser!.uid ||
                        element.hostUserUid ==
                            FirebaseAuth.instance.currentUser!.uid)
                    .toList()
                    .isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .03),
                    child: Column(children: [
                      h2,
                      GeneralWidgets.seeAllWidget(context, "bookings",
                          onTap: () {
                        Get.toNamed(AllBookings.route,
                            arguments: {"isHost": false});
                      },
                          isPadding: false,
                          isSeeAll: provider.allBookings
                                  .where((element) =>
                                      element.createdBy ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid ||
                                      element.hostUserUid ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid)
                                  .toList()
                                  .isEmpty
                              ? false
                              : true),
                      h2,
                      Expanded(
                        child: EmptyScreen(
                          title: "no_bookings",
                          subtitle: "no_bookings_has_been_completed_yet",
                          img: R.images.emptyBook,
                        ),
                      ),
                      h4,
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(HelpCenter.route);
                        },
                        child: Row(
                          children: [
                            Text(
                              "${getTranslated(context, "do_not_see_a_past_booking")}",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: Colors.white, fontSize: 12.sp),
                            ),
                            w1,
                            Text(
                              getTranslated(context, "visit_help_center") ?? "",
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.themeMud, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                      h7,
                    ]),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Get.width * .03),
                      child: Column(
                        children: [
                          h2,
                          GeneralWidgets.seeAllWidget(
                              context, "recent_bookings", onTap: () {
                            log("_____here");
                            Get.toNamed(AllBookings.route,
                                arguments: {"isHost": false});
                          },
                              isPadding: false,
                              isSeeAll: provider.allBookings
                                      .where((element) =>
                                          element.createdBy ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid ||
                                          element.hostUserUid ==
                                              FirebaseAuth
                                                  .instance.currentUser!.uid)
                                      .toList()
                                      .isEmpty
                                  ? false
                                  : true),
                          h2,
                          Column(
                            children: List.generate(
                                provider.allBookings
                                            .where((element) =>
                                                element.createdBy ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid ||
                                                element.hostUserUid ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid)
                                            .toList()
                                            .length >=
                                        3
                                    ? 3
                                    : provider.allBookings
                                        .where((element) =>
                                            element.createdBy ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid ||
                                            element.hostUserUid ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                        .toList()
                                        .length, (index) {
                              BookingsModel booking = provider.allBookings
                                  .where((element) =>
                                      element.createdBy ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid ||
                                      element.hostUserUid ==
                                          FirebaseAuth
                                              .instance.currentUser!.uid)
                                  .toList()[index];
                              return GestureDetector(
                                onTap: () {
                                  log("____here:HOST ID${booking.hostUserUid}______CURRENT:${FirebaseAuth.instance.currentUser?.uid}___CREATEDBY:${booking.createdBy}");
                                  if (booking.createdBy ==
                                      FirebaseAuth.instance.currentUser?.uid) {
                                    Get.toNamed(BookingsDetail.route,
                                        arguments: {"bookingsModel": booking});
                                  } else if (booking.hostUserUid ==
                                      FirebaseAuth.instance.currentUser?.uid) {
                                    Get.toNamed(HostBookingDetail.route,
                                        arguments: {"bookingsModel": booking});
                                  }
                                },
                                child: BookingsWidget(
                                  bookings: booking,
                                  index: index,
                                  isBooking: true,
                                  isLargeView: false,
                                ),
                              );
                            }),
                          ),
                          h4,
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(HelpCenter.route);
                            },
                            child: Row(
                              children: [
                                Text(
                                  getTranslated(context,
                                          "do_not_see_a_past_booking") ??
                                      "",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: Colors.white, fontSize: 12.sp),
                                ),
                                w1,
                                Text(
                                  getTranslated(context, "visit_help_center") ??
                                      "",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.themeMud,
                                      decoration: TextDecoration.underline,
                                      fontSize: 12.sp),
                                ),
                              ],
                            ),
                          ),
                          h7,
                        ],
                      ),
                    ),
                  )),
      );
    });
  }
}
