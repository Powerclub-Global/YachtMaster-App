import 'dart:developer';

import 'package:async_foreach/async_foreach.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../../../constant/enums.dart';
import '../../../../../../localization/app_localization.dart';
import '../../../../../../resources/decorations.dart';
import '../../../../../../resources/resources.dart';
import '../../../../../../services/firebase_collections.dart';
import '../../../../../auth/view_model/auth_vm.dart';
import '../../../model/charter_model.dart';
import '../model/bookings.dart';
import 'add_credit_card.dart';
import 'payments_methods.dart';
import '../view_model/bookings_vm.dart';
import '../../../../yacht/model/split_payment_person_model.dart';
import '../../../../../../utils/general_app_bar.dart';
import '../../../../../../utils/heights_widths.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../../utils/validation.dart';

import '../../../../../../utils/textfield_search.dart';

class SplitPayment extends StatefulWidget {
  static String route = "/splitPayment";

  const SplitPayment({Key? key}) : super(key: key);

  @override
  _SplitPaymentState createState() => _SplitPaymentState();
}

class _SplitPaymentState extends State<SplitPayment> {
  bool isDeposit = false;
  bool isLoading = false;
  double splitAmount = 0.00;
  double totalAmount = 0.00;
  CharterModel? charter;
  TextEditingController totalPersonCon = TextEditingController();
  FocusNode totalPersonFn = FocusNode();
  String labelText = "Some Label";
  List<String>? yachtUsers = [];
  TextEditingController myController = TextEditingController();
  var maskFormatter = MaskTextInputFormatter(
      mask: '#%',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);
  int currentSplitIndex=-1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var bookingVm=Provider.of<BookingsVm>(context,listen: false);
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      isDeposit = args["isDeposit"];
      charter = args["charter"];
      yachtUsers=await bookingVm.fetchAllUsers(charter?.createdBy??"");

