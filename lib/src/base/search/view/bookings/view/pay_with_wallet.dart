import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/base_view.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/search/view/search_screen.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';

class PayWithWallet extends StatefulWidget {
  static String route = "/payWithWallet";
  bool isTip;
  double amount = 0.0;
  PayWithWallet({Key? key, this.isTip = false}) : super(key: key);

  @override
  _PayWithWalletState createState() => _PayWithWalletState();
}

class _PayWithWalletState extends State<PayWithWallet> {
  TextEditingController cardNumCon = TextEditingController();
  TextEditingController accountName = TextEditingController();
  TextEditingController amountCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  FocusNode cardNumFn = FocusNode();
  FocusNode accountNameFn = FocusNode();
  FocusNode amountFn = FocusNode();
  FocusNode nameFn = FocusNode();
  final formKey = GlobalKey<FormState>();
  double walletAmount = 0.0;
  SplitPaymentModel? splitPerson;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final Map<String, dynamic> arguments = Get.arguments;

      widget.isTip = arguments['isTip'] ?? false;
      widget.amount = arguments['amount'] ?? 0.0;

      var bookingsVm = Provider.of<BookingsVm>(context, listen: false);
      var authVm = Provider.of<AuthVm>(context, listen: false);
      if (bookingsVm.bookingsModel.paymentDetail?.isSplit == true) {
        splitPerson = bookingsVm.bookingsModel.paymentDetail?.splitPayment
            ?.where((element) =>
                element.userUid == FirebaseAuth.instance.currentUser?.uid)
            .first;
      }
      walletAmount = double.parse(authVm.wallet?.amount.toString() ?? "0.0");
      log("_________________WALLET AMOUNT:${authVm.wallet?.amount.toString()}____");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTip = widget.isTip;
    return Consumer<BookingsVm>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: R.colors.black,
        appBar: GeneralAppBar.simpleAppBar(context,
            "${getTranslated(context, "pay_with_wallet").toString().capitalize}"),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Get.width * .05, vertical: Get.height * .02),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              height: 1.5,
                              color: Colors.white,
                              fontSize: 10.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      h1P5,
                      Text(
                        "\$ ${walletAmount.toStringAsFixed(2)}",
                        style: R.textStyle
                            .helvetica()
                            .copyWith(color: Colors.white, fontSize: 18.sp),
                      ),
                    ],
                  ),
                ),
                h2,
                if (!isTip) ...[
                  Text(
                    getTranslated(context, "amount_you_want_to_pay") ?? "",
                    style:
                        R.textStyle.helvetica().copyWith(color: Colors.white),
                  ),
                  h3,
                  TextFormField(
                      controller: amountCon,
                      focusNode: amountFn,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                      ],
                      onFieldSubmitted: (value) {
                        Helper.moveFocus(context, cardNumFn);
                      },
                      validator: (val) =>
                          FieldValidator.validateAmount(amountCon.text),
                      decoration: InputDecoration(
                        errorStyle: R.textStyle
                            .helvetica()
                            .copyWith(color: R.colors.redColor, fontSize: 9.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        hintText: getTranslated(context, "amount"),
                        hintStyle:
                            R.textStyle.helvetica().copyWith(fontSize: 12.sp),
                        fillColor: R.colors.whiteColor,
                        filled: true,
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: R.colors.whiteColor,
                            )),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: R.colors.whiteColor)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: R.colors.whiteColor)),
                      )),
                ] else ...[
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
                            getTranslated(context, "money2pay") ?? "",
                            style: R.textStyle.helvetica().copyWith(
                                height: 1.5,
                                color: Colors.white,
                                fontSize: 10.sp),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        h1P5,
                        Text(
                          "\$ ${widget.amount.toStringAsFixed(2)}",
                          style: R.textStyle
                              .helvetica()
                              .copyWith(color: Colors.white, fontSize: 18.sp),
                        ),
                      ],
                    ),
                  ),
                ],
                h3,
              ],
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () async {
            var authVm = Provider.of<AuthVm>(context, listen: false);
            if (formKey.currentState!.validate()) {
              if (isTip && walletAmount >= widget.amount) {
                var hostWalletDoc = await FbCollections.wallet
                    .doc(provider.bookingsModel.hostUserUid)
                    .get();
                var userWalletDoc = await FbCollections.wallet
                    .doc(provider.bookingsModel.createdBy)
                    .get();
                var hostWalletData =
                    hostWalletDoc.data() as Map<String, dynamic>;
                var userWalletData =
                    userWalletDoc.data() as Map<String, dynamic>;
                log(hostWalletData['amount'].toString());
                log(userWalletData['amount'].toString());
                hostWalletData['amount'] += widget.amount;
                userWalletData['amount'] -= widget.amount;
                await FbCollections.wallet
                    .doc(provider.bookingsModel.hostUserUid)
                    .update(hostWalletData);
                await FbCollections.wallet
                    .doc(provider.bookingsModel.createdBy)
                    .update(userWalletData);
                BookingsModel localModel = provider.bookingsModel;
                localModel.priceDetaill!.tip =
                    localModel.priceDetaill!.tip! + widget.amount;
                await FbCollections.bookings
                    .doc(localModel.id)
                    .update(localModel.toJson());
                Helper.inSnackBar(
                    "Success",
                    "Your Tip has been recieved successfully",
                    R.colors.themeMud);
                await authVm.cancleStreams();
                Get.offAllNamed(BaseView.route);
              } else if (!isTip) {
                if (walletAmount >= double.parse(amountCon.text)) {
                  provider.bookingsModel.paymentDetail?.paymentMethod =
                      PaymentMethodEnum.wallet.index;
                  provider.bookingsModel.paymentDetail?.payWithWallet =
                      provider.bookingsModel.paymentDetail?.payWithWallet +
                          double.parse(amountCon.text);
                  provider.bookingsModel.paymentDetail?.paidAmount =
                      provider.bookingsModel.paymentDetail?.paidAmount +
                          double.parse(amountCon.text);
                  provider
                      .bookingsModel.paymentDetail?.remainingAmount = provider
                                  .bookingsModel.paymentDetail?.payInType ==
                              PayType.deposit.index &&
                          provider.bookingsModel.paymentDetail?.isSplit == true
                      ? percentOfAmount(
                              provider
                                  .bookingsModel.paymentDetail?.remainingAmount,
                              25) -
                          double.parse(amountCon.text)
                      : provider.bookingsModel.paymentDetail?.remainingAmount -
                          double.parse(amountCon.text);
                  if (provider.bookingsModel.paymentDetail?.isSplit == true) {
                    splitPerson?.payWithWallet = splitPerson?.payWithWallet +
                        double.parse(amountCon.text);
                    splitPerson?.remainingAmount = provider
                                    .bookingsModel.paymentDetail?.payInType ==
                                PayType.deposit.index &&
                            provider.bookingsModel.paymentDetail?.isSplit ==
                                false
                        ? percentOfAmount(splitPerson?.remainingAmount, 25) -
                            double.parse(amountCon.text)
                        : splitPerson?.remainingAmount -
                            double.parse(amountCon.text);
                    splitPerson?.amount =
                        splitPerson?.amount + double.parse(amountCon.text);
                    splitPerson?.paymentMethod = PaymentMethodEnum.wallet.index;

                    provider.update();
                  }
                  log("_______________${provider.bookingsModel.paymentDetail?.remainingAmount}");
                  var authVm = Provider.of<AuthVm>(context, listen: false);
                  authVm.wallet?.amount =
                      authVm.wallet?.amount - double.parse(amountCon.text);
                  Get.forceAppUpdate();
                  Get.back();
                } else {
                  Helper.inSnackBar(
                      "Error",
                      "You do not have such amount in your wallet",
                      R.colors.themeMud);
                }
              } else {
                Helper.inSnackBar(
                    "Error",
                    "You do not have such amount in your wallet",
                    R.colors.themeMud);
              }
            }
          },
          child: Container(
            height: Get.height * .065,
            width: Get.width * .8,
            margin: EdgeInsets.symmetric(horizontal: Get.width * .09),
            decoration: AppDecorations.gradientButton(radius: 30),
            child: Center(
              child: Text(
                "${getTranslated(context, "pay_now")?.toUpperCase()}",
                style: R.textStyle.helvetica().copyWith(
                    color: R.colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    });
  }
}
