import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../settings/model/neighborhood_support_model.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/validation.dart';

class HelpCenter extends StatefulWidget {
  static String route="/helpCenter";
  const HelpCenter({Key? key}) : super(key: key);

  @override
  _HelpCenterState createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  final formKey = GlobalKey<FormState>();
  TextEditingController fullNameCon = TextEditingController(text:"${Get.context!.read<AuthVm>().userModel?.firstName??""} ${Get.context!.read<AuthVm>().userModel?.lastName??""}");
  TextEditingController emailController = TextEditingController(text:Get.context!.read<AuthVm>().userModel?.email??"");
  TextEditingController subjectCon = TextEditingController();
  TextEditingController descCon = TextEditingController();
  FocusNode emailFn = FocusNode();
  FocusNode descFn= FocusNode();
  FocusNode fullNameFn= FocusNode();
  FocusNode subjectFn= FocusNode();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.colors.black,
      appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "yachtmaster_support")??""),
     body:   Padding(
       padding:  EdgeInsets.symmetric(vertical: Get.height*.02),
       child: Column(
         children: [
           Form(key: formKey,
             autovalidateMode: AutovalidateMode.onUserInteraction,
             child: Expanded(
               child: Padding(
                 padding:  EdgeInsets.symmetric(horizontal: 23.sp),
                 child: ListView(
                   children: [
                     label(getTranslated(context,"full_name",)??""),
                     h0P5,
                     TextFormField(
                       focusNode: fullNameFn,
                       textInputAction: TextInputAction.next,
                       inputFormatters: [
                         LengthLimitingTextInputFormatter(50),
                       ],
                       onChanged: (v) {
                         setState(() {});
                       },
                       onTap: () {
                         setState(() {});
                       },
                       onFieldSubmitted: (a) {
                         setState(() {});
                       },
                       controller: fullNameCon,
                       validator: (val) =>
                           FieldValidator.validateFullName(
                               fullNameCon.text.trim()),
                       decoration: AppDecorations.suffixTextField(
                           "enter_full_name",
                           R.textStyle.helvetica().copyWith(
                               color: fullNameFn.hasFocus
                                   ? R.colors.themeMud
                                   : R.colors.charcoalColor,
                               fontSize: 10.sp),
                           Image.asset(R.images.name,scale: 14,
                               color: fullNameFn.hasFocus
                                   ? R.colors.themeMud
                                   : R.colors.charcoalColor)),
                     ),
                     h2,
                     label(getTranslated(context,   "email",)??""),
                     h0P5,
                     TextFormField(
                       focusNode: emailFn,
                       textInputAction: TextInputAction.next,
                       onChanged: (v) {
                         setState(() {});
                       },
                       onTap: () {
                         setState(() {});
                       },
                       onFieldSubmitted: (a) {
                         setState(() {
                         });
                       },
                       controller: emailController,
                       validator: (val) =>
                           FieldValidator.validateEmail(
                               emailController.text),
                       decoration: AppDecorations.suffixTextField(

                           "enter_email",
                           R.textStyle.helvetica().copyWith(
                               color: emailFn.hasFocus
                                   ? R.colors.themeMud
                                   : R.colors.charcoalColor,
                               fontSize: 10.sp),
                           Container(
                             alignment: Alignment.center,
                             width: Get.width*.1,
                             child: Image.asset(R.images.email,scale: 15,
                                 color: emailFn.hasFocus
                                     ? R.colors.themeMud
                                     : R.colors.charcoalColor),
                           )),
                     ),
                     h2,
                     label(getTranslated(context,    "subject",)??""),
                     h0P5,
                     TextFormField(
                       textInputAction: TextInputAction.next,
                       focusNode: subjectFn,
                       validator: (val) =>
                           FieldValidator.validateSubject(
                               subjectCon.text.trim()),
                       inputFormatters: [
                         LengthLimitingTextInputFormatter(50)
                       ],
                       onChanged: (v) {
                         setState(() {});
                       },
                       onTap: () {
                         setState(() {});
                       },
                       onFieldSubmitted: (a) {
                         setState(() {

                         });
                       },
                       controller: subjectCon,
                       // validator: (val) =>
                       //     FieldValidator.validateSubject(
                       //         subjectCon.text),
                       decoration: AppDecorations.simpleTextField(
                           "enter_submit",
                           R.textStyle.helvetica().copyWith(
                               color: subjectFn.hasFocus
                                   ? R.colors.themeMud
                                   : R.colors.charcoalColor,
                               fontSize: 10.sp),
                           ),
                     ),
                     h2,
                     label(getTranslated(context,    "desc",)??""),
                     h0P5,
                     TextFormField(
                       focusNode: descFn,
                       textInputAction: TextInputAction.done,
                       onChanged: (v) {
                         setState(() {});
                       },
                       onTap: () {
                         setState(() {});
                       },
                       onFieldSubmitted: (a) {
                         setState(() {
                           FocusScope.of(Get.context!)
                               .requestFocus(new FocusNode());
                         });
                       },
                       maxLines: 6,
                       controller: descCon,
                       validator: (val) =>
                           FieldValidator.validateDesc(
                               descCon.text.trim()),
                       decoration: AppDecorations.simpleTextField(
                           "write_here",
                           R.textStyle.helvetica().copyWith(
                               color: descFn.hasFocus
                                   ? R.colors.themeMud
                                   : R.colors.charcoalColor,
                               fontSize: 10.sp),
                       ),
                     ),
                     h5,
                     GestureDetector(
                       onTap: () async {

                         if(formKey.currentState!.validate())
                         {

                           String docId=Timestamp.now().millisecondsSinceEpoch.toString();

                           try {
                             final Email email = Email(
                               body: descCon.text.trim(),
                               subject: subjectCon.text.trim(),
                               recipients: [emailController.text],
                               cc: [emailController.text],
                               bcc: [emailController.text],
                               attachmentPaths: [],
                               isHTML: false,
                             );
                             await FlutterEmailSender.send(email).whenComplete(() async {
                               Get.back();
                               Helper.inSnackBar("Success", "Submitted successfully", R.colors.themeMud);
                               NeighborhoodSupportModel model=NeighborhoodSupportModel(
                                   fullName: fullNameCon.text.trim(),
                                   subject: subjectCon.text.trim(),description: descCon.text.trim(),
                                   email: emailController.text,
                                   createdAt: Timestamp.now()
                               );
                               await FbCollections.neighborhoodSuppport.doc(docId).set(model.toJson());

                             });
                           } on Exception catch (e) {
                             // TODO
                             debugPrintStack();
                             log(e.toString());
                           }

                         }
                       },
                       child: Container(
                         height: Get.height*.06,
                         decoration: AppDecorations.gradientButton(radius: 30),
                         child: Center(
                           child: Text("${getTranslated(context, "submit")?.toUpperCase()}",
                             style: R.textStyle.helvetica().copyWith(color: R.colors.black,
                               fontSize: 12.sp,fontWeight: FontWeight.bold,
                             ) ,),
                         ),
                       ),
                     ),
                     h9,

                   ],
                 ),
               ),
             ),
           ),
         ],
       ),
     ),
    );
  }
}