      if(bookingVm.bookingsModel.paymentDetail?.payInType==PayType.deposit.index)
        {
              splitAmount = (bookingVm.bookingsModel.priceDetaill?.totalPrice??0.0)*(25/100);
        }
      else{
        splitAmount = bookingVm.bookingsModel.priceDetaill?.totalPrice??0.0;
      }
      totalAmount=bookingVm.bookingsModel.priceDetaill?.totalPrice??0.0;
      log("_______________Total amount:${totalAmount}____${yachtUsers?.length}");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthVm,BookingsVm>(builder: (context,authVm, provider, _) {
      return ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator:   SpinKitPulse(color: R.colors.themeMud,),
        child: GestureDetector(
          onTap: (){
            if(yachtUsers?.any((element) => element== provider.splitList[currentSplitIndex].personEmail.text)!=true)
           {
             provider.splitList[currentSplitIndex].personEmail.text="";
             provider.update();
           }
            Helper.focusOut(context);
          },
          child: Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "split_payment")??""),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
                child: Column(
                  children: [
                    h1P5,
                    Container(
                      decoration: BoxDecoration(
                          color: R.colors.blackDull,
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(
                          horizontal: Get.width * .05, vertical: Get.height * .02),
                      child:   Column(
                        children: [
                          if (provider.bookingsModel.paymentDetail?.payInType==
                              PayType.deposit.index)
                            Padding(
                            padding:  EdgeInsets.only(bottom: 2.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "25% Deposit",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.whiteColor, fontSize: 14.5.sp),
                                ),
                                Text(
                                  "\$${double.parse(splitAmount.toStringAsFixed(2))}",
                                  style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.yellowDark,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                getTranslated(context, "total") ?? "",
                                style: R.textStyle.helveticaBold().copyWith(
                                    color: R.colors.whiteColor, fontSize: 14.5.sp),
                              ),
                              Text(
                                "\$${double.parse(totalAmount.toStringAsFixed(2))}",
                                style: R.textStyle.helveticaBold().copyWith(
                                  color: R.colors.yellowDark,
                                  fontSize: 15.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    h4,
                    Row(
                      children: [
                        Text(
                          getTranslated(context, "split_details") ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp),
                        ),
                      ],
                    ),
                    h2,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter(RegExp("[0-9]"),
                                  allow: true)
                            ],
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            textInputAction: TextInputAction.next,
                            onChanged: (v) {
                              setState(() {});
                            },
                            onTap: () {
                              setState(() {});
                            },
                            onFieldSubmitted: (a) {
                              setState(() {
                                Helper.focusOut(context);
                              });
                            },
                            controller: totalPersonCon,
                            validator: (val) =>
                                FieldValidator.validateEmpty(val ?? ""),
                            decoration: AppDecorations.suffixTextField(
                                "enter_persons_count",
                                R.textStyle.helvetica().copyWith(
                                    color: totalPersonFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                                SizedBox()),
                          ),
                        ),
                        w3,
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (totalPersonCon.text.isNotEmpty) {
                                if (int.parse(totalPersonCon.text) <= 1) {
                                  Helper.inSnackBar(
                                      "Error",
                                      "Persons count should be greater than 1",
                                      R.colors.themeMud);
                                }else if((provider.bookingsModel.totalGuest??0)<int.parse(totalPersonCon.text))
                                  {
                                    Helper.inSnackBar(
                                        "Error",
                                        "Split count for more than guests not possible",
                                        R.colors.themeMud);
                                  }
                                else {
                                  setState(() {
                                    provider.splitList.clear();
                                    for (int i = 1;
                                        i <= int.parse(totalPersonCon.text);
                                        i++) {
                                      provider.splitList.add(SplitPaymentPersonModel(
                                          personEmail: TextEditingController(),
                                          percentage: TextEditingController(),
                                          splitAmount: 0.0));
                                    }
                                    Helper.focusOut(context);
                                  });
                                }
                              } else {
                                Helper.inSnackBar(
                                    "Error",
                                    "Please enter total persons count",
                                    R.colors.themeMud);
                              }
                            },
                            child: Container(
                              height: Get.height * .065,
                              decoration: AppDecorations.gradientButton(radius: 15),
                              child: Center(
                                child: Text(
                                  "Split",
                                  style: R.textStyle.helvetica().copyWith(
                                      color: R.colors.black,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    h2,
                    Column(
                        children: List.generate(provider.splitList.length, (index) {
                      provider.splitList[0].personEmail.text = yachtUsers?.firstWhereOrNull((element) => element==authVm.userModel?.email);
                      if (isDeposit == true) {
                        provider.splitList[0].splitAmount = splitAmount * (25 / 100);
                        provider.splitList[0].percentage.text = "25";
                      }
                      int availedPercentage = 0;
                      currentSplitIndex=index;
                      return Column(
                        children: [
                          if (index == 0) label("Default Person Email") else label("Person Email"),
                          h0P5,
                          IgnorePointer(
                            ignoring: index==0?true:false,
                            child: TextFieldSearch(
                              decoration: AppDecorations.generalTextField(
                                index == 0
                                    ? "Enter Default Person Email"
                                    : "Person ${index + 1} email",
                                R.textStyle.helvetica().copyWith(
                                    color: totalPersonFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                              ),
                              initialList: yachtUsers,
                              getSelectedValue: (val){
                                if(provider.splitList.where((element) => element.personEmail.text==val).toList().length>=2)
                                  {
                                    log("________________TRUE:${provider.splitList.where((element) => element.personEmail.text==val).toList().length}");
                                    provider.splitList[index].personEmail.clear();
                                    Helper.inSnackBar("Error", "You have already selected that person", R.colors.themeMud);
                                  }
                                log("_______SELCTED VALUE:${val}");
                              },
                              label: labelText,
                              controller: provider.splitList[index].personEmail,
                            ),
                          ),
                          h1,
                          if (index == 0) label("Default User (%)") else label("Percentage (%)"),
                          h0P5,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: TextFormField(
                                  readOnly: isDeposit == true && index == 0
                                      ? true
                                      : false,
                                  controller: provider.splitList[index].percentage,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // maskFormatter
                                    FilteringTextInputFormatter(RegExp("[0-9.]"),
                                        allow: true),
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (v) {
                                    setState(() {});
                                  },
                                  onTap: () {
                                    setState(() {});
                                  },
                                  onFieldSubmitted: (a) {
                                    if (double.parse(a) <= 0) {
                                      provider.splitList[index].percentage.clear();
                                      Helper.inSnackBar("Error",
                                          "Invalid percentage", R.colors.themeMud);
                                    } else {
                                      availedPercentage = 0;
                                      if (double.parse(a) >= 100) {
                                        Helper.inSnackBar(
                                            "Error",
                                            "Split percentage should be less than 100",
                                            R.colors.themeMud);
                                      } else {
                                        setState(() {
                                          provider.splitList.forEach((element) {
                                            if (element.percentage.text != "") {
                                              log("HERE:__${(double.parse(availedPercentage.toString()) +
                                                  double.parse(element.percentage.text.toString().replaceAll("%", ""))).toInt()}___${double.parse(availedPercentage.toString())}___${double.parse(element.percentage.text.toString().replaceAll("%", ""))}");
                                              availedPercentage =
                                                  (double.parse(availedPercentage.toString()) +
                                                      double.parse(element.percentage.text.toString().replaceAll("%", ""))).toInt();
                                              log("_____________ELEMENT PER:${availedPercentage}");
                                            }
                                          });
                                          log("_____________TOTAL PER:${(availedPercentage)}");
                                          if (availedPercentage <= 100) {
                                            provider.splitList[index].splitAmount =
                                                splitAmount *
                                                    (double.parse(provider.splitList[index]
                                                            .percentage
                                                            .text
                                                            .toString()
                                                            .replaceAll("%", "")) /
                                                        100);
                                          } else {
                                            provider.splitList[index].percentage.clear();
                                            provider.splitList[index].splitAmount = 0.0;
                                            setState(() {});
                                            Helper.inSnackBar(
                                                "Error",
                                                "Split percentage can not be greater than 100",
                                                R.colors.themeMud);
                                          }
                                        });
                                      }
                                    }
                                    Helper.focusOut(context);
                                  },
                                  validator: (val) =>
                                      FieldValidator.validateEmpty(val ?? ""),
                                  decoration: AppDecorations.generalTextField(
                                    "Enter Percentage",
                                    R.textStyle.helvetica().copyWith(
                                        color: totalPersonFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: Get.height * .062,
                                  child: Icon(
                                    CupertinoIcons.equal,
                                    color: R.colors.yellowDark,
                                    size: 17,
                                  )),
                              Expanded(
                                flex: 4,
                                child: Container(
                                  height: Get.height * .062,
                                  decoration: AppDecorations.buttonDecoration(
                                      R.colors.blackDull, 12),
                                  child: Center(
                                    child: Text(
                                      "\$ ${provider.splitList[index].splitAmount?.toStringAsFixed(2)}",
                                      style: R.textStyle.helveticaBold().copyWith(
                                          color: R.colors.themeMud,
                                          fontSize: 12.sp),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          h2,
                        ],
                      );
                    })),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: GestureDetector(
              onTap: () async {
                   startLoader();
                   if (totalPersonCon.text.isEmpty) {
                     Helper.inSnackBar(
                         "Error", "Please enter number of persons", R.colors.themeMud);
                   }
                   else {
                     int totalPercent = 0;
                     double totalSplitAmount = 0;
                     provider.splitList.forEach((element) {
                       if (element.percentage.text != "") {
                         totalPercent = (double.parse(totalPercent.toString()) +
                             double.parse(element.percentage.text
                                 .toString()
                                 .replaceAll("%", ""))).toInt();
                         totalSplitAmount=(element.splitAmount??0)+totalSplitAmount;
                       }
                     });
                     if (totalPercent < 100) {
                       Helper.inSnackBar(
                           "Error",
                           "Please split all amount between persons",
                           R.colors.themeMud);
                     }
                     else {
                       provider.bookingsModel.paymentDetail?.splitPayment?.clear();
                       provider.bookingsModel.paymentDetail?.splitPayment=[];
                       provider.update();

                       await provider.splitList.asyncForEach((element) async {
                         String personUid='';
                         QuerySnapshot doc=await FbCollections.user.where("status",isEqualTo:UserStatus.active.index)
                             .where("email",isEqualTo:element.personEmail.text).get();
                         doc.docs.forEach((docEmail) {
                           personUid=docEmail.get("uid");
                         });
                         provider.bookingsModel.paymentDetail?.splitPayment?.add(SplitPaymentModel(
                             paymentType: -1,
                             amount: element.splitAmount,
                             remainingDeposit: element.splitAmount,
                             remainingAmount:provider.bookingsModel.paymentDetail?.payInType==PayType.deposit.index?
                             percentOfAmount((totalAmount-splitAmount),double.parse(element.percentage.text)):
                             element.splitAmount,
                             depositStatus: DepositStatus.nothingPaid.index,
                             userUid:personUid,
                             percentage:element.percentage.text,
                             paymentStatus:provider.bookingsModel.paymentDetail?.payInType==PayType.deposit.index?
                             PaymentStatus.confirmBooking.index:
                             PaymentStatus.payInAppOrCash.index,
                             paymentMethod: -1,
                             cryptoReceiverEmail: "",
                             cryptoScreenShot: "",
                           currentUserCardNum: null
                         ));
                       });
                       provider.update();
                       Get.toNamed(PaymentMethods.route,arguments: {
                         "isDeposit":isDeposit,"bookingsModel":provider.bookingsModel,"isCompletePayment":false});
                     }
                   }
                   stopLoader();
                   },
              child: Container(
                height: Get.height * .065,
                width: Get.width * .8,
                margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                decoration: AppDecorations.gradientButton(radius: 30),
                child: Center(
                  child: Text(
                    "${getTranslated(context, "send_receipt_and_pay_with")?.toUpperCase()}",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.black,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget paymentMethods(
      BookingsVm provider, String title, String img, int index) {
    return GestureDetector(
      onTap: () {
        provider.selectedPaymentMethod = index;
        switch (index) {
          case 0:
            Get.toNamed(AddCreditCard.route);
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
  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }
}
