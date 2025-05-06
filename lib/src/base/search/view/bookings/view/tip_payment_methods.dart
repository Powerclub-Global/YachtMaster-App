import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../../../../constant/enums.dart';
import '../../../../../../localization/app_localization.dart';
import '../../../../../../main.dart';
import '../../../../../../resources/resources.dart';
import 'apple_store_sheet.dart';
import 'pay_with_wallet.dart';
import '../view_model/bookings_vm.dart';
import '../../../../../../utils/heights_widths.dart';

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
    BookingsVm provider,
    String title,
    String img,
    int index,
  ) {
    return GestureDetector(
      onTap: () async {
        provider.selectedPaymentMethod = index;
        provider.update();
        switch (index) {
          case 0:
            provider.bookingsModel.paymentDetail?.paymentMethod =
                PaymentMethodEnum.card.index;
            provider.update();
            
            break;
          case 1:
            {
              Get.bottomSheet(
                AppleStoreSheet(
                  callBack: () async {
                    
                  },
                ),
                barrierColor: Colors.grey.withValues(alpha: .20),
              );
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
              
            }
            break;
          case 3:
            break;
          case 4:
            Get.toNamed(PayWithWallet.route);
        }
        provider.update();
      },
      child: Container(
        decoration: BoxDecoration(
          color: R.colors.blackDull,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Get.width * .05,
          vertical: Get.height * .02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(img, height: Get.height * .025),
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
      await Stripe.instance.applySettings().whenComplete(
        () => setInitialBookingData(),
      );
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
