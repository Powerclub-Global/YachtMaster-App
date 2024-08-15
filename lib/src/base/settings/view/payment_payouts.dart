import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../appwrite.dart';
import '../../../../constant/enums.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../../services/time_schedule_service.dart';
import '../../home/home_vm/home_vm.dart';
import '../../search/view/bookings/model/bookings.dart';
import '../../search/view/bookings/view_model/bookings_vm.dart';
import '../model/payment_payouts_model.dart';
import '../view_model/settings_vm.dart';
import '../../../../utils/empty_screem.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';

class PaymentPayouts extends StatefulWidget {
  static String route="/paymentPayouts";
  const PaymentPayouts({Key? key}) : super(key: key);

  @override
  _PaymentPayoutsState createState() => _PaymentPayoutsState();
}

class _PaymentPayoutsState extends State<PaymentPayouts> {
  List<String> tabsList=["pending","paid","received"];
  int selectedTabIndex=0;
  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeVm,BookingsVm,SettingsVm>(
        builder: (context, homeVm,bookingsVm,provider,_) {
          return Scaffold(
            backgroundColor: R.colors.black,
            appBar:  GeneralAppBar.simpleAppBar(context, getTranslated(context, "payment_status")??""),
            body: Column(
              children: [
                h2,
                Container(
                  child: Row(children: List.generate(3, (index) {
                    return tabs(tabsList[index],index);
                  }),),
                ),
                h2,
                Expanded(
                    child:
                    selectedTabIndex==PaymentPayoutsStatus.pending.index &&
                        homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.ongoing.index && element.hostUserUid==appwrite.user.$id)
                            .toList().isEmpty?
                    EmptyScreen(
                      title: "no_payment",
                      subtitle: "no_payment_pending_yet",
                      img: R.images.noPayment,

                    ):
                    selectedTabIndex==PaymentPayoutsStatus.pending.index &&
                        homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.ongoing.index && element.hostUserUid==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)!="0.0")
                            .toList().isNotEmpty?
                    ListView(
                      children: List.generate( homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.ongoing.index && element.hostUserUid==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)!="0.0")
                          .toList().length,
                              (index) {
                           BookingsModel bookingModel=homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.ongoing.index && element.hostUserUid==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)!="0.0")
                               .toList()[index];
                            PaymentModel model=PaymentModel(
                              status: 0,
                              payments: bookingModel.paymentDetail?.isSplit==true?
                                  bookingModel.paymentDetail?.splitPayment?.map((e) => PaymentPayoutsModel(
                                    charterName: bookingModel.charterFleetDetail?.name,
                                    paidBy: e.userUid,price: e.amount.toString(),date: DateFormat("MMM dd, yyyy").format(bookingModel.createdAt?.toDate()??now)
                                  )).toList():[
                                PaymentPayoutsModel(
                                    charterName: bookingModel.charterFleetDetail?.name,
                                    paidBy: bookingModel.createdBy,price: bookingModel.paymentDetail?.remainingAmount.toString(),date: DateFormat("MMM dd, yyyy").format(bookingModel.createdAt?.toDate()??now)
                                )
                              ],

                            );
                            return payoutsCard(model);
                          }),):
                    selectedTabIndex==PaymentPayoutsStatus.paid.index &&
                        homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.completed.index && element.createdBy==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                            .toList().isEmpty?
                    EmptyScreen(
                      title: "no_payment",
                      subtitle: "no_payment_paid_yet",
                      img: R.images.noPayment,


                    ):
                    selectedTabIndex==PaymentPayoutsStatus.paid.index &&
                        homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.completed.index && element.createdBy==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                            .toList().isNotEmpty?
                    ListView(
                      children: List.generate(homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.completed.index && element.createdBy==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                          .toList().length,
                              (index) {
                            BookingsModel bookingModel=homeVm.allBookings.where((element) => element.bookingStatus==BookingStatus.completed.index && element.createdBy==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                                .toList()[index];
                            PaymentModel model=PaymentModel(
                              status: 0,
                              payments: bookingModel.paymentDetail?.isSplit==true?
                              bookingModel.paymentDetail?.splitPayment?.map((e) => PaymentPayoutsModel(
                                  charterName: bookingModel.charterFleetDetail?.name,
                                  paidBy: e.userUid,price: e.amount.toString(),date: DateFormat("MMM dd, yyyy").format(bookingModel.createdAt?.toDate()??now)
                              )).toList():[
                                PaymentPayoutsModel(
                                    charterName: bookingModel.charterFleetDetail?.name,
                                    paidBy: bookingModel.createdBy,price: bookingModel.paymentDetail?.paidAmount.toString(),date: DateFormat("MMM dd, yyyy").format(bookingModel.createdAt?.toDate()??now)
                                )
                              ],

                            );
                            return payoutsCard(model);
                          }),):
                    selectedTabIndex==PaymentPayoutsStatus.received.index &&
                        homeVm.allBookings.where((element) =>  element.hostUserUid==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                            .toList().isEmpty?
                    EmptyScreen(
                      title: "no_payment",
                      subtitle: "no_payment_received_yet",
                      img: R.images.noPayment,

                    ):

                  ListView(
            children: List.generate( homeVm.allBookings.where((element) =>  element.hostUserUid==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                .toList().length,
                    (index) {
                  BookingsModel bookingModel=homeVm.allBookings.where((element) =>  element.hostUserUid==appwrite.user.$id && element.paymentDetail?.remainingAmount.toStringAsFixed(1)=="0.0")
                      .toList()[index];
                  PaymentModel model=PaymentModel(
                    status: 0,
                    payments: bookingModel.paymentDetail?.isSplit==true?
                    bookingModel.paymentDetail?.splitPayment?.map((e) => PaymentPayoutsModel(
                        charterName: bookingModel.charterFleetDetail?.name,
                        paidBy: e.userUid,price: e.amount.toString(),date: DateFormat("MMM dd, yyyy").format(bookingModel.createdAt?.toDate()??now)
                    )).toList():[
                      PaymentPayoutsModel(
                          charterName: bookingModel.charterFleetDetail?.name,
                          paidBy: bookingModel.createdBy,price: bookingModel.paymentDetail?.paidAmount.toString(),date: DateFormat("MMM dd, yyyy").format(bookingModel.createdAt?.toDate()??now)
                      )
                    ],

                  );
                  return payoutsCard(model);
                }),)


                )
              ],
            ),
          );
        }
    );
  }
  Widget payoutsCard(PaymentModel model)
  {
    return Padding(
        padding:  EdgeInsets.symmetric(horizontal: 5.w),
        child: Container(
          decoration: BoxDecoration(
              color: R.colors.blackDull,
              borderRadius: BorderRadius.circular(12)
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h,
              horizontal: 3.w
          ),
          margin: EdgeInsets.only(bottom: 1.5.h),
          child:Column(
            children:List.generate(model.payments?.length??0, (paymentIndex) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(model.payments?[paymentIndex].charterName??"",
                            style: R.textStyle.helveticaBold().copyWith(
                                color: R.colors.whiteDull,
                                fontSize:13.sp
                            ),
                          ),
                          h0P5,
                          FutureBuilder(
                            future: FbCollections.user.doc(model.payments?[paymentIndex].paidBy??"").get(),
                            builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if(!snapshot.hasData)
                                {
                                  return SizedBox();
                                }
                             else{
                                return Text(snapshot.data?.get("first_name"),
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.whiteColor,
                                      fontSize:12.sp
                                  ),
                                );
                              }
                            }
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("\$${double.parse(model.payments?[paymentIndex].price??"").toStringAsFixed(2)}",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.yellowDark,
                                fontSize:13.sp
                            ),
                          ),
                          h0P5,
                          Text(model.payments?[paymentIndex].date??"",
                            style: R.textStyle.helvetica().copyWith(
                                color: R.colors.whiteColor,
                                fontSize:12.sp
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (model.payments?.length==1 ||
                      paymentIndex == (model.payments?.length??0)-1)
                    SizedBox() else Divider(color: R.colors.whiteColor,
                    height: 3.h,)
                ],
              );
            }),
          ),
        )
    );
  }
  Widget tabs(String title,int index)
  {
    return Expanded(
      child: GestureDetector(
        onTap: (){
          setState(() {
            selectedTabIndex=index;
          });
        },
        child: Container(color: Colors.transparent,
          child: Column(
            children: [
              Text(getTranslated(context, title)??"",style: R.textStyle.helveticaBold().copyWith(
                color: selectedTabIndex==index?
                R.colors.yellowDark:R.colors.whiteColor,
              ),),
              Divider(color:selectedTabIndex==index?
              R.colors.yellowDark:R.colors.grey.withOpacity(.40),thickness: 2,height: Get.height*.03,)
            ],
          ),
        ),
      ),
    );
  }
}
