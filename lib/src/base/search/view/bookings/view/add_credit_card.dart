import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/credit_card_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/view_model/bookings_vm.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/validation.dart';

class AddCreditCard extends StatefulWidget {
  static String route="/addCreditCard";
  const AddCreditCard({Key? key}) : super(key: key);

  @override
  _AddCreditCardState createState() => _AddCreditCardState();
}

class _AddCreditCardState extends State<AddCreditCard> {
  TextEditingController cardNumCon=TextEditingController();
  TextEditingController dateCon=TextEditingController();
  TextEditingController cvcCon=TextEditingController();
  TextEditingController nameCon=TextEditingController();
  FocusNode cardNumFn=FocusNode();
  FocusNode dateFn=FocusNode();
  FocusNode cvcFn=FocusNode();
  FocusNode nameFn=FocusNode();
  var maskFormatter = new MaskTextInputFormatter(
      mask: '##/##',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );
  var cardFormater = new MaskTextInputFormatter(
      mask: '#### #### #### ####',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer<BookingsVm>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "credit_card")??""),
            body: Padding(
              padding:  EdgeInsets.symmetric(horizontal: Get.width*.05,vertical: Get.height*.02),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(getTranslated(context, "add_a_credit_or_debit_card")??"",style: R.textStyle.helvetica().copyWith(
                  color: Colors.white
                ),),
                  h3,
                  TextFormField(
                    controller: cardNumCon,
                    focusNode: cardNumFn,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      cardFormater
                    ],
                    decoration:InputDecoration(
                      errorStyle:  R.textStyle.helvetica().copyWith(
                          color: R.colors.redColor,
                          fontSize: 9.sp),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 10,),
                      hintText: getTranslated(context, "card_number"),
                      hintStyle: R.textStyle.helvetica().copyWith(fontSize: 12.sp),
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
                    ),
                    validator: (val) =>
                        FieldValidator.validateCardNumber(
                            cardNumCon.text),
                  ),
                  h1P5,
                  Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dateCon,
                          focusNode: dateFn,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              maskFormatter
                            ],
                            onFieldSubmitted: (value)
                            {
                              log("_________${int.parse(value.substring(0,2))<=now.month}");
                              log("_________${int.parse(value.substring(3,5))<int.parse(now.year.toString().substring(2,4))}");
                            },
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                FieldValidator.validateExpiration(
                                    dateCon.text),
                          decoration:InputDecoration(
                            errorStyle:  R.textStyle.helvetica().copyWith(
                                color: R.colors.redColor,
                                fontSize: 9.sp),
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 10,),
                            hintText: getTranslated(context, "mm/yy"),
                            hintStyle: R.textStyle.helvetica().copyWith(fontSize: 12.sp),
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
                          )
                        ),
                      ),
                      w2,
                      Expanded(
                          child: TextFormField(
                              controller: cvcCon,
                              focusNode: cvcFn,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(3),
                                FilteringTextInputFormatter.allow(
                                    RegExp("[0-9]"))
                              ],
                              validator: (val) =>
                                  FieldValidator.validateCvcNumber(
                                      cvcCon.text),
                              decoration:InputDecoration(
                                errorStyle:  R.textStyle.helvetica().copyWith(
                                    color: R.colors.redColor,
                                    fontSize: 9.sp),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 10,),
                                hintText: getTranslated(context, "cvc"),
                                hintStyle: R.textStyle.helvetica().copyWith(fontSize: 12.sp),
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
                              )
                          ),
                        ),
                    ],
                  ),
                    h1P5,
                    TextFormField(
                        controller: nameCon,
                        focusNode: nameFn,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (val) =>
                            FieldValidator.validateHolderName(
                                nameCon.text),
                        decoration:InputDecoration(
                          errorStyle:  R.textStyle.helvetica().copyWith(
                              color: R.colors.redColor,
                              fontSize: 9.sp),
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: 10,),
                          hintText: getTranslated(context, "name_of_the_card_holder"),
                          hintStyle: R.textStyle.helvetica().copyWith(fontSize: 12.sp),
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
                        )
                    ),
                    h2,
                    GestureDetector(
                      onTap: (){
                        provider.isSaveThisCard==true?
                        provider.isSaveThisCard=false:
                        provider.isSaveThisCard=true;
                        provider.update();
                      },
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white)
                            ),
                            padding: EdgeInsets.all(2.5),
                            child:Icon(Icons.check,size: 12,
                              color: provider.isSaveThisCard==true?R.colors.whiteColor:Colors.transparent,)
                          ),
                          w2,
                          Text(getTranslated(context, "save_this_card_for_a_fast_payment_next_time")??"",
                          style: R.textStyle.helvetica().copyWith(color: Colors.white,fontSize: 11.5.sp),)
                        ],
                      ),
                    ),
                    h2,
                    Text(getTranslated(context, "by_saving_your_card_you_grant_us_your_consent_to")??"",
                      style: R.textStyle.helvetica().copyWith(color: R.colors.whiteDull,fontSize: 11.sp,
                      height: 1.3),)


                  ],),
              ),
            ),
              bottomNavigationBar: GestureDetector(
                onTap: (){
                 if(formKey.currentState!.validate())
                   {

                    provider.creditCardModel=CreditCardModel(
                      cardNum: cardNumCon.text,
                      expiryDate: dateCon.text,
                      cvc: cvcCon.text,
                      name: nameCon.text,
                    );
                    provider.bookingsModel.paymentDetail?.paymentMethod=PaymentMethodEnum.card.index;
                    provider.update();
                    Get.back();
                   }
                },
                child: Container(
                  height: Get.height*.065,width: Get.width*.8,
                  margin: EdgeInsets.symmetric(horizontal: Get.width*.09),
                  decoration: AppDecorations.gradientButton(radius: 30),
                  child: Center(
                    child: Text("${getTranslated(context, "done")?.toUpperCase()}",
                      style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                          fontSize: 12.sp,fontWeight: FontWeight.bold
                      ) ,),
                  ),
                ),
              ),
        ),
          );
      }
    );
  }
}
