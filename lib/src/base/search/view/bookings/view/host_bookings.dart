// import 'dart:developer';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
// import 'package:yacht_master/constant/enums.dart';
// import 'package:yacht_master/localization/app_localization.dart';
// import 'package:yacht_master/resources/resources.dart';
// import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
// import 'package:yacht_master/src/base/home/widgets/bookings_widget.dart';
// import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
// import 'package:yacht_master/src/base/search/view/bookings/view/bookings_detail_customer.dart';
// import 'package:yacht_master/src/base/search/view/bookings/view/host_booking_detail.dart';
// import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
// import 'package:yacht_master/utils/empty_screem.dart';
// import 'package:yacht_master/utils/general_app_bar.dart';
// import 'package:yacht_master/utils/heights_widths.dart';
//
// class HostBookings extends StatefulWidget {
//   static String route="/hostBookings";
//   const HostBookings({Key? key}) : super(key: key);
//
//   @override
//   _HostBookingsState createState() => _HostBookingsState();
// }
//
// class _HostBookingsState extends State<HostBookings> {
//   List<String> tabsList=["ongoing","completed","canceled"];
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Consumer2<HomeVm,BookingsVm>(
//         builder: (context, provider, bookingsVm,_) {
//           log("__________All bookings:${provider.allBookings.length}");
//           return Scaffold(
//             backgroundColor: R.colors.black,
//             appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "host_bookings")??""),
//             body: Column(
//               children: [
//                 h2,
//                 Container(
//                   child: Row(children: List.generate(3, (index) {
//                     return tabs(tabsList[index],index,bookingsVm);
//                   }),),
//                 ),
//                 h2,
//                 Expanded(
//                     child:
//                     bookingsVm.selectedHostBookingTab==BookingStatus.ongoing.index &&
//                             provider.allBookings.
//                             where((element) => element.bookingStatus==BookingStatus.ongoing.index
//                                 && element.hostUserUid==appwrite.user.$id
//                             ).toList().isEmpty?
//                     EmptyScreen(
//                       title: "no_ongoing_booking",
//                       subtitle: "no_ongoing_booking_has_been_made_yet",
//                       img: R.images.emptyBook,
//
//                     ):
//                     bookingsVm.selectedHostBookingTab==BookingStatus.ongoing.index &&
//                             provider.allBookings.
//                             where((element) => element.bookingStatus==BookingStatus.ongoing.index
//                                 && element.hostUserUid==appwrite.user.$id
//                             ).toList().isNotEmpty?
//                     ListView(
//                       children: List.generate(provider.allBookings.
//                       where((element) => element.bookingStatus==BookingStatus.ongoing.index
//                           && element.hostUserUid==appwrite.user.$id
//                       ).toList().length,
//                               (index) {
//                             BookingsModel bookingModel=provider.allBookings.
//                             where((element) => element.bookingStatus==BookingStatus.ongoing.index  && element.hostUserUid==appwrite.user.$id).toList()[index];
//                             return Padding(
//                               padding:  EdgeInsets.symmetric(horizontal: 5.w),
//                               child: GestureDetector(
//                                 onTap: (){
//                                   Get.toNamed(HostBookingDetail.route,
//                                       arguments: {
//                                         "bookingsModel":bookingModel
//                                       });
//                                 },
//                                 child: BookingsWidget(bookings:bookingModel,index: index,
//                                   isBooking:true,isLargeView: true,
//
//                                 ),
//                               ),
//                             );
//                           }),):
//                     bookingsVm.selectedHostBookingTab==BookingStatus.completed.index &&
//                         provider.allBookings.
//                         where((element) => element.bookingStatus==BookingStatus.completed.index  && element.hostUserUid==appwrite.user.$id).toList().isEmpty?
//                     EmptyScreen(
//                       title: "no_completed_booking",
//                       subtitle: "no_bookings_has_been_completed_yet",
//                       img: R.images.emptyBook,
//
//                     ):
//                     bookingsVm.selectedHostBookingTab==BookingStatus.completed.index &&
//                         provider.allBookings.
//                         where((element) => element.bookingStatus==BookingStatus.completed.index && element.hostUserUid==appwrite.user.$id).toList().isNotEmpty?
//                     ListView(
//                       children: List.generate(provider.allBookings.
//                       where((element) => element.bookingStatus==BookingStatus.completed.index).toList().length,
//                               (index) {
//                             BookingsModel bookingModel=provider.allBookings.
//                             where((element) => element.bookingStatus==BookingStatus.completed.index).toList()[index];
//                             return Padding(
//                               padding:  EdgeInsets.symmetric(horizontal: 5.w),
//                               child: GestureDetector(
//                                 onTap: (){
//                                   Get.toNamed(HostBookingDetail.route,
//                                       arguments: {
//                                         "bookingsModel":bookingModel
//                                       });
//                                 },
//                                 child: BookingsWidget(bookings:bookingModel,index: index,
//                                   isBooking:true,isLargeView: true,
//
//                                 ),
//                               ),
//                             );
//                           }),):
//                     bookingsVm.selectedHostBookingTab==BookingStatus.canceled.index &&
//                         provider.allBookings.
//                         where((element) => element.bookingStatus==BookingStatus.canceled.index && element.hostUserUid==appwrite.user.$id).toList().isEmpty?
//                     EmptyScreen(
//                       title: "no_canceled_booking",
//                       subtitle: "no_bookings_has_been_canceled_yet",
//                       img: R.images.emptyBook,
//
//                     ):
//                     ListView(
//                       children: List.generate(provider.allBookings.
//                       where((element) => element.bookingStatus==BookingStatus.canceled.index && element.hostUserUid==appwrite.user.$id).toList().length,
//                               (index) {
//                             BookingsModel bookingModel=provider.allBookings.
//                             where((element) => element.bookingStatus==BookingStatus.canceled.index && element.hostUserUid==appwrite.user.$id).toList()[index];
//                             return Padding(
//                               padding:  EdgeInsets.symmetric(horizontal: 5.w),
//                               child: GestureDetector(
//                                 onTap: (){
//                                   Get.toNamed(HostBookingDetail.route,
//                                       arguments: {
//                                         "bookingsModel":bookingModel
//                                       });
//                                 },
//                                 child: BookingsWidget(bookings:bookingModel,index: index,
//                                   isBooking:true,isLargeView: true,
//
//                                 ),
//                               ),
//                             );
//                           }),)
//
//                 ),
//               ],
//             ),
//           );
//         }
//     );
//   }
//   Widget tabs(String title,int index,BookingsVm bookingsVm)
//   {
//     return Expanded(
//       child: GestureDetector(
//         onTap: (){
//           setState(() {
//             bookingsVm.selectedHostBookingTab=index;
//           });
//         },
//         child: Container(color: Colors.transparent,
//           child: Column(
//             children: [
//               Text(getTranslated(context, title)??"",style: R.textStyle.helveticaBold().copyWith(
//                 color: bookingsVm.selectedHostBookingTab==index?
//                 R.colors.yellowDark:R.colors.whiteColor,
//               ),),
//               Divider(color:bookingsVm.selectedHostBookingTab==index?
//               R.colors.yellowDark:R.colors.grey.withOpacity(.40),thickness: 2,height: Get.height*.03,)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
