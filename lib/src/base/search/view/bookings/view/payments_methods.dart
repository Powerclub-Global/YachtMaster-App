import 'dart:async';
import 'dart:developer';
import 'dart:io';
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
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/main.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/base/home/home_vm/home_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/add_credit_card.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/apple_store_sheet.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/pay_with_crypto.dart';
import 'package:yacht_master/src/base/search/view/bookings/view/pay_with_wallet.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';


class PaymentMethods extends StatefulWidget {
  static String route = "/paymentMethods";

  const PaymentMethods({Key? key}) : super(key: key);

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}
const _paymentItems = [
pay.PaymentItem(
label: 'Jessy Artman',
amount: '1.0',
status: pay.PaymentItemStatus.final_price,
)
];

class _PaymentMethodsState extends State<PaymentMethods> {
  bool isDeposit = false;
  double splitAmount = 0.0;
  double userPaidAmount = 0.0;
  BookingsModel? bookingsModel;
  bool? isCompletePayment = false;
  bool isLoading = false;
  SplitPaymentModel? splitPerson;
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
    return Consumer2<BookingsVm, HomeVm>(builder: (context, provider, homeVm, _) {
      log("_____key:${publishableKey}");
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "payment_method") ?? ""),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
            child: Column(
              children: [
                h1P5,
                Container(
                  decoration: BoxDecoration(color: R.colors.blackDull, borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: Get.width * .05, vertical: Get.height * .02),
                  child: Column(
                    children: [
                      if (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index)
                        Padding(
                          padding: EdgeInsets.only(bottom: 2.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "25% Deposit",
                                style:
                                    R.textStyle.helveticaBold().copyWith(color: R.colors.whiteColor, fontSize: 14.5.sp),
                              ),
                              Text(
                                "\$${Helper.numberFormatter(double.parse((userPaidAmount * (25 / 100)).toStringAsFixed(1)))}",
                                style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.yellowDark,
                                      fontSize: 15.sp,
                                    ),
                              ),
                            ],
                          ),
                        )
                      else
                        SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated(context, "total_amount") ?? "",
                            style: R.textStyle.helvetica().copyWith(color: R.colors.whiteColor, fontSize: 14.sp),
                          ),
                          Text(
                            "\$${Helper.numberFormatter(double.parse(userPaidAmount.toStringAsFixed(2)))}",
                            style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.yellowDark,
                                  fontSize: 15.sp,
                                ),
                          ),
                        ],
                      ),
                      if ((splitPerson != null && removeSign(splitPerson?.payWithWallet) != "0.0") ||
                          provider.bookingsModel.paymentDetail?.payWithWallet.toStringAsFixed(1) != "0.0")
                        Column(
                          children: [
                            Divider(
                              color: R.colors.grey.withOpacity(.50),
                              thickness: 1,
                              height: 2.5.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, "paid_with_wallet") ?? "",
                                  style: R.textStyle.helvetica().copyWith(color: R.colors.whiteColor, fontSize: 14.sp),
                                ),
                                Text(
                                  provider.bookingsModel.paymentDetail?.isSplit == true &&
                                          splitPerson?.payWithWallet != null
                                      ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.payWithWallet)))}"
                                      : "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.payWithWallet)))}",
                                  style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.whiteColor,
                                        fontSize: 15.sp,
                                      ),
                                ),
                              ],
                            ),
                            Divider(
                              color: R.colors.grey.withOpacity(.50),
                              thickness: 1,
                              height: 2.5.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  getTranslated(context, "remaining_amount") ?? "",
                                  style: R.textStyle.helvetica().copyWith(color: R.colors.whiteColor, fontSize: 14.sp),
                                ),
                                Text(
                                  provider.bookingsModel.paymentDetail?.isSplit == true &&
                                          provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
                                      ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                      : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                              provider.bookingsModel.paymentDetail?.payInType ==
                                                  PayType.deposit.index &&
                                              splitPerson?.depositStatus == DepositStatus.nothingPaid.index
                                          ? "\$${Helper.numberFormatter(double.parse(removeSign((splitPerson?.remainingDeposit - splitPerson?.payWithWallet))))}"
                                          : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                  provider.bookingsModel.paymentDetail?.payInType ==
                                                      PayType.deposit.index &&
                                                  isCompletePayment == true
                                              ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                              : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                      provider.bookingsModel.paymentDetail?.payInType ==
                                                          PayType.deposit.index &&
                                                      isCompletePayment == false
                                                  ? "\$${Helper.numberFormatter(double.parse((splitPerson?.remainingAmount - splitPerson?.payWithWallet).toStringAsFixed(1)))}"
                                                  : "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.remainingAmount)))}",
                                  style: R.textStyle.helveticaBold().copyWith(
                                        color: R.colors.whiteColor,
                                        fontSize: 15.sp,
                                      ),
                                )
                              ],
                            ),
                          ],
                        )
                      else
                        SizedBox(),
                    ],
                  ),
                ),
                h4,
                Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, "pay_with") ?? "",
                        style: R.textStyle
                            .helvetica()
                            .copyWith(color: R.colors.whiteColor, fontWeight: FontWeight.bold, fontSize: 15.sp),
                      ),
                      if ((provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                              removeSign(provider.bookingsModel.paymentDetail?.remainingAmount) == "0.0") ||
                          ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                  splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                  splitPerson?.depositStatus == DepositStatus.twentyFivePaid.index) &&
                              removeSign(splitPerson?.amount) == removeSign(splitPerson?.payWithWallet)))
                        SizedBox()
                      else if ((provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                              provider.bookingsModel.paymentDetail?.isSplit == false &&
                              provider.bookingsModel.paymentDetail?.remainingAmount != null &&
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                              removeSign(provider.bookingsModel.paymentDetail?.remainingAmount) != "0.0") ||
                          (provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                              provider.bookingsModel.paymentDetail?.isSplit == true &&
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                              removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount) !=
                                  "0.0") ||
                          (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                              provider.bookingsModel.paymentDetail?.isSplit == true &&
                              removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingDeposit) !=
                                  "0.0" &&
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                          (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                              provider.bookingsModel.paymentDetail?.isSplit == true &&
                              provider.bookingsModel.paymentDetail?.splitPayment?.first.depositStatus ==
                                  DepositStatus.twentyFivePaid.index &&
                              removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount) !=
                                  "0.0" &&
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                          (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                              provider.bookingsModel.paymentDetail?.isSplit == false &&
                              provider.bookingsModel.paymentDetail?.paymentStatus !=
                                  PaymentStatus.confirmBooking.index &&
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                          (provider.bookingsModel.paymentDetail?.paymentMethod == -1))
                        SizedBox()
                      else
                        GestureDetector(
                            onTap: () {
                              provider.creditCardModel.cardNum = "";
                              provider.bookingsModel.paymentDetail?.paymentMethod = -1;
                              if (isCompletePayment == false) {
                                provider.bookingsModel.paymentDetail?.paidAmount =
                                    provider.bookingsModel.paymentDetail?.paidAmount -
                                        provider.bookingsModel.paymentDetail?.payWithWallet;
                                provider.bookingsModel.paymentDetail?.remainingAmount =
                                    provider.bookingsModel.paymentDetail?.remainingAmount +
                                        provider.bookingsModel.paymentDetail?.payWithWallet;
                                provider.bookingsModel.paymentDetail?.payWithWallet = 0.0;
                                if (provider.bookingsModel.paymentDetail?.isSplit == true) {
                                  provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount =
                                      provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount +
                                          provider.bookingsModel.paymentDetail?.splitPayment?.first.payWithWallet;
                                  provider.bookingsModel.paymentDetail?.splitPayment?.first.amount =
                                      provider.bookingsModel.paymentDetail?.splitPayment?.first.amount +
                                          provider.bookingsModel.paymentDetail?.splitPayment?.first.payWithWallet;
                                  provider.bookingsModel.paymentDetail?.splitPayment?.first.payWithWallet = 0.0;

                                  provider.update();
                                }
                              }
                              setState(() {});
                            },
                            child: Image.asset(
                              R.images.edit,
                              height: Get.height * .017,
                            ))
                    ],
                  ),
                ),
                h2,
                if ((provider.bookingsModel.paymentDetail?.remainingAmount != null &&
                        removeSign(provider.bookingsModel.paymentDetail?.remainingAmount) == "0.0") ||
                    (provider.bookingsModel.paymentDetail?.isSplit == true &&
                            splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                            splitPerson?.depositStatus == DepositStatus.nothingPaid.index) &&
                        removeSign(splitPerson?.remainingDeposit) == removeSign(splitPerson?.payWithWallet))
                  Container(
                    decoration: BoxDecoration(color: R.colors.blackDull, borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .05, vertical: Get.height * .02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.appStore.index
                                  ? R.images.apple
                                  : provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.crypto.index
                                      ? R.images.crypto
                                      : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                              PaymentMethodEnum.wallet.index
                                          ? R.images.link
                                          : R.images.credit,
                              height: Get.height * .02,
                            ),
                            w2,
                            Text(
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.appStore.index
                                  ? getTranslated(context, "apple_pay") ?? ""
                                  :
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.crypto.index
                                      ? getTranslated(context, "crypto_currency") ?? ""
                                      : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                              PaymentMethodEnum.wallet.index
                                          ? getTranslated(context, "pay_with_wallet") ?? ""
                                          : (provider.creditCardModel.cardNum ?? "").obsecureCardNum(),
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize:
                                      provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.card.index
                                          ? 14.5.sp
                                          : 10.sp),
                            ),
                          ],
                        ),
                        if (isCompletePayment == true)
                          Text(
                            provider.bookingsModel.paymentDetail?.isSplit == true &&
                                    provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                            splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                            splitPerson?.depositStatus == DepositStatus.twentyFivePaid.index) &&
                                        removeSign(splitPerson?.amount) == removeSign(splitPerson?.payWithWallet))
                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.amount)))}"
                                    : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index) &&
                                            removeSign(splitPerson?.remainingDeposit) ==
                                                removeSign(splitPerson?.payWithWallet))
                                        ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit)))}"
                                        : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                provider.bookingsModel.paymentDetail?.payInType ==
                                                    PayType.deposit.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index
                                            ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit - splitPerson?.payWithWallet)))}"
                                            : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                    provider.bookingsModel.paymentDetail?.payInType ==
                                                        PayType.deposit.index
                                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                                : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                                            PaymentMethodEnum.wallet.index &&
                                                        removeSign(provider
                                                                .bookingsModel.paymentDetail?.remainingAmount) ==
                                                            "0.0"
                                                    ? "\$${Helper.numberFormatter(double.parse(provider.bookingsModel.paymentDetail?.paidAmount.toStringAsFixed(1)))}"
                                                    : "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.remainingAmount)))}",
                            style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 15.sp,
                                ),
                          )
                        else
                          Text(
                            provider.bookingsModel.paymentDetail?.isSplit == true &&
                                    provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                            splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                            splitPerson?.depositStatus == DepositStatus.twentyFivePaid.index) &&
                                        removeSign(splitPerson?.amount) == removeSign(splitPerson?.payWithWallet))
                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.amount)))}"
                                    : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index) &&
                                            removeSign(splitPerson?.remainingDeposit) ==
                                                removeSign(splitPerson?.payWithWallet))
                                        ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit)))}"
                                        : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                provider.bookingsModel.paymentDetail?.payInType ==
                                                    PayType.deposit.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index
                                            ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit - splitPerson?.payWithWallet)))}"
                                            : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                    provider.bookingsModel.paymentDetail?.payInType ==
                                                        PayType.deposit.index
                                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount - splitPerson?.payWithWallet)))}"
                                                : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                                            PaymentMethodEnum.wallet.index &&
                                                        removeSign(provider
                                                                .bookingsModel.paymentDetail?.remainingAmount) ==
                                                            "0.0"
                                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.paidAmount)))}"
                                                    : provider.bookingsModel.paymentDetail?.payInType ==
                                                                PayType.deposit.index &&
                                                            provider.bookingsModel.paymentDetail?.isSplit == false
                                                        ? "\$${Helper.numberFormatter(double.parse(removeSign((percentOfAmount(provider.bookingsModel.priceDetaill?.totalPrice ?? 0.0, 25) - provider.bookingsModel.paymentDetail?.payWithWallet))))}"
                                                        : "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.remainingAmount)))}",
                            style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 15.sp,
                                ),
                          ),
                      ],
                    ),
                  )
                else if ((provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == false &&
                        provider.bookingsModel.paymentDetail?.remainingAmount != null &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                        removeSign(provider.bookingsModel.paymentDetail?.remainingAmount) != "0.0") ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == true &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                        removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount) !=
                            "0.0") ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == true &&
                        provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingDeposit.toStringAsFixed(1) !=
                            "0.0" &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == true &&
                        provider.bookingsModel.paymentDetail?.splitPayment?.first.depositStatus ==
                            DepositStatus.twentyFivePaid.index &&
                        removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount) !=
                            "0.0" &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == false &&
                        provider.bookingsModel.paymentDetail?.paymentStatus != PaymentStatus.confirmBooking.index &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                    (provider.bookingsModel.paymentDetail?.paymentMethod == -1))
                  Column(
                    children: [
                      paymentMethods(provider, "credit_or_debit_card", R.images.credit, 0),

                      if(Platform.isIOS)...[ 
              h2,
              pay.ApplePayButton(
              paymentItems: _paymentItems,
              style: pay.ApplePayButtonStyle.black,
              type: pay.ApplePayButtonType.buy,
              width: 200,
              height: 50,
              margin: const EdgeInsets.only(top: 15.0),
              onPaymentResult: (value) {
                print(value);
              },
              onError: (error) {
                print(error);
              },
              loadingIndicator: const Center(
                child: CircularProgressIndicator(),
              ), 
              paymentConfiguration: pay.PaymentConfiguration.fromJsonString('''{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.yatchmaster.app", 
    "displayName": "Jessy Artman",
    "merchantCapabilities": [
      "3DS",
      "debit",
      "credit"
    ],
    "supportedNetworks": [
      "amex",
      "visa",
      "discover",
      "masterCard"
    ],
    "countryCode": "US",
    "currencyCode": "USD",
    "requiredBillingContactFields": null, 
    "requiredShippingContactFields": null
  }
}'''),
            ),
                      ],
                      h2,
                      paymentMethods(provider, "crypto_currency", R.images.crypto, 2),
                      h2,
                      paymentMethods(provider, "crypto_currency_usdt", R.images.crypto, 3),
                      h2,
                      paymentMethods(provider, "pay_with_wallet", R.images.link, 4),
                    ],
                  )
                else
                  Container(
                    decoration: BoxDecoration(color: R.colors.blackDull, borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: Get.width * .05, vertical: Get.height * .02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.appStore.index
                                  ? R.images.apple
                                  : provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.crypto.index
                                      ? R.images.crypto
                                      : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                              PaymentMethodEnum.wallet.index
                                          ? R.images.link
                                          : R.images.credit,
                              height: Get.height * .02,
                            ),
                            w2,
                            Text(
                              provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.appStore.index
                                  ? getTranslated(context, "apple_pay") ?? ""
                                  : provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.crypto.index
                                      ? getTranslated(context, "crypto_currency") ?? ""
                                      : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                              PaymentMethodEnum.wallet.index
                                          ? getTranslated(context, "pay_with_wallet") ?? ""
                                          : (provider.creditCardModel.cardNum ?? "").obsecureCardNum(),
                              style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize:
                                      provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.card.index
                                          ? 14.5.sp
                                          : 10.sp),
                            ),
                          ],
                        ),
                        if (isCompletePayment == true)
                          Text(
                            provider.bookingsModel.paymentDetail?.isSplit == true &&
                                    provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                            splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                            splitPerson?.depositStatus == DepositStatus.twentyFivePaid.index) &&
                                        removeSign(splitPerson?.amount) == removeSign(splitPerson?.payWithWallet))
                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.amount)))}"
                                    : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index) &&
                                            removeSign(splitPerson?.remainingDeposit) ==
                                                removeSign(splitPerson?.payWithWallet))
                                        ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit)))}"
                                        : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                provider.bookingsModel.paymentDetail?.payInType ==
                                                    PayType.deposit.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index
                                            ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit - splitPerson?.payWithWallet)))}"
                                            : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                    provider.bookingsModel.paymentDetail?.payInType ==
                                                        PayType.deposit.index
                                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                                : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                                            PaymentMethodEnum.wallet.index &&
                                                        removeSign(provider
                                                                .bookingsModel.paymentDetail?.remainingAmount) ==
                                                            "0.0"
                                                    ? "\$${Helper.numberFormatter(double.parse(provider.bookingsModel.paymentDetail?.paidAmount.toStringAsFixed(1)))}"
                                                    : "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.remainingAmount)))}",
                            style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 15.sp,
                                ),
                          )
                        else
                          Text(
                            provider.bookingsModel.paymentDetail?.isSplit == true &&
                                    provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index
                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount)))}"
                                : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                            splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                            splitPerson?.depositStatus == DepositStatus.twentyFivePaid.index) &&
                                        removeSign(splitPerson?.amount) == removeSign(splitPerson?.payWithWallet))
                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.amount)))}"
                                    : ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index) &&
                                            removeSign(splitPerson?.remainingDeposit) ==
                                                removeSign(splitPerson?.payWithWallet))
                                        ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit)))}"
                                        : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                provider.bookingsModel.paymentDetail?.payInType ==
                                                    PayType.deposit.index &&
                                                splitPerson?.depositStatus == DepositStatus.nothingPaid.index
                                            ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingDeposit - splitPerson?.payWithWallet)))}"
                                            : provider.bookingsModel.paymentDetail?.isSplit == true &&
                                                    provider.bookingsModel.paymentDetail?.payInType ==
                                                        PayType.deposit.index
                                                ? "\$${Helper.numberFormatter(double.parse(removeSign(splitPerson?.remainingAmount - splitPerson?.payWithWallet)))}"
                                                : provider.bookingsModel.paymentDetail?.paymentMethod ==
                                                            PaymentMethodEnum.wallet.index &&
                                                        removeSign(provider
                                                                .bookingsModel.paymentDetail?.remainingAmount) ==
                                                            "0.0"
                                                    ? "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.paidAmount)))}"
                                                    : provider.bookingsModel.paymentDetail?.payInType ==
                                                                PayType.deposit.index &&
                                                            provider.bookingsModel.paymentDetail?.isSplit == false
                                                        ? "\$${Helper.numberFormatter(double.parse(removeSign((percentOfAmount(provider.bookingsModel.priceDetaill?.totalPrice ?? 0.0, 25) - provider.bookingsModel.paymentDetail?.payWithWallet))))}"
                                                        : "\$${Helper.numberFormatter(double.parse(removeSign(provider.bookingsModel.paymentDetail?.remainingAmount ?? 0)))}",
                            style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.whiteColor,
                                  fontSize: 15.sp,
                                ),
                          ),
                      ],
                    ),
                  ),
                Spacer(),
                if ((provider.bookingsModel.paymentDetail?.remainingAmount != null &&
                        removeSign(provider.bookingsModel.paymentDetail?.remainingAmount) == "0.0") ||
                    ((provider.bookingsModel.paymentDetail?.isSplit == true &&
                            splitPerson?.paymentMethod == PaymentMethodEnum.wallet.index &&
                            splitPerson?.depositStatus == DepositStatus.nothingPaid.index) &&
                        removeSign(splitPerson?.remainingDeposit) == removeSign(splitPerson?.payWithWallet)))
                  GestureDetector(
                    onTap: () async {
                      startLoader();
                      await provider.onClickPaymentMethods("", context, isCompletePayment, splitAmount, userPaidAmount);
                      stopLoader();
                    },
                    child: Container(
                      height: Get.height * .065,
                      width: Get.width * .8,
                      decoration: AppDecorations.gradientButton(radius: 30),
                      child: Center(
                        child: Text(
                          "${getTranslated(context, "pay_now")?.toUpperCase()}",
                          style: R.textStyle
                              .helvetica()
                              .copyWith(color: R.colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
                else if ((provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == false &&
                        provider.bookingsModel.paymentDetail?.remainingAmount != null &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                        removeSign(provider.bookingsModel.paymentDetail?.remainingAmount) != "0.0") ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.fullPay.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == true &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index &&
                        removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingAmount) !=
                            "0.0") ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == true &&
                        removeSign(provider.bookingsModel.paymentDetail?.splitPayment?.first.remainingDeposit) !=
                            "0.0" &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                    (provider.bookingsModel.paymentDetail?.payInType == PayType.deposit.index &&
                        provider.bookingsModel.paymentDetail?.isSplit == false &&
                        provider.bookingsModel.paymentDetail?.paymentStatus != PaymentStatus.confirmBooking.index &&
                        provider.bookingsModel.paymentDetail?.paymentMethod == PaymentMethodEnum.wallet.index) ||
                    (provider.bookingsModel.paymentDetail?.paymentMethod == -1))
                  SizedBox()
                else
                  GestureDetector(
                    onTap: () async {
                      startLoader();
                      await provider.onClickPaymentMethods("", context, isCompletePayment, splitAmount, userPaidAmount);
                      stopLoader();
                    },
                    child: Container(
                      height: Get.height * .065,
                      width: Get.width * .8,
                      decoration: AppDecorations.gradientButton(radius: 30),
                      child: Center(
                        child: Text(
                          "${getTranslated(context, "pay_now")?.toUpperCase()}",
                          style: R.textStyle
                              .helvetica()
                              .copyWith(color: R.colors.black, fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                h4,
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget paymentMethods(BookingsVm provider, String title, String img, int index) {
    return GestureDetector(
      onTap: () async {
        provider.selectedPaymentMethod = index;
        provider.update();
        switch (index) {
          case 0:
            provider.bookingsModel.paymentDetail?.paymentMethod = PaymentMethodEnum.card.index;
            provider.update();
            // await provider.onClickPaymentMethods("", context, isCompletePayment, splitAmount, userPaidAmount);
            // Get.toNamed(AddCreditCard.route);
            break;
          case 1:
            {
              Get.bottomSheet(AppleStoreSheet(
                callBack: () async {
                  await provider.onClickPaymentMethods("", context, isCompletePayment, splitAmount, userPaidAmount);
                },
              ), barrierColor: Colors.grey.withOpacity(.20));
            }
            break;
          case 2:
            {
                  Get.toNamed(PayWithCrypto.route, arguments: {
                "isCompletePayment": isCompletePayment,
                "userPaidAmount": userPaidAmount,
                "splitAmount": splitAmount,
                "isBitcoin": true
              });
            }
            break;
          case 3:
                  {
              Get.toNamed(PayWithCrypto.route, arguments: {
                "isCompletePayment": isCompletePayment,
                "userPaidAmount": userPaidAmount,
                "splitAmount": splitAmount,
                "isBitcoin": false
              });
            }
            break;
          case 4:
            Get.toNamed(PayWithWallet.route);
        }
        provider.update();
      },
      child: Container(
        decoration: BoxDecoration(color: R.colors.blackDull, borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: Get.width * .05, vertical: Get.height * .02),
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

  Future<void> stripeConfig()
  async {
    try {
      Stripe.publishableKey = publishableKey ?? "";
      Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance.applySettings().whenComplete(() => setInitialBookingData());
    }  catch (e) {
      log(e.toString());
    }
  }
  void setInitialBookingData()
  {
    var bookingVm = Provider.of<BookingsVm>(context, listen: false);
    var args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    isDeposit = args["isDeposit"];
    bookingsModel = args["bookingsModel"];
    isCompletePayment = args["isCompletePayment"];
    bookingVm.selectedPaymentMethod = -1;
    if (bookingVm.bookingsModel.paymentDetail?.isSplit == true) {
      splitPerson = bookingVm.bookingsModel.paymentDetail?.splitPayment
          ?.where((element) => element.userUid == FirebaseAuth.instance.currentUser?.uid)
          .first;
      splitPerson?.payWithWallet = splitPerson?.payWithWallet ?? 0.0;
    }
    if (isCompletePayment == true) {
      bookingVm.bookingsModel = bookingsModel ?? BookingsModel();
      bookingVm.creditCardModel.cardNum = bookingVm.bookingsModel.paymentDetail?.currentUserCardNum;
      bookingVm.selectedPaymentMethod = bookingVm.bookingsModel.paymentDetail?.paymentMethod ?? -1;

      if (bookingVm.bookingsModel.paymentDetail?.isSplit == true) {
        bookingVm.bookingsModel.paymentDetail?.paymentMethod = -1;
        splitPerson = bookingVm.bookingsModel.paymentDetail?.splitPayment
            ?.where((element) => element.userUid == FirebaseAuth.instance.currentUser?.uid)
            .toList()
            .first;
        bookingVm.selectedPaymentMethod = splitPerson?.paymentMethod ?? -1;
        bookingVm.creditCardModel.cardNum = splitPerson?.currentUserCardNum;
      }
      bookingVm.update();
    }
    else {
      bookingsModel?.paymentDetail?.remainingAmount = bookingsModel?.priceDetaill?.totalPrice;
    }
    if (bookingsModel?.paymentDetail?.isSplit == true &&
        bookingsModel?.paymentDetail?.splitPayment?.isNotEmpty == true) {
      splitAmount = splitPerson?.amount ?? 0.0;
      if (removeSign(splitPerson?.remainingAmount) == "0.0" && isCompletePayment == false) {
        splitPerson?.remainingAmount = splitPerson?.amount;
      }
    }
    else {
      splitAmount = bookingsModel?.priceDetaill?.totalPrice ?? 0.0;
    }
    userPaidAmount = bookingsModel?.priceDetaill?.totalPrice ?? 0.0;
    bookingsModel?.paymentDetail?.paidAmount = bookingVm.bookingsModel.paymentDetail?.paidAmount ?? 0.0;
    bookingsModel?.paymentDetail?.payWithWallet = bookingVm.bookingsModel.paymentDetail?.payWithWallet ?? 0.0;
    setState(() {});
  }
  // Future<void> getCards()
  // async {
  //   Map<String, dynamic>? result=await  StripeService().getCard(secretKey: secretKey??"", customerID: context.read<AuthVm>().userModel?.stripeCustomerID ?? "", );
  //   log("____RESULT:${result}");
  // }
}
