import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/stripe/stripe_service.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/src/base/yacht/widgets/congo_bottomSheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';

class WithdrawMoney extends StatefulWidget {
  static String route = "/withdrawMoney";
  const WithdrawMoney({Key? key}) : super(key: key);

  @override
  _WithdrawMoneyState createState() => _WithdrawMoneyState();
}

class _WithdrawMoneyState extends State<WithdrawMoney> {
  TextEditingController cardNumCon = TextEditingController();
  TextEditingController accountName = TextEditingController();
  TextEditingController amountCon = TextEditingController();
  TextEditingController nameCon = TextEditingController();
  FocusNode cardNumFn = FocusNode();
  FocusNode accountNameFn = FocusNode();
  FocusNode amountFn = FocusNode();
  FocusNode nameFn = FocusNode();

  var cardFormater = new MaskTextInputFormatter(
      mask: '#### #### #### ####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    String accountId = args['accountId'];
    return Consumer<BookingsVm>(builder: (context, provider, _) {
      return Consumer<AuthVm>(builder: (context, authVm, _) {
        return Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(context,
              "${getTranslated(context, "withdraw_money").toString().capitalize}"),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Get.width * .05, vertical: Get.height * .02),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated(context, "amount_you_want_to_withdraw") ?? "",
                    style:
                        R.textStyle.helvetica().copyWith(color: Colors.white),
                  ),
                  h3,
                  GestureDetector(
                    onTap: (){
                      FocusScope.of(context).unfocus();
                    },
                    child: TextFormField(
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
                  ),
                  h3,
                ],
              ),
            ),
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () async {
              if (formKey.currentState!.validate()) {
                if (authVm.wallet?.amount >= double.parse(amountCon.text)) {
                  try {
                    await authVm.updateUserWallet(
                        authVm.wallet?.amount - double.parse(amountCon.text));
                  } on Exception catch (e) {
                    // TODO
                    debugPrintStack();
                    log(e.toString());
                  }
                  Get.back();
                  StripeService stripe = StripeService();
                  await stripe.payout(accountId, amountCon.text);
                  Get.bottomSheet(Congoratulations(
                      "You have withdrawn money successfully", () {
                    Future.delayed(Duration(seconds: 2), () {
                      Get.back();
                    });
                  }));
                } else {
                  Helper.inSnackBar("Error",
                      "You do not have sufficient balance", R.colors.themeMud);
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
                  "${getTranslated(context, "done")?.toUpperCase()}",
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
    });
  }
}
