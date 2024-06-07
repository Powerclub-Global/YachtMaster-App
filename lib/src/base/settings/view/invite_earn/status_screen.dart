import 'dart:convert';

import 'package:bulleted_list/bulleted_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../appwrite.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../../main.dart';
import '../../../../../resources/decorations.dart';
import '../../../../../resources/resources.dart';
import '../../../../../services/firebase_collections.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../../services/time_schedule_service.dart';
import '../../../../auth/view_model/auth_vm.dart';
import '../../../home/home_vm/home_vm.dart';
import '../../../search/view/bookings/model/bookings.dart';
import '../../../search/view/bookings/view/host_booking_detail.dart';
import '../become_verified.dart';
import 'withdraw_money.dart';
import '../../../../../utils/heights_widths.dart';
import '../../../../../utils/helper.dart';
import '../../../../../utils/zbot_toast.dart';

class StatusScreen extends StatefulWidget {
  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StripeService stripe = StripeService();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthVm, HomeVm>(builder: (context, authVm, homeVm, _) {
      print('Wallet Amount type: ${authVm.wallet?.amount}');
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              h1P5,
              Container(
                width: Get.width,
                decoration:
                    AppDecorations.buttonDecoration(R.colors.blackDull, 12),
                padding: EdgeInsets.symmetric(vertical: 2.5.h),
                child: Column(
                  children: [
                    SizedBox(
                      width: Get.width * .7,
                      child: Text(
                        getTranslated(context, "amount_in_wallet") ?? "",
                        style: R.textStyle.helvetica().copyWith(
                            height: 1.5, color: Colors.white, fontSize: 10.sp),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    h1P5,
                    Text(
                      "\$ ${authVm.wallet?.amount.toStringAsFixed(2) ?? "0.00"}",
                      style: R.textStyle
                          .helvetica()
                          .copyWith(color: Colors.white, fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  ZBotToast.loadingShow();
                  var data =
                      await db.collection("users").doc(appwrite.user.$id).get();
                  var data1 = data.data();
                  var inviteStatus = data1!["invite_status"];
                  if (inviteStatus == 2) {
                    var connectedAccount = await FbCollections
                        .connected_accounts
                        .where('uid', isEqualTo: authVm.userModel!.uid)
                        .get();
                    if (connectedAccount.docs.isNotEmpty) {
                      Map<String, dynamic> connected_account_id_data =
                          connectedAccount.docs.first.data()
                              as Map<String, dynamic>;
                      String connectedAccountId =
                          connected_account_id_data['account_id'];
                      await stripe.checkDetailsSubmitted(
                          context, false, connectedAccountId);
                    } else {
                      ZBotToast.loadingClose();
                      Get.bottomSheet(Container(
                        color: Colors.black,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                getTranslated(context, "first_time_intro")!,
                                softWrap: true,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                getTranslated(context, "read_instructions")!,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SingleChildScrollView(
                                child: BulletedList(listItems: [
                                  getTranslated(context,
                                      "first_time_intro_bullet_text_1")!,
                                  getTranslated(context,
                                      "first_time_intro_bullet_text_2")!,
                                  getTranslated(context,
                                      "first_time_intro_bullet_text_3")!
                                ]),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  ZBotToast.loadingShow();
                                  String accountId =
                                      await stripe.createStripeConnectedAccount(
                                          authVm.userModel!.uid!);
                                  print("connected account made");
                                  if (accountId == 'internet error') {
                                    // ignore: use_build_context_synchronously
                                    Get.dialog(AlertDialog(
                                        content: Text(getTranslated(context,
                                            "no_internet_onboarding")!)));
                                    return;
                                  }
                                  print("connected account Id");
                                  print(accountId);
                                  print("about to make account link");

                                  String accountLink =
                                      await stripe.createAccountLink(accountId);
                                  if (accountLink == 'internet error') {
                                    // ignore: use_build_context_synchronously
                                    Get.dialog(AlertDialog(
                                      content: Text(getTranslated(
                                          context, "no_internet_onboarding")!),
                                    ));
                                    return;
                                  }
                                  ZBotToast.loadingClose();
                                  launchUrl(Uri.parse(accountLink));
                                },
                                child: Container(
                                  height: Get.height * .05,
                                  width: Get.width * .65,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 2.h),
                                  decoration:
                                      AppDecorations.gradientButton(radius: 30),
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, "proceed") ?? "",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.black,
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ));
                    }
                  } else if (inviteStatus == 1) {
                    ZBotToast.showToastError(
                        message:
                            "Please wait your request to be verified for earnings in process");
                  } else {
                    Get.toNamed(BecomeVerified.route);
                  }
                },
                child: Container(
                  height: Get.height * .05,
                  width: Get.width * .65,
                  margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  decoration: AppDecorations.gradientButton(radius: 30),
                  child: Center(
                    child: Text(
                      getTranslated(context, "withdraw_money") ?? "",
                      style: R.textStyle.helvetica().copyWith(
                          color: R.colors.black,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              h2,
              Row(
                children: [
                  Text(
                    getTranslated(context, "history") ?? "",
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: Colors.white, fontSize: 13.sp),
                  ),
                ],
              ),
              h2,
              Expanded(
                child: ListView(
                    children:
                        List.generate(homeVm.walletHistory.length, (index) {
                  if (homeVm.walletHistory[index]['type'] ==
                      'CashOut_Booking') {
                    return referralHistory(
                        homeVm.walletHistory[index]['data']['charter_name'],
                        homeVm.walletHistory[index]['data']['host_userId'],
                        "- \$ ${homeVm.walletHistory[index]['data']['amount']}",
                        DateTime.parse(
                            homeVm.walletHistory[index]['data']['created_at']));
                  } else if (homeVm.walletHistory[index]['type'] ==
                      'CashIn_Booking') {
                    return CashInBookingWidget(
                        homeVm.walletHistory[index]['data']['guest_username'],
                        homeVm.walletHistory[index]['data']['guest_image_url'],
                        "+ \$ ${homeVm.walletHistory[index]['data']['amount']}",
                        DateTime.parse(
                            homeVm.walletHistory[index]['data']['created_at']),
                        homeVm.walletHistory[index]['data']['booking_id']);
                  } else {
                    return CashInInviteWidget(
                        homeVm.walletHistory[index]['data']['invited_username'],
                        homeVm.walletHistory[index]['data']
                            ['invited_image_url'],
                        "+ \$ ${homeVm.walletHistory[index]['data']['amount']}",
                        DateTime.parse(
                            homeVm.walletHistory[index]['data']['created_at']));
                  }
                })),
              ),
              h3
            ],
          ),
        ),
      );
    });
  }

  Widget CashInInviteWidget(
      String title, String imageUrl, String amount, DateTime date) {
    return Container(
      width: Get.width,
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: AppDecorations.buttonDecoration(R.colors.blackDull, 12),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
                radius: 25,
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalize(title),
                    style: R.textStyle.helvetica().copyWith(
                        height: 1.5,
                        color: R.colors.whiteDull,
                        fontSize: 13.sp),
                    textAlign: TextAlign.center,
                  ),
                  h0P6,
                  Container(
                    height: 20,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color.fromARGB(255, 195, 147, 5),
                        border: Border.all(
                            color: Color.fromARGB(255, 255, 206, 59))),
                    child: Center(
                        child: Text("Invite",
                            style: TextStyle(
                                fontSize: 8.sp, color: R.colors.whiteColor))),
                  )
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: R.textStyle.helveticaBold().copyWith(
                    height: 1.5, color: R.colors.themeMud, fontSize: 13.sp),
                textAlign: TextAlign.center,
              ),
              h0P6,
              Text(
                "${date.formateDateMDY()}",
                style: R.textStyle
                    .helvetica()
                    .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String capitalize(String s) {
  if (s == null || s.isEmpty) {
    return s;
  }
  return s[0].toUpperCase() + s.substring(1);
}

Widget CashInBookingWidget(String title, String imageUrl, String amount,
    DateTime date, String bookingId) {
  return Column(
    children: [
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          var doc = await FbCollections.bookings.doc(bookingId).get();
          BookingsModel bookingsModel = BookingsModel.fromJson(doc.data());
          Get.toNamed(HostBookingDetail.route, arguments: {
            "bookingsModel": bookingsModel,
          });
        },
        child: Ink(
          width: Get.width,
          decoration: AppDecorations.buttonDecoration(R.colors.blackDull, 12),
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(imageUrl),
                    radius: 25,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalize(title),
                        style: R.textStyle.helvetica().copyWith(
                            height: 1.5,
                            color: R.colors.whiteDull,
                            fontSize: 13.sp),
                        textAlign: TextAlign.center,
                      ),
                      h0P6,
                      Container(
                        height: 20,
                        width: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromARGB(255, 195, 147, 5),
                            border: Border.all(
                                color: Color.fromARGB(255, 255, 206, 59))),
                        child: Center(
                            child: Text("Booking",
                                style: TextStyle(
                                    fontSize: 8.sp,
                                    color: R.colors.whiteColor))),
                      )
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: R.textStyle.helveticaBold().copyWith(
                        height: 1.5, color: R.colors.themeMud, fontSize: 13.sp),
                    textAlign: TextAlign.center,
                  ),
                  h0P6,
                  Text(
                    "${date.formateDateMDY()}",
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 1.5.h,
      )
    ],
  );
}

Widget referralHistory(
    String title, String subTitle, String amount, DateTime date) {
  return Container(
    width: Get.width,
    margin: EdgeInsets.only(bottom: 1.5.h),
    decoration: AppDecorations.buttonDecoration(R.colors.blackDull, 12),
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: R.textStyle.helvetica().copyWith(
                  height: 1.5, color: R.colors.whiteDull, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            h0P6,
            FutureBuilder(
                future: FbCollections.user.doc(subTitle).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return SizedBox();
                  } else {
                    return Text(
                      snapshot.data?.get("first_name") ?? "",
                      style: R.textStyle
                          .helveticaBold()
                          .copyWith(color: R.colors.whiteDull, fontSize: 11.sp),
                    );
                  }
                }),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: R.textStyle.helveticaBold().copyWith(
                  height: 1.5, color: R.colors.themeMud, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            h0P6,
            Text(
              "${date.formateDateMDY()}",
              style: R.textStyle
                  .helvetica()
                  .copyWith(color: R.colors.whiteColor, fontSize: 10.sp),
            ),
          ],
        ),
      ],
    ),
  );
}
