import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pay/pay.dart' as pay;
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../../../constant/enums.dart';
import '../../../../../../localization/app_localization.dart';
import '../../../../../../main.dart';
import '../../../../../../resources/decorations.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../services/firebase_collections.dart';
import '../../../../../../services/stripe/stripe_service.dart';
import '../../../../../../services/time_schedule_service.dart';
import '../../../../base_view.dart';
import '../../../../home/home_vm/home_vm.dart';
import '../../../model/stripe_card_model.dart';
import '../model/bookings.dart';
import 'add_credit_card.dart';
import 'apple_store_sheet.dart';
import 'pay_with_crypto.dart';
import 'pay_with_wallet.dart';
import '../view_model/bookings_vm.dart';
import '../../../../yacht/widgets/congo_bottomSheet.dart';
import '../../../../../../utils/general_app_bar.dart';
import '../../../../../../utils/heights_widths.dart';
import '../../../../../../utils/helper.dart';

class TipPaymentMethods extends StatefulWidget {
  static String route = "/paymentTipMethods";

  const TipPaymentMethods({Key? key}) : super(key: key);

  @override
  _TipPaymentMethodsState createState() => _TipPaymentMethodsState();
}

class _TipPaymentMethodsState extends State<TipPaymentMethods> {
  double userPaidAmount = 0.0;
  String? bookingId;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      log("___INIT");
      await stripeConfig();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget paymentMethods(
      BookingsVm provider, String title, String img, int index) {
    return GestureDetector(
      onTap: () async {
        provider.selectedPaymentMethod = index;
        provider.update();
        switch (index) {
          case 0:
            provider.bookingsModel.paymentDetail?.paymentMethod =
                PaymentMethodEnum.card.index;
            provider.update();
            //await provider.onClickPaymentMethods("", context, isCompletePayment, splitAmount, userPaidAmount);
            // Get.toNamed(AddCreditCard.route);
            break;
          case 1:
            {
              Get.bottomSheet(AppleStoreSheet(
                callBack: () async {
                  // await provider.onClickPaymentMethods("", context,
                  //     isCompletePayment, splitAmount, userPaidAmount);
                },
              ), barrierColor: Colors.grey.withOpacity(.20));
            }
            break;
          case 2:
            {
              var response = await http.get(
                Uri.parse('https://rest.coinapi.io/v1/exchangerate/USD/BTC'),
                headers: {
                  HttpHeaders.authorizationHeader:
                      'D07A3A3B-7641-4158-B7F5-81A6FD8B3265',
                },
              );

              Map<String, dynamic> data = await json.decode(response.body);
              // Get.toNamed(PayWithCrypto.route, arguments: {
              //   "converRate": data['rate'],
              //   "isCompletePayment": isCompletePayment,
              //   "userPaidAmount": userPaidAmount,
              //   "splitAmount": splitAmount,
              //   "isBitcoin": true
              // });
            }
            break;
          case 3:
            // {
            //   Get.toNamed(PayWithCrypto.route, arguments: {
            //     "converRate": 1.0,
            //     "isCompletePayment": isCompletePayment,
            //     "userPaidAmount": userPaidAmount,
            //     "splitAmount": splitAmount,
            //     "isBitcoin": false
            //   });
            // }
            break;
          case 4:
            Get.toNamed(PayWithWallet.route);
        }
        provider.update();
      },
      child: Container(
        decoration: BoxDecoration(
            color: R.colors.blackDull, borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(
            horizontal: Get.width * .05, vertical: Get.height * .02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  img,
                  height: Get.height * .025,
                ),
                w3,
                Text(
                  getTranslated(context, title) ?? "",
                  style: R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteDull,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///LOADER
  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }

  Future<void> stripeConfig() async {
    try {
      Stripe.publishableKey = publishableKey ?? "";
      Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance
          .applySettings()
          .whenComplete(() => setInitialBookingData());
    } catch (e) {
      log(e.toString());
    }
  }

  void setInitialBookingData() {
    var bookingVm = Provider.of<BookingsVm>(context, listen: false);
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    bookingId = args["bookingId"];
    userPaidAmount = args["userPaidAmount"];
    setState(() {});
  }
}
