import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/view/bookings/model/bookings.dart';
import 'package:yacht_master/src/base/widgets/tip_sheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/validation.dart';

class FeedbackSheet extends StatefulWidget {
  Function(double rat, String desc, double tip)? submitCallBack;

  FeedbackSheet({this.submitCallBack, required this.bookingsModel});
  BookingsModel? bookingsModel;
  double tipAmount = 0.0;

  @override
  _FeedbackSheetState createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  Future<DocumentSnapshot>? _getData;
  int _selectedIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    _getData = FbCollections.charterFleet
        .doc(widget.bookingsModel?.charterFleetDetail?.id)
        .get();
    super.initState();
  }

  TextEditingController descCon = TextEditingController();
  FocusNode descFn = FocusNode();
  bool isLoading = false;

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
    log(widget.tipAmount.toString());
    double totalPrice = widget.bookingsModel!.priceDetaill!.subTotal! +
        Helper().calculatePercentage(
            widget.bookingsModel?.priceDetaill?.taxes!.toInt() ?? 0,
            widget.bookingsModel!.priceDetaill!.subTotal!) +
        widget.bookingsModel!.priceDetaill!.serviceFee!;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: SingleChildScrollView(
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: R.colors.black,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(35),
                topLeft: Radius.circular(35),
              ),
            ),
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: _getData,
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox();
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SpinKitPulse(
                        color: R.colors.themeMud,
                      );
                    } else {
                      CharterModel charterModel =
                          CharterModel.fromJson(snapshot.data?.data());
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Form(
                          key: _ratingFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: Get.height * .02,
                              ),
                              GeneralAppBar.simpleAppBar(
                                  context,
                                  getTranslated(context, "give_us_feedback") ??
                                      "",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: Colors.white, fontSize: 16.sp)),
                              SizedBox(
                                height: Get.height * .02,
                              ),
                              h1,
                              Text(
                                "Congratulations, Your charter has been completed!!",
                                style: R.textStyle.helveticaBold().copyWith(
                                    color: Colors.white, fontSize: 13.sp),
                                textAlign: TextAlign.center,
                              ),
                              h2,
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: R.colors.whiteColor),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        imageUrl: charterModel.images?.first ??
                                            R.images.serviceUrl,
                                        height: Get.height * .09,
                                        width: Get.width * .3,
                                        fit: BoxFit.cover,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                SpinKitPulse(
                                          color: R.colors.themeMud,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  w4,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        charterModel.name ?? "",
                                        style: R.textStyle
                                            .helveticaBold()
                                            .copyWith(
                                                color: R.colors.whiteColor,
                                                fontSize: 15.sp),
                                      ),
                                      h0P5,
                                      FutureBuilder(
                                          future: FbCollections.user
                                              .doc(charterModel.createdBy)
                                              .get(),
                                          builder: (context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  hostSnap) {
                                            if (!hostSnap.hasData) {
                                              return SizedBox();
                                            } else {
                                              return Text(
                                                hostSnap.data
                                                    ?.get("first_name"),
                                                style: R.textStyle
                                                    .helvetica()
                                                    .copyWith(
                                                        color:
                                                            R.colors.whiteDull,
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              );
                                            }
                                          }),
                                      h0P5,
                                      SizedBox(
                                        width: Get.width * .5,
                                        child: Text(
                                          " ${charterModel.location?.adress}",
                                          style: R.textStyle
                                              .helvetica()
                                              .copyWith(
                                                  color: R.colors.whiteDull,
                                                  fontSize: 11.sp),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              h3,
                              if (Helper().calculatePercentage(10, totalPrice) >
                                  widget.bookingsModel!.priceDetaill!.tip!) ...[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "  How much do you want to Tip?",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10.sp),
                                    ),
                                    SizedBox(),
                                  ],
                                ),
                                h2,
                                Container(
                                  decoration: BoxDecoration(
                                      color: R.colors.blackDull,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: ButtonBar(
                                    alignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: _selectedIndex == 0
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: TextButton(
                                          child: Text(
                                            "\$${Helper().calculatePercentage(10, totalPrice).toStringAsFixed(2)}",
                                            style:
                                                TextStyle(color: Colors.amber),
                                          ),
                                          onPressed: () {
                                            widget.tipAmount = Helper()
                                                .calculatePercentage(
                                                    10, totalPrice);
                                            _selectedIndex = 0;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: _selectedIndex == 1
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: TextButton(
                                            child: Text(
                                              "\$${Helper().calculatePercentage(15, totalPrice).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.amber),
                                            ),
                                            onPressed: () {
                                              widget.tipAmount = Helper()
                                                  .calculatePercentage(
                                                      15, totalPrice);
                                              _selectedIndex = 1;
                                              setState(() {});
                                            }),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: _selectedIndex == 2
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: TextButton(
                                            child: Text(
                                              "\$${Helper().calculatePercentage(20, totalPrice).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Colors.amber),
                                            ),
                                            onPressed: () {
                                              widget.tipAmount = Helper()
                                                  .calculatePercentage(
                                                      20, totalPrice);
                                              _selectedIndex = 2;
                                              setState(() {});
                                            }),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: _selectedIndex == 3
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: TextButton(
                                            child: Text(
                                              'Other',
                                              style: TextStyle(
                                                  color: Colors.amber),
                                            ),
                                            onPressed: () {
                                              _selectedIndex = 3;
                                              Get.bottomSheet(TipAmountSheet(
                                                yesCallBack: (value) {
                                                  widget.tipAmount =
                                                      double.parse(value);
                                                  setState(() {});
                                                },
                                              ));
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                                h3,
                              ],
                              SizedBox(
                                width: Get.width * .7,
                                child: Text(
                                  getTranslated(
                                          context, "your_feedback_will_help") ??
                                      "",
                                  style: R.textStyle.helveticaBold().copyWith(
                                      color: R.colors.blueGrey,
                                      fontSize: 12.sp),
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
                                  glowColor:
                                      R.colors.yellowDark.withOpacity(.50),
                                  unratedColor: R.colors.unratedStar,
                                  itemBuilder: (context, _) => Padding(
                                    padding: EdgeInsets.only(right: 50),
                                    child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(colors: [
                                            R.colors.gradMud,
                                            R.colors.gradMudLight
                                          ]).createShader(bounds);
                                        },
                                        blendMode: BlendMode.srcATop,
                                        child: Image.asset(
                                          R.images.star,
                                        )),
                                  ),
                                  onRatingUpdate: (selectedRating) {
                                    rating = selectedRating;
                                  },
                                ),
                              ),
                              h3,
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * .04),
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
                                      FieldValidator.validateDesc(descCon.text),
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
                                  if (_ratingFormKey.currentState!.validate()) {
                                    startLoader();
                                    await widget.submitCallBack!(
                                        rating, descCon.text, widget.tipAmount);
                                    stopLoader();
                                  }
                                },
                                child: Container(
                                  height: Get.height * .06,
                                  width: Get.width * .6,
                                  decoration:
                                      AppDecorations.gradientButton(radius: 30),
                                  child: Center(
                                    child: Text(
                                      "${getTranslated(context, "submit")?.toUpperCase()}",
                                      style: R.textStyle.helvetica().copyWith(
                                            color: R.colors.black,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              h2,
                            ],
                          ),
                        ),
                      );
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsFeedbackSheet extends StatefulWidget {
  Function(double rat, String desc)? submitCallBack;

  SettingsFeedbackSheet({this.submitCallBack});

  @override
  _SettingsFeedbackSheetState createState() => _SettingsFeedbackSheetState();
}

class _SettingsFeedbackSheetState extends State<SettingsFeedbackSheet> {
  TextEditingController descCon = TextEditingController();
  FocusNode descFn = FocusNode();
  bool isLoading = false;

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
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: SingleChildScrollView(
          child: Container(
            width: Get.width,
            decoration: BoxDecoration(
              color: R.colors.black,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(35),
                topLeft: Radius.circular(35),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: _ratingFormKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: Get.height * .02,
                      ),
                      GeneralAppBar.simpleAppBar(context,
                          getTranslated(context, "give_us_feedback") ?? "",
                          style: R.textStyle
                              .helveticaBold()
                              .copyWith(color: Colors.white, fontSize: 16.sp)),
                      SizedBox(
                        height: Get.height * .02,
                      ),
                      SizedBox(
                        width: Get.width * .7,
                        child: Text(
                          getTranslated(context, "your_feedback_will_help") ??
                              "",
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
                          itemBuilder: (context, _) => Padding(
                            padding: EdgeInsets.only(right: 50),
                            child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(colors: [
                                    R.colors.gradMud,
                                    R.colors.gradMudLight
                                  ]).createShader(bounds);
                                },
                                blendMode: BlendMode.srcATop,
                                child: Image.asset(
                                  R.images.star,
                                )),
                          ),
                          onRatingUpdate: (selectedRating) {
                            rating = selectedRating;
                          },
                        ),
                      ),
                      h3,
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: Get.width * .04),
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
                              FieldValidator.validateDesc(descCon.text),
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
                          if (_ratingFormKey.currentState!.validate()) {
                            startLoader();
                            await widget.submitCallBack!(rating, descCon.text);
                            stopLoader();
                          }
                        },
                        child: Container(
                          height: Get.height * .06,
                          width: Get.width * .6,
                          decoration: AppDecorations.gradientButton(radius: 30),
                          child: Center(
                            child: Text(
                              "${getTranslated(context, "submit")?.toUpperCase()}",
                              style: R.textStyle.helvetica().copyWith(
                                    color: R.colors.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
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
