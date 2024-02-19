import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
import 'package:yacht_master/src/base/yacht/model/yachts_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/src/base/yacht/widgets/choose_services.dart';
import 'package:yacht_master/src/base/yacht/widgets/rules_bottomsheet.dart';
import 'package:yacht_master/utils/general_app_bar.dart';
import 'package:yacht_master/utils/heights_widths.dart';
import 'package:yacht_master/utils/helper.dart';
import 'package:yacht_master/utils/pick_location.dart';
import 'package:yacht_master/utils/validation.dart';

class AddYachtForSale extends StatefulWidget {
  static String route = "/addYachtForSale";
  const AddYachtForSale({Key? key}) : super(key: key);

  @override
  _AddYachtForSaleState createState() => _AddYachtForSaleState();
}

class _AddYachtForSaleState extends State<AddYachtForSale> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameCon = TextEditingController();
  TextEditingController addressCon = TextEditingController();
  TextEditingController locationCon = TextEditingController();
  TextEditingController priceCon = TextEditingController();
  TextEditingController descCon = TextEditingController();
  FocusNode descFn = FocusNode();
  FocusNode locationFn = FocusNode();
  FocusNode nameFn = FocusNode();
  FocusNode addressFn = FocusNode();
  FocusNode priceFn = FocusNode();
  LatLng? locationLatLng;
  String? city;
  bool isEdit = false;
  YachtsModel? yachtsModel;
  int index = -1;
  List<XFile> fileImages=[];
  List<String> networkImagesList=[];
  List<String> deletedImagesRef=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var provider = Provider.of<YachtVm>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider.yachtsModel = YachtsModel();
      networkImagesList=[];
      fileImages=[];
      deletedImagesRef=[];
      var args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      yachtsModel = args["yachtsModel"];
      isEdit = args["isEdit"];
      index = args["index"];
      if (isEdit == true) {
        provider.yachtsModel = yachtsModel;
        nameCon.text = yachtsModel?.name ?? "";
        locationCon.text = yachtsModel?.location?.address ?? "";
        priceCon.text = yachtsModel?.price.toString()??"";
        descCon.text = yachtsModel?.description ?? "";
        locationLatLng=LatLng(yachtsModel?.location?.lat??25.7716239, yachtsModel?.location?.long??-80.1397398);
        networkImagesList=List.from(yachtsModel?.images??[]);
        setState(() {});
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
        progressIndicator:   SpinKitPulse(color: R.colors.themeMud,),
        child: Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(
              context, getTranslated(context, "yacht_for_sale") ?? ""),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * .05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  h2,
                  Text(
                    getTranslated(context, "upload_yacht_images") ?? "",
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
                        horizontal: Get.width * .04, vertical: Get.height * .02),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap:() async {
                                List<XFile>? images=(await ImagePickerServices().getMultipleImages())!;
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
                                        border:
                                            Border.all(color: R.colors.themeMud)),
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
                        if (networkImagesList.isNotEmpty==true || fileImages.isNotEmpty==true)
                          Expanded(
                              child: SizedBox(
                                height: Get.height*.1,
                                child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: networkImagesList.map((e) => imageNetwork(e,provider),).toList()
                                      ..addAll(fileImages.map((e) => imgFile(e,provider),).toList())
                                ),
                              )
                          )
                        else SizedBox()
                      ],
                    ),
                  ),
                  h2,
                  Text(
                    getTranslated(context, "yacht_detail") ?? "",
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
                              "yacht_name",
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
                                  .requestFocus(new FocusNode());
                            });
                          },
                          controller: nameCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(nameCon.text),
                          decoration: AppDecorations.suffixTextField(
                              "enter_yacht_name",
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
                              "charter_location",
                            ) ??
                            ""),
                        h0P5,
                        TextFormField(
                          focusNode: locationFn,
                          textInputAction: TextInputAction.next,
                          readOnly: true,
                          onChanged: (v) {
                            setState(() {});
                          },
                          onTap: () {
                            Get.to(PickLocation(selectedLatLng: locationLatLng ?? null,))?.then((value) {
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
                                  .requestFocus(new FocusNode());
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
                        label(getTranslated(
                              context,
                              "price",
                            ) ??
                            ""),
                        h0P5,
                        TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: priceFn,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          keyboardType: TextInputType.number,
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
                          controller: priceCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(priceCon.text),
                          decoration: AppDecorations.suffixTextField(
                              "enter_price",
                              R.textStyle.helvetica().copyWith(
                                  color: priceFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h1P5,
                        label("Description"),
                        h0P5,
                        TextFormField(
                          focusNode: descFn,
                          textInputAction: TextInputAction.next,
                          maxLines: 4,
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
                          controller: descCon,
                          validator: (val) =>
                              FieldValidator.validateRequired(val),
                          decoration: AppDecorations.suffixTextField(
                              "write_here",
                              R.textStyle.helvetica().copyWith(
                                  color: descFn.hasFocus
                                      ? R.colors.themeMud
                                      : R.colors.charcoalColor,
                                  fontSize: 10.sp),
                              SizedBox()),
                        ),
                        h5,
                        GestureDetector(
                          onTap: () async {
                            // FbCollections.yachtForSale.doc("8IOKxfIaWyycTLDcONJI").get().then((value) {
                            //   log("${jsonEncode(value.data())}");
                            // });
                            if (formKey.currentState!.validate()) {
                              await provider.onClickAddYacht(city,isEdit, fileImages, networkImagesList, deletedImagesRef, descCon.text, priceCon.text,nameCon.text, locationCon.text, locationLatLng, context);
                            }
                          },
                          child: Container(
                            height: Get.height * .06,
                            decoration: AppDecorations.gradientButton(radius: 30),
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

  Widget tiles(String title, int index, YachtVm provider) {
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 4:
            Get.toNamed(ChooseServices.route);
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
                title: "cancellation_policy",
                index: index,
                subTitle:
                    "mention_all_the_cancellation_policy_you_want_to_share_with_others"));
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
              getTranslated(context, title) ?? "",
              style: R.textStyle
                  .helvetica()
                  .copyWith(color: R.colors.charcoalColor, fontSize: 10.sp),
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
  }

  Widget imageNetwork(String image,YachtVm provider) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 6.5.h,
              width: 6.5.h,
              margin: EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl:  image,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SpinKitPulse(color: R.colors.themeMud,),
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
                    color:R.colors.whiteColor,
                  ),
                ),
              ),
            )
          ],
        ),

      ],
    );
  }
  Widget imgFile(XFile file,YachtVm provider,) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 6.5.h,
              width: 6.5.h,
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image:
                DecorationImage(
                    image:
                    FileImage(File(
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
                    color:R.colors.whiteColor,
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
