import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:async_foreach/async_foreach.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/constant.dart';
import 'package:yacht_master/localization/app_localization.dart';
import 'package:yacht_master/resources/decorations.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/services/image_picker_services.dart';
import 'package:yacht_master/src/auth/model/user_model.dart';
import 'package:yacht_master/src/base/search/model/charter_model.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/yacht/model/choose_offers.dart';
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/yacht/view/define_availibility.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/src/base/yacht/widgets/choose_services.dart';
import 'package:yacht_master/src/base/yacht/widgets/rules_bottomsheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/pick_location.dart';
import 'package:yacht_master/utils/validation.dart';

class AddfeaturedCharters extends StatefulWidget {
  static String route = "/addfeaturedCharters";
  const AddfeaturedCharters({Key? key}) : super(key: key);

  @override
  _AddfeaturedChartersState createState() => _AddfeaturedChartersState();
}

class _AddfeaturedChartersState extends State<AddfeaturedCharters> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameCon = TextEditingController();
  TextEditingController subheadingCon = TextEditingController();
  TextEditingController locationCon = TextEditingController();
  TextEditingController priceFourCon = TextEditingController();
  TextEditingController priceEightCon = TextEditingController();
  TextEditingController priceFullCon = TextEditingController();
  TextEditingController guestCountCon = TextEditingController();
  TextEditingController dockCon = TextEditingController();
  TextEditingController slipCon = TextEditingController();
  FocusNode locationFn = FocusNode();
  FocusNode nameFn = FocusNode();
  FocusNode priceFourFn = FocusNode();
  FocusNode priceEightFn = FocusNode();
  FocusNode priceFullFn = FocusNode();
  FocusNode guestCountFn = FocusNode();
  FocusNode subheadingFn = FocusNode();
  FocusNode dockFn = FocusNode();
  FocusNode slipFn = FocusNode();
  LatLng? locationLatLng;
  String? city;
  bool isEdit = false;
  bool isFourHours = false;
  bool isEightHours = false;
  bool isFullDay = false;
  CharterModel? charterModel;
  int index = -1;
  List<XFile> fileImages = [];
  List<String> networkImagesList = [];
  List<String> deletedImagesRef = [];
  int isPetAllow = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var vm = Provider.of<SearchVm>(context, listen: false);
      var provider = Provider.of<YachtVm>(context, listen: false);
      vm.start = null;
      vm.end = null;
      networkImagesList = [];
      fileImages = [];
      deletedImagesRef = [];
      provider.charterModel = CharterModel();
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      charterModel = args["charterModel"];
      isEdit = args["isEdit"];
      index = args["index"];

      if (isEdit == true) {
        provider.charterModel = charterModel;
        nameCon.text = charterModel?.name ?? "";
        city = charterModel?.location?.city;
        locationCon.text = charterModel?.location?.adress ?? "";
        subheadingCon.text = charterModel?.subHeading ?? "";
        guestCountCon.text = charterModel?.guestCapacity?.toString() ?? "";
        dockCon.text = charterModel?.location?.dockno.toString() ?? "";
        slipCon.text = charterModel?.location?.slipno.toString() ?? "";

        /// TODO SET PRICES
        priceEightCon.text = charterModel?.priceHalfDay != 0
            ? charterModel?.priceHalfDay?.toString() ?? ""
            : "";
        priceFullCon.text = charterModel?.priceFullDay != 0
            ? charterModel?.priceFullDay?.toString() ?? ""
            : "";
        priceFourCon.text = charterModel?.priceFourHours != 0
            ? charterModel?.priceFourHours?.toString() ?? ""
            : "";
        isFourHours = charterModel?.priceFourHours != 0;
        isEightHours = charterModel?.priceHalfDay != 0;
        isFullDay = charterModel?.priceFullDay != 0;
        locationLatLng = LatLng(charterModel?.location?.lat ?? 25.7716239,
            charterModel?.location?.long ?? -80.1397398);
        networkImagesList = List.from(charterModel?.images ?? []);
        provider.update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<YachtVm, SearchVm>(
        builder: (context, provider, searchVm, _) {
      return ModalProgressHUD(
        inAsyncCall: provider.isLoading,
        progressIndicator: SpinKitPulse(
          color: R.colors.themeMud,
        ),
        child: Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(
              context, getTranslated(context, "charter_fleet") ?? ""),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  h2,
                  Text(
                    getTranslated(context, "upload_charter_images") ?? "",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  h2,
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white),
                    padding: EdgeInsets.symmetric(
                        horizontal: Get.width * .04,
                        vertical: Get.height * .02),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                List<XFile>? images =
                                    (await ImagePickerServices()
                                        .getMultipleImages())!;
                                images?.forEach((element) {
                                  fileImages.add(element);
                                });
                                provider.update();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(3.0),
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(8),
                                  color: R.colors.themeMud,
                                  dashPattern: [2, 2],
                                  strokeWidth: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              R.colors.gradMudLight,
                                              R.colors.gradMud,
                                              R.colors.gradMud,
                                            ]),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: R.colors.themeMud)),
                                    padding: EdgeInsets.all(10),
                                    child: Icon(
                                      Icons.cloud_upload,
                                      color: R.colors.whiteColor,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            h0P9,
                            Text(
                              getTranslated(context, "upload") ?? "",
                              style: R.textStyle.helvetica().copyWith(
                                  color: R.colors.black, fontSize: 8.sp),
                            )
                          ],
                        ),
                        if (networkImagesList.isNotEmpty == true ||
                            fileImages.isNotEmpty == true)
                          Expanded(
                              child: SizedBox(
                            height: Get.height * .1,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: networkImagesList
                                    .map(
                                      (e) => imageNetwork(e, provider),
                                    )
                                    .toList()
                                  ..addAll(fileImages
                                      .map(
                                        (e) => imgFile(e, provider),
                                      )
                                      .toList())),
                          ))
                        else
                          SizedBox()
                      ],
                    ),
                  ),
                  h2,
                  Text(
                    getTranslated(context, "charter_details") ?? "",
                    style: R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteColor,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  h2,
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        label(getTranslated(
                              context,
                              "charter_name",
                            ) ??
                            ""),
                        h0P5,
                        TextFormField(
                          focusNode: nameFn,
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
                                  .requestFocus(FocusNode());
                            });
                          },
                          controller: nameCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(nameCon.text),
                          decoration: AppDecorations.suffixTextField(
                              "enter_charter_name",
                              R.textStyle.helvetica().copyWith(
                                  color: nameFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h1P5,
                        label(getTranslated(
                              context,
                              "sub_heading",
                            ) ??
                            ""),
                        h0P5,
                        TextFormField(
                          focusNode: subheadingFn,
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
                                  .requestFocus(FocusNode());
                            });
                          },
                          controller: subheadingCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(val),
                          decoration: AppDecorations.suffixTextField(
                              "enter_sub_heading",
                              R.textStyle.helvetica().copyWith(
                                  color: subheadingFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h1P5,
                        label("Marina Location"),
                        h0P5,
                        TextFormField(
                          focusNode: locationFn,
                          textInputAction: TextInputAction.next,
                          readOnly: true,
                          onChanged: (v) {
                            setState(() {});
                          },
                          onTap: () {
                            Get.to(PickLocation(
                              selectedLatLng: locationLatLng ?? null,
                            ))?.then((value) {
                              var result = value;
                              Map<String, dynamic>;
                              log("____RESUKT:${result["locationAddress"]}");
                              setState(() {
                                locationCon.text = result["locationAddress"];
                                locationLatLng = result["latlng"];
                                city = result["city"];
                              });
                            });
                          },
                          onFieldSubmitted: (a) {
                            setState(() {
                              FocusScope.of(Get.context!)
                                  .requestFocus(FocusNode());
                            });
                          },
                          controller: locationCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(locationCon.text),
                          decoration: AppDecorations.suffixTextField(
                              "enter_charter_location",
                              R.textStyle.helvetica().copyWith(
                                  color: locationFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              Image.asset(
                                R.images.location,
                                scale: 4,
                              )),
                        ),
                        h1P5,
                        label("Slip Number"),
                        h0P5,
                        TextFormField(
                          focusNode: slipFn,
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
                                  .requestFocus(FocusNode());
                            });
                          },
                          controller: slipCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(val),
                          decoration: AppDecorations.suffixTextField(
                              "enter_slip",
                              R.textStyle.helvetica().copyWith(
                                  color: subheadingFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h1P5,
                        label("Dock Number"),
                        h0P5,
                        TextFormField(
                          focusNode: dockFn,
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
                                  .requestFocus(FocusNode());
                            });
                          },
                          controller: dockCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(val),
                          decoration: AppDecorations.suffixTextField(
                              "enter_dock",
                              R.textStyle.helvetica().copyWith(
                                  color: subheadingFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h1P5,
                        label(getTranslated(
                              context,
                              "guest_capacity",
                            ) ??
                            ""),
                        h0P5,
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          keyboardType: TextInputType.number,
                          focusNode: guestCountFn,
                          onChanged: (v) {
                            setState(() {});
                          },
                          onTap: () {
                            setState(() {});
                          },
                          onFieldSubmitted: (a) {
                            setState(() {
                              FocusScope.of(Get.context!)
                                  .requestFocus(FocusNode());
                            });
                          },
                          controller: guestCountCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(val),
                          decoration: AppDecorations.suffixTextField(
                              "enter_guest_capacity",
                              R.textStyle.helvetica().copyWith(
                                  color: guestCountFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h1P5,
                        label(getTranslated(
                              context,
                              "allow_pets",
                            ) ??
                            ""),
                        h0P5,
                        Container(
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: R.colors.whiteColor,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 2.h, horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, "allow_pets") ?? "",
                                style: R.textStyle.helvetica().copyWith(
                                    color: guestCountFn.hasFocus
                                        ? R.colors.themeMud
                                        : R.colors.charcoalColor,
                                    fontSize: 10.sp),
                              ),
                              h1P5,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  allowPetRadio("yes", 0),
                                  allowPetRadio("no", 1),
                                  SizedBox()
                                ],
                              ),
                            ],
                          ),
                        ),
                        h1P5,
                        label(getTranslated(
                              context,
                              "price",
                            ) ??
                            ""),
                        h0P5,
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFourHours = !isFourHours;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: R.colors.black,
                                          ),
                                          shape: BoxShape.circle,
                                          color: R.colors.whiteColor),
                                      padding: EdgeInsets.all(2),
                                      child: Container(
                                        height: 8.sp,
                                        width: 8.sp,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isFourHours
                                                ? R.colors.themeMud
                                                : Colors.transparent),
                                      ),
                                    ),
                                    w3,
                                    Text(
                                      getTranslated(context, "four_hours") ??
                                          "",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 10.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            w2,
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                readOnly: !isFourHours,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                keyboardType: TextInputType.number,
                                focusNode: priceFourFn,
                                onChanged: (v) {
                                  setState(() {});
                                },
                                onTap: () {
                                  setState(() {});
                                },
                                onFieldSubmitted: (a) {
                                  setState(() {
                                    FocusScope.of(Get.context!)
                                        .requestFocus(FocusNode());
                                  });
                                },
                                controller: priceFourCon,
                                validator: (val) => isFourHours
                                    ? FieldValidator.validateRequiredPrice(val)
                                    : null,
                                decoration: AppDecorations.suffixTextField(
                                    "price_four_hours",
                                    R.textStyle.helvetica().copyWith(
                                        color: priceFourFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    SizedBox()),
                              ),
                            ),
                          ],
                        ),
                        h0P5,
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isEightHours = !isEightHours;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: R.colors.black,
                                          ),
                                          shape: BoxShape.circle,
                                          color: R.colors.whiteColor),
                                      padding: EdgeInsets.all(2),
                                      child: Container(
                                        height: 8.sp,
                                        width: 8.sp,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isEightHours
                                                ? R.colors.themeMud
                                                : Colors.transparent),
                                      ),
                                    ),
                                    w3,
                                    Text(
                                      getTranslated(context, "eight_hours") ??
                                          "",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 10.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            w2,
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                readOnly: !isEightHours,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                keyboardType: TextInputType.number,
                                focusNode: priceEightFn,
                                onChanged: (v) {
                                  setState(() {});
                                },
                                onTap: () {
                                  setState(() {});
                                },
                                onFieldSubmitted: (a) {
                                  setState(() {
                                    FocusScope.of(Get.context!)
                                        .requestFocus(FocusNode());
                                  });
                                },
                                controller: priceEightCon,
                                validator: (val) => isEightHours
                                    ? FieldValidator.validateRequiredPrice(
                                        priceEightCon.text)
                                    : null,
                                decoration: AppDecorations.suffixTextField(
                                    "price_eight_hours",
                                    R.textStyle.helvetica().copyWith(
                                        color: priceEightFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    SizedBox()),
                              ),
                            ),
                          ],
                        ),
                        h0P5,
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isFullDay = !isFullDay;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: R.colors.black,
                                          ),
                                          shape: BoxShape.circle,
                                          color: R.colors.whiteColor),
                                      padding: EdgeInsets.all(2),
                                      child: Container(
                                        height: 8.sp,
                                        width: 8.sp,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isFullDay
                                                ? R.colors.themeMud
                                                : Colors.transparent),
                                      ),
                                    ),
                                    w3,
                                    Text(
                                      getTranslated(context, "twenty_hours") ??
                                          "",
                                      style: R.textStyle.helvetica().copyWith(
                                          color: R.colors.whiteColor,
                                          fontSize: 10.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            w2,
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                readOnly: !isFullDay,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                keyboardType: TextInputType.number,
                                focusNode: priceFullFn,
                                onChanged: (v) {
                                  setState(() {});
                                },
                                onTap: () {
                                  setState(() {});
                                },
                                onFieldSubmitted: (a) {
                                  setState(() {
                                    FocusScope.of(Get.context!)
                                        .requestFocus(FocusNode());
                                  });
                                },
                                controller: priceFullCon,
                                validator: (val) => isFullDay
                                    ? FieldValidator.validateRequiredPrice(
                                        priceFullCon.text)
                                    : null,
                                decoration: AppDecorations.suffixTextField(
                                    "price_twenty_hours",
                                    R.textStyle.helvetica().copyWith(
                                        color: priceFullFn.hasFocus
                                            ? R.colors.themeMud
                                            : R.colors.charcoalColor,
                                        fontSize: 10.sp),
                                    SizedBox()),
                              ),
                            ),
                          ],
                        ),
                        h1P5,
                        tiles("choose_experiences", 4, provider),
                        h1P5,
                        tiles("availability", 5, provider),
                        h1P5,
                        tiles("yacht_rules", 6, provider),
                        h1P5,
                        tiles("health_and_safety", 7, provider),
                        h1P5,
                        tiles("boarding_instructions", 8, provider),
                        h5,
                        GestureDetector(
                          onTap: () async {
                            // FbCollections.charterFleet.doc("vXlmg5EL423G80qB5pBE").get().then((value) {
                            //   log("${jsonEncode(value.data())}");
                            // });

                            if (formKey.currentState!.validate()) {
                              if (provider
                                      .charterModel?.chartersOffers?.isEmpty ==
                                  true) {
                                Helper.inSnackBar(
                                    "Error",
                                    "Please select charter offers",
                                    R.colors.themeMud);
                              } else if (provider.charterModel?.availability ==
                                      null ||
                                  provider.charterModel?.availability?.dates
                                          ?.isEmpty ==
                                      true) {
                                Helper.inSnackBar(
                                    "Error",
                                    "Please select charter availability",
                                    R.colors.themeMud);
                              } else if (!isFourHours &&
                                  !isEightHours &&
                                  !isFullDay) {
                                Helper.inSnackBar(
                                    "Error",
                                    "Please select at least 1 price slot",
                                    R.colors.themeMud);
                              } else {
                                await provider.onClickAddCharter(
                                    isPetAllow,
                                    city,
                                    isEdit,
                                    fileImages,
                                    networkImagesList,
                                    deletedImagesRef,
                                    subheadingCon.text,
                                    guestCountCon.text,
                                    priceFourCon.text,
                                    priceEightCon.text,
                                    priceFullCon.text,
                                    nameCon.text,
                                    locationCon.text,
                                    locationLatLng,
                                    dockCon.text,
                                    slipCon.text,
                                    context);
                              }
                            }
                          },
                          child: Container(
                            height: Get.height * .06,
                            decoration:
                                AppDecorations.gradientButton(radius: 30),
                            child: Center(
                              child: Text(
                                isEdit == true
                                    ? "Save"
                                    : "${getTranslated(context, "add")?.toUpperCase()}",
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
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget allowPetRadio(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPetAllow = index;
        });
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: R.colors.black,
                ),
                shape: BoxShape.circle,
                color: R.colors.whiteColor),
            padding: EdgeInsets.all(2),
            child: Container(
              height: 8.sp,
              width: 8.sp,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPetAllow == index
                      ? R.colors.black
                      : Colors.transparent),
            ),
          ),
          w3,
          Text(
            getTranslated(context, title) ?? "",
            style: R.textStyle.helvetica().copyWith(
                color: guestCountFn.hasFocus
                    ? R.colors.themeMud
                    : R.colors.charcoalColor,
                fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  Widget tiles(String title, int index, YachtVm provider) {
    return Consumer2<YachtVm, SearchVm>(
        builder: (context, yachtVm, provider, _) {
      return GestureDetector(
        onTap: () {
          switch (index) {
            case 4:
              {
                // String docId=Timestamp.now().millisecondsSinceEpoch.toString();
                // ChooseOffers chooseOffers=ChooseOffers(
                //   id: docId,
                //   status: true,
                //   icon: "https://firebasestorage.googleapis.com/v0/b/yacht-masters.appspot.com/o/s1.png?alt=media&token=75e3fbad-48ca-417b-aa3e-506c8d5dcf52&_gl=1*g3xnxz*_ga*MTc2NTUwNDUwLjE2NzMyODU5MjM.*_ga_CW55HF8NVT*MTY5NzcwODM5MS4yMDAuMS4xNjk3NzA4NzY3LjYuMC4w",
                //   title: "Jet Skis",
                // );
                //  FbCollections.chartersOffers.doc(docId).set(chooseOffers.toJson());
                Get.toNamed(
                  ChooseServices.route,
                );
              }
              break;
            case 5:
              Get.toNamed(DefineAvailibility.route, arguments: {
                "charter":
                    yachtVm.charterModel?.availability?.dates?.isNotEmpty ==
                            true
                        ? yachtVm.charterModel
                        : null,
                "isReadOnly": false
              });
              break;
            case 6:
              Get.bottomSheet(RulesBottomSheet(
                  title: "yacht_rules",
                  index: index,
                  subTitle:
                      "mention_all_the_yacht_rules_you_want_to_share_with_others"));
              break;
            case 7:
              Get.bottomSheet(RulesBottomSheet(
                  title: "health_and_safety",
                  index: index,
                  subTitle:
                      "mention_all_the_health_and_safety_you_want_to_share_with_others"));
              break;
            case 8:
              Get.bottomSheet(RulesBottomSheet(
                  title: "boarding_instructions",
                  index: index,
                  subTitle:
                      "mention_all_the_boarding_instructions_you_want_to_share_with_others"));
              break;
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: R.colors.black)),
          padding: EdgeInsets.symmetric(
              horizontal: Get.width * .03, vertical: Get.height * .018),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                index == 8 &&
                        (yachtVm.charterModel?.boardingInstructions?.title !=
                                "" &&
                            yachtVm.charterModel?.boardingInstructions != null)
                    ? "${yachtVm.charterModel?.boardingInstructions?.title}"
                    : index == 7 &&
                            (yachtVm.charterModel?.healthSafety?.title != "" &&
                                yachtVm.charterModel?.healthSafety != null)
                        ? "${yachtVm.charterModel?.healthSafety?.title}"
                        : index == 6 &&
                                (yachtVm.charterModel?.yachtRules?.title !=
                                        "" &&
                                    yachtVm.charterModel?.yachtRules != null)
                            ? "${yachtVm.charterModel?.yachtRules?.title}"
                            : index == 5 &&
                                    (provider.start != null &&
                                        provider.end != null)
                                ? "${DateFormat("MMM dd,yyyy").format(provider.start!)} - ${DateFormat("MMM dd,yyyy").format(provider.end!)}"
                                : getTranslated(context, title) ?? "",
                style: R.textStyle.helvetica().copyWith(
                    color: index == 7 &&
                                (yachtVm.charterModel?.healthSafety?.title != "" &&
                                    yachtVm.charterModel?.healthSafety !=
                                        null) ||
                            index == 8 &&
                                (yachtVm.charterModel?.boardingInstructions?.title != "" &&
                                    yachtVm.charterModel?.boardingInstructions !=
                                        null) ||
                            index == 6 &&
                                (yachtVm.charterModel?.yachtRules?.title != "" &&
                                    yachtVm.charterModel?.yachtRules != null) ||
                            index == 5 &&
                                (provider.start != null &&
                                    provider.end != null) ||
                            index == 4 &&
                                yachtVm.charterModel?.chartersOffers?.isNotEmpty ==
                                    true ||
                            index == 5 &&
                                yachtVm.charterModel?.availability?.dates?.isNotEmpty == true
                        ? R.colors.black
                        : R.colors.charcoalColor,
                    fontSize: 10.sp),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: R.colors.blackDull,
                size: 20,
              )
            ],
          ),
        ),
      );
    });
  }

  Widget imageNetwork(String image, YachtVm provider) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 6.5.h,
              width: 6.5.h,
              decoration: BoxDecoration(
                color: R.colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SpinKitPulse(
                    color: R.colors.themeMud,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () async {
                  print("_________eree");
                  deletedImagesRef.add(image);
                  networkImagesList.remove(image);
                  provider.update();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: R.colors.themeMud, shape: BoxShape.circle),
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: R.colors.whiteColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget imgFile(
    XFile file,
    YachtVm provider,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 6.5.h,
              width: 6.5.h,
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: R.colors.black,
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                    image: FileImage(File(
                      file.path,
                    )),
                    fit: BoxFit.contain),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                onTap: () {
                  print("_________eree");
                  fileImages.remove(file);
                  provider.update();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: R.colors.themeMud, shape: BoxShape.circle),
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: R.colors.whiteColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
