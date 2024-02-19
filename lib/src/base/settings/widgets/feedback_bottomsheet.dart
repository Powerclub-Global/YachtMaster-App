import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/dummy.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';
class FeedbackSheet extends StatefulWidget {
  Function(double rat,String desc)? submitCallBack;


  FeedbackSheet({this.submitCallBack});

  @override
  _FeedbackSheetState createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  TextEditingController descCon = TextEditingController();
  FocusNode descFn= FocusNode();
  bool isLoading=false;

  final GlobalKey<FormState> _ratingFormKey = GlobalKey<FormState>();
  double rating = 3.0;
  startLoader() {
    isLoading = true;
    setState(() {});
  }

  stopLoader() {
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator:   SpinKitPulse(color: R.colors.themeMud,),
        child: SingleChildScrollView(
          child: Container(
            width: Get.width,
            decoration:  BoxDecoration(
              color: R.colors.black,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(35),
                topLeft: Radius.circular(35),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Form(key: _ratingFormKey,autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: Get.height * .02,
                      ),
                      GeneralAppBar.simpleAppBar(context, getTranslated(context, "give_us_feedback")??"",style:
                      R.textStyle.helveticaBold().copyWith(
                          color: Colors.white,fontSize: 16.sp
                      )),
                      SizedBox(
                        height: Get.height * .02,
                      ),
                      SizedBox(width: Get.width*.7,
                        child: Text(
                          getTranslated(context, "your_feedback_will_help")??"",
                          style: R.textStyle.helveticaBold().copyWith(
                              color: R.colors.blueGrey, fontSize: 12.sp),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      h4,
                      Center(
                        child: RatingBar.builder(
                          ignoreGestures: false,
                          initialRating: rating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 40,
                          glowColor: R.colors.yellowDark.withOpacity(.50),
                          unratedColor: R.colors.unratedStar,
                          itemBuilder: (context, _) =>  Padding(
                            padding:  EdgeInsets.only(right: 50),
                            child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                      colors:
                                      [R.colors.gradMud,R.colors.gradMudLight]
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcATop,
                                child: Image.asset(R.images.star,)),
                          ),
                          onRatingUpdate: (selectedRating) {
                            rating = selectedRating;
                          },
                        ),
                      ),
                      h3,
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: Get.width*.04),
                        child: TextFormField(
                          focusNode: descFn,
                          textInputAction: TextInputAction.next,
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
                                  descCon.text),
                          decoration: AppDecorations.simpleTextField(
                            "desc",
                            R.textStyle.helvetica().copyWith(
                                color: descFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                          ),
                        ),
                      ),
                       h3,
                      GestureDetector(
                        onTap: () async {

                          if(_ratingFormKey.currentState!.validate())
                          {
                            startLoader();
                            await widget.submitCallBack!(rating,descCon.text);
                            stopLoader();

                          }
                        },
                        child: Container(
                          height: Get.height*.06,
                          width: Get.width*.6,
                          decoration: AppDecorations.gradientButton(radius: 30),
                          child: Center(
                            child: Text("${getTranslated(context, "submit")?.toUpperCase()}",
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
      ),
    );
  }
}