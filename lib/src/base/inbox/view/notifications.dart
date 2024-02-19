import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/inbox/model/notification_model.dart';
import 'package:yacht_master/src/base/inbox/view_model/inbox_vm.dart';
import 'package:yacht_master/src/base/profile/view/host_profile.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/bookings_detail_customer.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/host_booking_detail.dart';
import 'package:yacht_master/src/base/settings/view/become_a_host.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InboxVm>(
        builder: (context, provider, _) {
          return provider.hostNotificationsList.isEmpty ?
          Center(
            child: SizedBox(height: Get.height*.7,
              child: EmptyScreen(
                title: "no_notification",
                subtitle: "no_notification_has_been_received_yet",
                img: R.images.noNotification,
              ),
            ),
          ):
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * .04,vertical: 2.h),
            child: ListView(
              padding: EdgeInsets.all(0),
                children:provider.hostNotificationsList.map((e) =>
                    GestureDetector(
                      onTap: () async {
                        if(e.type == 0){
                          if(context.read<AuthVm>().userModel?.requestStatus==RequestStatus.host) {
                            Get.toNamed(HostProfile.route);
                          }else{
                            Get.toNamed(BecomeHost.route);
                          }
                        } else if(e.type == 1){
                          var doc=await FbCollections.bookings.doc(e.bookingId).get();
                          BookingsModel bookingsModel=BookingsModel.fromJson(doc.data());

                          setState(() {});
                          e.hostUserId==FirebaseAuth.instance.currentUser?.uid?
                          Get.toNamed(HostBookingDetail.route,
                              arguments: {
                                "bookingsModel":bookingsModel,
                              }):
                          Get.toNamed(BookingsDetail.route,
                              arguments: {
                                "bookingsModel":bookingsModel,
                              });
                        }
                      },
                      child: notificationHeads(e,
                          isDivider:provider.hostNotificationsList.indexOf(e)==provider.hostNotificationsList.length-1?false:true),
                    )).toList()),
          );
        }
    );
  }
  Widget notificationHeads(NotificationModel notificationModel,{bool? isDivider=true}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                    decoration:BoxDecoration(
                      color: R.colors.blackDull,
                  shape: BoxShape.circle
                    ),child: SizedBox(height:15.sp,child: Image.asset(R.images.bell,))),
                w2,
                SizedBox(width: Get.width*.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationModel.title??"",
                        style: R.textStyle.helvetica().copyWith(
                          color: R.colors.whiteColor,
                          fontSize: 13.sp,height: 1.3
                        ),
                      ),
                      h0P5,
                      Text(
                        notificationModel.text??"",
                        style: R.textStyle.helvetica().copyWith(
                            color: R.colors.whiteDull,fontWeight: FontWeight.bold,
                            fontSize: 10.sp,height: 1.1
                        ),maxLines: 3,overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
        if (isDivider==false) SizedBox() else Divider(
          color: R.colors.grey.withOpacity(.40),
          thickness: 2,
          height: Get.height * .035,
        )
      ],
    );
  }

}
