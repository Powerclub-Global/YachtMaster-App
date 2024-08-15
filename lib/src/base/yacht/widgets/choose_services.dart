import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../localization/app_localization.dart';
import '../../../../resources/decorations.dart';
import '../../../../resources/resources.dart';
import '../../../../services/firebase_collections.dart';
import '../../search/model/charter_model.dart';
import '../../search/view_model/search_vm.dart';
import '../model/choose_offers.dart';
import '../view_model/yacht_vm.dart';
import '../../../../utils/general_app_bar.dart';
import '../../../../utils/heights_widths.dart';

class ChooseServices extends StatefulWidget {
  static String route="/chooseServices";
  const ChooseServices({Key? key}) : super(key: key);

  @override
  _ChooseServicesState createState() => _ChooseServicesState();
}

class _ChooseServicesState extends State<ChooseServices> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var yachtVm=Provider.of<YachtVm>(context,listen: false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      yachtVm.startLoader();
      yachtVm.selectedOffers=[];
      yachtVm.fetchCharterOffers();
      yachtVm.charterModel?.chartersOffers?.forEach((element) async {
        DocumentSnapshot doc=await FbCollections.chartersOffers.doc(element).get();
        yachtVm.selectedOffers.add(ChooseOffers.fromJson(doc.data()));
        yachtVm.update();
      });
      yachtVm.update();
      yachtVm.stopLoader();

    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer2<YachtVm,SearchVm>(
        builder: (context, provider, searchVm,_) {
          return ModalProgressHUD(
            inAsyncCall: provider.isLoading,
            progressIndicator:SpinKitPulse(color: R.colors.themeMud,),
            child: Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "charter_offers")??""),
            body: Padding(
              padding:  EdgeInsets.symmetric(horizontal: Get.width*.05,vertical: Get.height*.02),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(getTranslated(context, "choose")??"",style: R.textStyle.helvetica().copyWith(
                        color: R.colors.whiteColor,fontWeight: FontWeight.bold,fontSize: 15.sp
                      ),),
                    ],
                  ),
                  h2,
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      runSpacing: 20,
                      spacing: 20,
                      children:List.generate(provider.chooseServicesList.length, (index) {

                      return choose(provider.chooseServicesList[index], index,provider);
                    }),),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      provider.charterModel?.chartersOffers=[];
                      provider.charterModel?.chartersOffers=List.from(provider.selectedOffers.map((e) => e.id).toList());
                      provider.update();
                      Get.forceAppUpdate();
                      Get.back();
                    },
                    child: Container(
                      height: Get.height*.06,
                      width: Get.width*.6,
                      decoration: AppDecorations.gradientButton(radius: 30),
                      child: Center(
                        child: Text("${getTranslated(context, "save")?.toUpperCase()}",
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
          );
      }
    );
  }
  Widget choose(ChooseOffers service,int index,YachtVm provider)
  {
    return
      GestureDetector(
        onTap: (){
          // provider.chooseServicesList[index].isSelected==true?
          // provider.chooseServicesList[index].isSelected=false:
          // provider.chooseServicesList[index].isSelected=true;
          log("________________________isSeele:${provider.selectedOffers.any((element) => element.id==service.id)}___${provider.selectedOffers.indexOf(service)}");

          provider.selectedOffers.any((element) => element.id==service.id)?
          provider.selectedOffers.removeWhere((element) => element.id==service.id):
          provider.selectedOffers.add(service);
          provider.update();
        },
        child: Container(
        height: Get.height*.13,
        width: Get.width*.4,
        decoration: BoxDecoration(
            color: R.colors.whiteColor,
            border: Border.all(color:
           provider.selectedOffers.any((element) => element.id==service.id)?R.colors.themeMud:
            R.colors.black
            ,width: 2),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Stack(alignment: Alignment.center,
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CachedNetworkImage(imageUrl: service.icon??
                    R.images.serviceUrl
                  ,color:
                  provider.selectedOffers.any((element) => element.id==service.id)? R.colors.themeMud:
                  R.colors.black,height: Get.height*.045,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SpinKitPulse(color: R.colors.themeMud,),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),

                Text(service.title??"",style: R.textStyle.helvetica().copyWith(color:
                provider.selectedOffers.any((element) => element.id==service.id)?R.colors.themeMud:
                R.colors.black,fontSize: 13.sp),)
              ],),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color:
                    provider.selectedOffers.any((element) => element.id==service.id)?R.colors.themeMud:
                    Colors.grey)
                ),
                padding: EdgeInsets.all(2),
                child: Container(height: 13,width: 13,
                  decoration: BoxDecoration(
                      color:
                      provider.selectedOffers.any((element) => element.id==service.id)?R.colors.themeMud:
                      Colors.transparent,
                      shape: BoxShape.circle
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
