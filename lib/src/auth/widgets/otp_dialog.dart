// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/time_schedule_service.dart';
import 'package:yacht_master/src/auth/view/login.dart';
import 'package:yacht_master/src/auth/view_model/auth_vm.dart';
import 'package:yacht_master/utils/heights_widths.dart';

import '../../../utils/helper.dart';
import '../../../utils/keyboard_actions.dart';

class OTP extends StatefulWidget {
  String number;
  bool? isSignup;
  Function(String val) verifyCallBack;
  Function() resendCallBack;
  OTP(this.number,this.isSignup,this.verifyCallBack,this.resendCallBack);

  @override
  _OTPState createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  var onTapRecognizer;
   FocusNode fn=FocusNode();
  TextEditingController textEditingController = TextEditingController()
    ..text = "1234567";

  late StreamController<ErrorAnimationType> errorController;

  bool hasError = false;
  String currentText = "";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  // String number="kainatnawaz8@gmail.com";

  @override
  void initState() {
    startTimer();
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if (widget.number != "")
    // {
    //   number=widget.number;
    //   setState(() {
    //
    //   });
    // }
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Timer? _timer;
  int _start = 60;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthVm>(
        builder: (context, provider, _) {
          return WillPopScope(
            onWillPop: ()async{
              Get.offAllNamed(LoginScreen.route);
              return true;
            },
            child: Center(
            child: Container(

              height: Get.height*.6,
              margin: EdgeInsets.symmetric(horizontal: Get.width*.05),
              alignment: Alignment.topCenter,
              decoration:  BoxDecoration(
                color:R.colors.black,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color:R.colors.black,
                child: ModalProgressHUD(
                  inAsyncCall: provider.isLoading,
                  progressIndicator:SpinKitPulse(color: R.colors.themeMud,),
                  child: SingleChildScrollView(
                    child: Column(

                      children: <Widget>[
                        h4,
                        SizedBox(
                          height: Get.height * .09,
                          child: Image.asset(
                            R.images.otp,
                          ),

                        ),
                        SizedBox(
                          height: Get.height * .04,
                        ),
                        Text(getTranslated(context, "otp_verification")??"",
                            style: R.textStyle.helveticaBold().copyWith(
                                color:  Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Get.height * .027)),
                        SizedBox(height:Get.height*.025),
                        SizedBox(
                          width: Get.width*.7,
                          child: Column(
                            children: [
                              Text(getTranslated(context,   "enter_the_otp_code_that_you_have_received_on_your_number")??"",
                                  style: R.textStyle.helvetica().copyWith(
                                      color:  Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize:11.sp,height: 1.4),textAlign: TextAlign.center,),
                              Text(
                                  widget.number,
                                // obsecureEmail(widget.number),
                                  style: R.textStyle.helvetica().copyWith(
                                      color:  Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize:11.sp,height: 1.4),textAlign: TextAlign.center,),
                            ],
                          ),
                        ),
                        SizedBox(height:Get.height*.025),
                        Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
                            child: KeyboardActions(
                              config: buildConfigDone(context, fn,
                                  nextFocus: FocusNode(), isDone: true),
                              disableScroll: true,
                              autoScroll: false,
                              child: PinCodeTextField(
                                focusNode: fn,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                length: 6,
                                enabled: true,
                                enableActiveFill: true,
                                keyboardType: TextInputType.number,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,

                                  inactiveColor: Colors.grey.withOpacity(.20),
                                  activeColor:   Colors.grey.withOpacity(.20),
                                  selectedFillColor:    Colors.grey.withOpacity(.20),
                                  selectedColor:    Colors.grey.withOpacity(.20),
                                  activeFillColor:   Colors.grey.withOpacity(.20),
                                  inactiveFillColor:   Colors.grey.withOpacity(.20),
                                  disabledColor:   Colors.grey.withOpacity(.20),
                                  borderWidth: 0.6,
                                  borderRadius: BorderRadius.circular(8),
                                  fieldHeight: Get.width * .15,
                                  fieldWidth: Get.width * .12,

                                ),
                                textStyle: R.textStyle.helvetica().copyWith(
                                  color:  R.colors.whiteColor,fontSize: Get.width*.045,fontWeight: FontWeight.bold),
                                animationDuration: Duration(milliseconds: 300),
                                backgroundColor: Colors.transparent,
                                validator: (v) {
                                  if (v!.isEmpty) {
                                    return "OTP Required";
                                  }
                                  if (v.length<6) {
                                    return "Invalid OTP";
                                  }
                                  else {
                                    return null;
                                  }
                                },
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    currentText = value;
                                  });
                                }, appContext:context,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${getTranslated(context, "did_not_receive_code")}?",
                              style: R.textStyle.helvetica().copyWith(color: R.colors.greyOtp,
                                fontSize: 9.sp,fontWeight: FontWeight.bold,
                              )),
                            w2,
                            Text(
                              '00 : ' + '${_start.formatMint()}',
                              style:R.textStyle.helvetica().copyWith(color: R.colors.whiteColor,
                                fontSize: 10.sp,fontWeight: FontWeight.bold,fontStyle: FontStyle.italic
                              ),

                            ),
                          ],
                        ),
                        h1,
                        if(_start==0 )  GestureDetector(
                          onTap: () {
                            if (_start == 0) {
                              Helper.inSnackBar("Success", "OTP has successfully sent", R.colors.themeMud);
                              startTimer();
                              widget.resendCallBack();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Text(
                            "${getTranslated(context, "resend")}?",
                              style: R.textStyle.helveticaBold().copyWith(color: R.colors.whiteColor,
                                fontSize: 10.sp,fontWeight: FontWeight.bold,
                                 decoration: TextDecoration.underline
                              )
                            ),
                          ),
                        ),
                        h4,
                        GestureDetector(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              widget.verifyCallBack(currentText);
                            }
                          },

                          child:  Container(
                            height: Get.height*.06,width: Get.width*.6,
                            decoration: AppDecorations.gradientButton(radius: 30),
                            child: Center(
                              child: Text("${getTranslated(context, "verify")?.toUpperCase()}",
                                style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                                  fontSize: 12.sp,fontWeight: FontWeight.bold,
                                ) ,),
                            ),
                          ),
                        ),
                        h2,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ),
          );
      }
    );
  }
  void startTimer() {
    setState(() {
      _start = 60;
    });
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

}