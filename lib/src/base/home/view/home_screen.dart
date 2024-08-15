import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../appwrite.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import 'package:get/get.dart';
import '../home_vm/home_vm.dart';
import 'help_center.dart';
import 'previous_bookings.dart';
import '../widgets/bookings_widget.dart';
import '../../search/view/bookings/model/bookings.dart';
import '../../search/view/bookings/view/bookings_detail_customer.dart';
import '../../search/view/bookings/view/host_booking_detail.dart';
import '../../search/view/where_going.dart';
import '../../../../utils/empty_screem.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';

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
                  backgroundColor: R.colors.black,
                  expandedHeight: 220.sp,
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
                        element.createdBy == appwrite.user.$id ||
                        element.hostUserUid == appwrite.user.$id)
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
                                      element.createdBy == appwrite.user.$id ||
                                      element.hostUserUid == appwrite.user.$id)
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
                                              appwrite.user.$id ||
                                          element.hostUserUid ==
                                              appwrite.user.$id)
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
                                                    appwrite.user.$id ||
                                                element.hostUserUid ==
                                                    appwrite.user.$id)
                                            .toList()
                                            .length >=
                                        3
                                    ? 3
                                    : provider.allBookings
                                        .where((element) =>
                                            element.createdBy ==
                                                appwrite.user.$id ||
                                            element.hostUserUid ==
                                                appwrite.user.$id)
                                        .toList()
                                        .length, (index) {
                              print("printing index");
                              print(index);
                              print("Printing the entire booking data");
                              print(provider.allBookings[index].toJson());
                              BookingsModel booking = provider.allBookings
                                  .where((element) =>
                                      element.createdBy == appwrite.user.$id ||
                                      element.hostUserUid == appwrite.user.$id)
                                  .toList()[index];
                              print(booking.id);
                              print("about to show bookings");
                              return InkWell(
                                onTap: () {
                                  log("____here:HOST ID${booking.hostUserUid}______CURRENT:${appwrite.user.$id}___CREATEDBY:${booking.createdBy}_____YACHTID:${booking.id}");
                                  if (booking.createdBy == appwrite.user.$id) {
                                    print(
                                        "I am here now means the booking was created bt me ");
                                    if (booking.isPending ?? false) {
                                      Helper.inSnackBar(
                                          "Pending Payment Approval",
                                          "Booking Confirmation still pending, please wait",
                                          R.colors.themeMud);
                                      return;
                                    }
                                    Get.toNamed(BookingsDetail.route,
                                        arguments: {"bookingsModel": booking});
                                  } else if (booking.hostUserUid ==
                                      appwrite.user.$id) {
                                    print("booking model was hosted by me");
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
