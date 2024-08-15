import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
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

class ViewAllServices extends StatefulWidget {
  static String route="/viewAllServices";
  const ViewAllServices({Key? key}) : super(key: key);

  @override
  _ViewAllServicesState createState() => _ViewAllServicesState();
}

class _ViewAllServicesState extends State<ViewAllServices> {
  CharterModel? charter;
  @override
  Widget build(BuildContext context) {
    var args=ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    charter=args["charter"];
    return Consumer2<YachtVm,SearchVm>(
        builder: (context, provider, searchVm,_) {
          return Scaffold(
            backgroundColor: R.colors.black,
            appBar: GeneralAppBar.simpleAppBar(context, getTranslated(context, "charter_offers")??""),
            body: Padding(
              padding:  EdgeInsets.symmetric(horizontal: Get.width*.05,vertical: Get.height*.02),
              child: Column(
                children: [

                  h2,
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
                      runSpacing: 20,
                      spacing: 20,
                      children:List.generate(charter?.chartersOffers?.length??0, (index) {
                        return FutureBuilder(
                          future: FbCollections.chartersOffers.doc(charter?.chartersOffers?[index]).get(),
                          builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if(!snapshot.hasData)
                              {
                                return SpinKitPulse(color: R.colors.themeMud,);
                              }
                            else{
                              ChooseOffers offer=ChooseOffers.fromJson(snapshot.data);
                              return choose(
                                  offer
                                  , index,provider);
                            }
                          }
                        );
                      }),),
                  ),

                  h2,
                ],
              ),
            ),
          );
        }
    );
  }
  Widget choose(ChooseOffers? service,int index,YachtVm provider)
  {
    return
      Container(
        height: Get.height*.13,
        width: Get.width*.4,
        decoration: BoxDecoration(
            color: R.colors.whiteColor,
            border: Border.all(color: R.colors.black
                ,width: 2),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CachedNetworkImage(imageUrl: service?.icon??
                R.images.serviceUrl
              ,color:
              R.colors.black,height: Get.height*.045,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  SpinKitPulse(color: R.colors.themeMud,),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Text(service?.title??"",style: R.textStyle.helvetica().copyWith(color: R.colors.black,fontSize: 13.sp),)
          ],),
      );
  }
}
