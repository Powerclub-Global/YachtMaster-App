// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sizer/sizer.dart';
// import 'package:yacht_master/localization/app_localization.dart';
// import 'package:yacht_master/resources/decorations.dart';
// import 'package:yacht_master/resources/resources.dart';
// import 'package:yacht_master/src/auth/widgets/new_password_dialog.dart';
// import 'package:yacht_master/src/auth/widgets/otp_dialog.dart';
// import 'package:yacht_master/utils/heights_widths.dart';
// import 'package:yacht_master/utils/helper.dart';
// import 'package:yacht_master/utils/validation.dart';
//
// class ForgotPassword extends StatefulWidget {
//   bool isForgot;
//
//   ForgotPassword({this.isForgot=false});
//
//   @override
//   _ForgotPasswordState createState() => _ForgotPasswordState();
// }
//
// class _ForgotPasswordState extends State<ForgotPassword> {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   TextEditingController emailController = TextEditingController();
//   FocusNode emailFn = FocusNode();
//
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // startTimeout();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BackdropFilter(
//       filter: ImageFilter.blur(
//         sigmaX: 5.0,
//         sigmaY: 5.0,
//       ),
//       child: SingleChildScrollView(
//         child: GestureDetector(
//           onTap:(){
//             Helper.focusOut(context);
//           },
//           child: Container(
//             decoration:  BoxDecoration(
//               color: R.colors.black,
//               borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(30),
//                 topLeft: Radius.circular(30),
//               ),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 h1,
//                 Container(
//                   margin: EdgeInsets.only(top: Get.height * 0.01),
//                   width: Get.width * .2,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(10),
//                     color: Colors.white,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: Get.width * .07),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       h2,
//                       Container(
//                           height: Get.height * .09,
//                           child: Image.asset(R.images.otp,)),
//                      h5,
//                       Text("${getTranslated(context, "forgot_password")}",
//                           style:R.textStyle.helvetica().copyWith(
//                               color:  R.colors.whiteColor,
//                               fontWeight: FontWeight.bold,
//                               fontSize: Get.width * .05)),
//                       SizedBox(
//                         height: Get.height * .01,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
//                         child: Text(
//                           getTranslated(context, "enter_your_registered_email_address")??"",
//                           style: R.textStyle.helvetica().copyWith(
//                             color: Colors.white,height: 1.5,
//                             fontSize: Get.width * .04,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       SizedBox(
//                         height: Get.height * .04,
//                       ),
//                       Form(
//                         key: formKey,
//                         autovalidateMode: AutovalidateMode.onUserInteraction,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             label(getTranslated(context, "email")??""),
//                             h0P5,
//                             TextFormField(
//                               focusNode: emailFn,
//                               textInputAction: TextInputAction.next,
//                               onChanged: (v) {
//                                 setState(() {});
//                               },
//                               onTap: () {
//                                 setState(() {});
//                               },
//                               onFieldSubmitted: (a) {
//                                 setState(() {
//                                   Helper.focusOut(context);
//
//                                 });
//                               },
//                               controller: emailController,
//                               validator: (val) =>
//                                   FieldValidator.validateEmail(
//                                       emailController.text),
//                               decoration: AppDecorations.suffixTextField(
//
//                                   "enter_email",
//                                   R.textStyle.helvetica().copyWith(
//                                       color: emailFn.hasFocus
//                                           ? R.colors.themeMud
//                                           : R.colors.charcoalColor,
//                                       fontSize: 10.sp),
//                                   Container(
//                                     alignment: Alignment.center,
//                                     width: Get.width*.1,
//                                     child: Image.asset(R.images.email,scale: 15,
//                                         color: emailFn.hasFocus
//                                             ? R.colors.themeMud
//                                             : R.colors.charcoalColor),
//                                   )),
//                             ),
//
//
//                           ],
//                         ),
//                       ),
//                       // Spacer(),
//                       SizedBox(
//                         height: Get.height * .05,
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           if (formKey.currentState!.validate()) {
//                             Get.back();
//
//                             Get.dialog(
//                                 OTP("+92 31212121222",false,(){
//                                   Get.back();
//                                   Get.bottomSheet(NewPasswordDialog(),barrierColor: R.colors.grey.withOpacity(.30));
//
//                                 }),barrierDismissible: true,
//                                 barrierColor: Colors.grey.withOpacity(.25));
//
//                           }
//                         },
//                         child:  Container(
//                           height: Get.height*.06,width: Get.width*.6,
//                           decoration: AppDecorations.gradientButton(radius: 30),
//                           child: Center(
//                             child: Text("${getTranslated(context, "proceed")?.toUpperCase()}",
//                               style: R.textStyle.helvetica().copyWith(color: R.colors.black,
//                                 fontSize: 12.sp,fontWeight: FontWeight.bold,
//                               ) ,),
//                           ),
//                         ),
//                       ),
//                       h1,
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//
// }