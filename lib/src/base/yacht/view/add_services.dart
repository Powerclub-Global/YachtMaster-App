import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:async_foreach/async_foreach.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../../../services/image_picker_services.dart';
import '../../../auth/model/user_model.dart';
import '../../../auth/view_model/auth_vm.dart';
import '../../search/model/services_model.dart';
import '../../search/view_model/search_vm.dart';
import '../model/yachts_model.dart';
import 'define_availibility.dart';
import '../view_model/yacht_vm.dart';
import '../widgets/rules_bottomsheet.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';
import '../../../../utils/helper.dart';
import '../../../../utils/pick_location.dart';
import '../../../../utils/validation.dart';

class AddServices extends StatefulWidget {
  static String route="/addService";
  const AddServices({Key? key}) : super(key: key);

  @override
  _AddServicesState createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices> {

  final formKey = GlobalKey<FormState>();
  TextEditingController nameCon = TextEditingController();
  TextEditingController locationCon = TextEditingController();
  TextEditingController whatYouDoCon = TextEditingController();
  FocusNode locationFn = FocusNode();
  FocusNode nameFn= FocusNode();
  FocusNode whatYouDoFn= FocusNode();
  LatLng? locationLatLng;
  String? city;
  bool isEdit=false;
  ServiceModel? serviceModel;
  int index=-1;
  List<XFile> fileImages=[];
  List<String> networkImagesList=[];
  List<String> deletedImagesRef=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var vm=Provider.of<SearchVm>(context,listen: false);
    var provider=Provider.of<YachtVm>(context,listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      vm.start=null;
      vm.end=null;
      networkImagesList=[];
      fileImages=[];
      deletedImagesRef=[];
      provider.serviceModel=ServiceModel();
      var args=ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      serviceModel=args["service"];
      isEdit=args["isEdit"];
      index=args["index"];
      if(isEdit==true)
        {
          provider.serviceModel=serviceModel;
          nameCon.text=serviceModel?.name??"";
          locationCon.text=serviceModel?.location?.address??"";
          whatYouDoCon.text=serviceModel?.description??"";
          locationLatLng=LatLng(serviceModel?.location?.lat??25.7716239, serviceModel?.location?.log??-80.1397398);
          networkImagesList=List.from(serviceModel?.images??[]);
          setState(() {});
          provider.update();
        }
    });

  }

  @override
  Widget build(BuildContext context) {

    return Consumer3<YachtVm,SearchVm,AuthVm>(
        builder: (context, provider, searchVm,authVm,_) {
      log("_________${isEdit}________${networkImagesList.length}");
          return Scaffold(
          backgroundColor: R.colors.black,
          appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "add_experience")??""),
          body: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: Get.width*.05),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  h2,
                  Text(
                    getTranslated(context, "upload_image") ?? "",
                    style: R.textStyle.helvetica().copyWith(color: R.colors.whiteColor,
                        fontSize: 15.sp,fontWeight: FontWeight.bold),
                  ),
                  h2,
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white
                    ),
                    padding: EdgeInsets.symmetric(horizontal: Get.width*.04,vertical: Get.height*.02),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap:() async {
                                List<XFile>? images=(await ImagePickerServices().getMultipleImages())!;
                                if((fileImages.length+(images?.length??0)+networkImagesList.length)>5)
                                  {
                                    Helper.inSnackBar(
                                        'Error',
                                        "Maximum 5 pictures allowed",
                                        R.colors.themeMud);
                                  }
                               else{
                                  images?.forEach((element) {
                                    fileImages.add(element);
                                  });
                                  provider.update();
                                }
                               },
                              child: Padding(
                                padding:  EdgeInsets.all(3.0),
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
                                            colors:[
                                              R.colors.gradMudLight,
                                              R.colors.gradMud,
                                              R.colors.gradMud,
                                            ] ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: R.colors.themeMud)
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.cloud_upload,color: R.colors.whiteColor,size: 30,),
                                  ),
                                ),
                              ),
                            ),
                            h0P9,
                            Text(getTranslated(context, "upload")??"",
                            style: R.textStyle.helvetica().copyWith(
                              color: R.colors.black,
                                fontSize: 8.sp
                            ),)
                          ],
                        ),
                        if (networkImagesList.isNotEmpty==true || fileImages.isNotEmpty==true)
                          Expanded(
                            child: SizedBox(
                              height: 80,
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
                  getTranslated(context, "tell_us_about_your_experience") ?? "",
                  style: R.textStyle.helvetica().copyWith(color: R.colors.whiteColor,
                      fontSize: 15.sp,fontWeight: FontWeight.bold),
                ),
                h2,
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      label(getTranslated(context,  "experience_name",)??""),
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
                            FieldValidator.validateRequired(
                                nameCon.text),
                        decoration: AppDecorations.suffixTextField(

                            "enter_experience_name",
                            R.textStyle.helvetica().copyWith(
                                color: nameFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                           SizedBox()),
                      ),
                      h1P5,
                      label(getTranslated(context,  "experience_location",)??""),
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
                           var result=value; Map<String, dynamic>;
                           log("____RESUKT:${result["locationAddress"]}");
                           setState(() {
                             locationCon.text=result["locationAddress"];
                             locationLatLng=result["latlng"];
                             city=result["city"];
                           });
                           log("_______________LOcation:${locationLatLng?.latitude}");
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
                            FieldValidator.validateRequired(
                                locationCon.text),
                        decoration: AppDecorations.suffixTextField(
                            "enter_experience_location",
                            R.textStyle.helvetica().copyWith(
                                color: locationFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                            Image.asset(R.images.location,scale: 4,)),
                      ),
                      h1P5,
                      label(getTranslated(context,  "describe_your_experience",)??""),
                      h0P5,
                      TextFormField(
                        textInputAction: TextInputAction.unspecified,
                        focusNode: whatYouDoFn,
                        keyboardType: TextInputType.text,
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
                        controller: whatYouDoCon,
                        maxLines: 4,
                        validator: (val) =>
                            FieldValidator.validateRequired(
                                whatYouDoCon.text),
                        decoration: AppDecorations.suffixTextField(

                            "write_here",
                            R.textStyle.helvetica().copyWith(
                                color: whatYouDoFn.hasFocus
                                    ? R.colors.themeMud
                                    : R.colors.charcoalColor,
                                fontSize: 10.sp),
                            SizedBox()),
                      ),
                      h5,
                      GestureDetector(
                        onTap: () async {

                          if(formKey.currentState!.validate())
                          {
                          await provider.onClickAddService(city,isEdit, fileImages, networkImagesList, deletedImagesRef, whatYouDoCon.text, nameCon.text, locationCon.text, locationLatLng, context);
                          }
                        },
                        child: Container(
                          height: Get.height*.06,
                          decoration: AppDecorations.gradientButton(radius: 30),
                          child: Center(
                            child: Text(
                                isEdit==true?
                                    "Save":
                              "${getTranslated(context, "add")?.toUpperCase()}",
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
              ],),
            ),
          ),
        );
      }
    );
  }
  Widget tiles(String title,int index)
  {
    return Consumer2<YachtVm,SearchVm>(
        builder: (context, yachtVm,provider,_) {
          return GestureDetector(
          onTap: (){
            switch(index)
            {
              case 0:
                Get.toNamed(DefineAvailibility.route,arguments: {"charter":null,"isReadOnly":false});
                break;
                case 1:
                Get.bottomSheet(RulesBottomSheet(title: "yacht_rules",index: index,subTitle:"mention_all_the_yacht_rules_you_want_to_share_with_others"));
                break;
              case 2:
                Get.bottomSheet(RulesBottomSheet(title: "health_and_safety",index: index,subTitle:"mention_all_the_health_and_safety_you_want_to_share_with_others"));
                break;
              case 3:
                Get.bottomSheet(RulesBottomSheet(title: "cancellation_policy",index: index,subTitle:"mention_all_the_cancellation_policy_you_want_to_share_with_others"));
                break;
            }
          },
          child: Container(
            decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color:R.colors.black
                )
            ),
            padding: EdgeInsets.symmetric(horizontal: Get.width*.03,
                vertical: Get.height*.018),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  index==0 && (provider.start!=null && provider.end!=null)?
                    "${DateFormat("MMM dd,yyyy").format(provider.start!)} - ${DateFormat("MMM dd,yyyy").format(provider.end!)}":
                  getTranslated(context, title)??"",
                  style:R.textStyle.helvetica().copyWith(
                      color:
                      index==0 && (provider.start!=null && provider.end!=null)

                      ? R.colors.black
                          : R.colors.charcoalColor,
                      fontSize: 10.sp),),
                Icon(Icons.arrow_forward_ios_rounded,color: R.colors.blackDull,size: 20,)
              ],
            ),
          ),
        );
      }
    );
  }
  Widget imageNetwork(String image,YachtVm provider) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height:55,
              width: 55,
              decoration: BoxDecoration(
                color: R.colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
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
              height:55,
              width: 55,
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: R.colors.black,
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
