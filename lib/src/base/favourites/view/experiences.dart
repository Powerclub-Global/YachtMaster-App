import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:yacht_master/constant/enums.dart';
import 'package:yacht_master/resources/resources.dart';
import 'package:yacht_master/services/firebase_collections.dart';
import 'package:yacht_master/src/auth/model/favourite_model.dart';
import 'package:yacht_master/src/base/favourites/view_model/favourites_vm.dart';
import 'package:yacht_master/src/base/search/model/services_model.dart';
import 'package:yacht_master/src/base/search/view_model/search_vm.dart';
import 'package:yacht_master/src/base/search/widgets/host_widget.dart';
import 'package:yacht_master/src/base/yacht/view/service_detail.dart';
import 'package:yacht_master/src/base/yacht/view_model/yacht_vm.dart';
import 'package:yacht_master/utils/empty_screem.dart';
import 'package:yacht_master/utils/heights_widths.dart';

class ExperiencesView extends StatefulWidget {
  const ExperiencesView({Key? key}) : super(key: key);

  @override
  _ExperiencesViewState createState() => _ExperiencesViewState();
}

class _ExperiencesViewState extends State<ExperiencesView> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<YachtVm, SearchVm>(
        builder: (context, yachtVm, provider, _) {
      return yachtVm.userFavouritesList
              .where((element) => element.type == FavouriteType.service.index)
              .toList()
              .isEmpty
          ? EmptyScreen(
              title: "no_experience",
              subtitle: "no_experience_has_been_saved_yet",
              img: R.images.noFav,
            )
          : ModalProgressHUD(
              inAsyncCall: yachtVm.isLoading,
              progressIndicator: SpinKitPulse(color: R.colors.themeMud,),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Get.width * .04, vertical: Get.height * .02),
                child: SingleChildScrollView(
                  child: Center(
                    child: Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      alignment: WrapAlignment.start,
                      children: List.generate(
                          yachtVm.userFavouritesList
                              .where((element) =>
                                  element.type == FavouriteType.service.index)
                              .toList()
                              .length, (index) {
                        FavouriteModel favModel = yachtVm.userFavouritesList
                            .where((element) =>
                                element.type == FavouriteType.service.index)
                            .toList()[index];
                        return FutureBuilder(
                            future:
                                FbCollections.services.doc(favModel.id).get(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox();
                              } else {
                                ServiceModel service = ServiceModel.fromJson(
                                    snapshot.data?.data());
                                return GestureDetector(
                                  onTap: () {
                                    Get.toNamed(ServiceDetail.route,
                                        arguments: {
                                          "service": service,
                                          "isHostView": false,
                                          "index": -1
                                        });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index ==
                                                yachtVm.userFavouritesList
                                                        .length -
                                                    1
                                            ? 8.h
                                            : 10),
                                    child: HostWidget(
                                      service: service,
                                      width: Get.width * .27,
                                      height: Get.height * .2,
                                      isShowRating: false,
                                      isShowStar: true,
                                      isFav: yachtVm.userFavouritesList.any(
                                          (element) =>
                                              element.favouriteItemId ==
                                                  service.id &&
                                              element.type ==
                                                  FavouriteType.service.index),
                                      isFavCallBack: () async {
                                        yachtVm.startLoader();
                                        FavouriteModel favModel =
                                            FavouriteModel(
                                                creaatedAt: Timestamp.now(),
                                                favouriteItemId: service.id,
                                                id: service.id,
                                                type: FavouriteType
                                                    .service.index);
                                        if (yachtVm.userFavouritesList.any(
                                            (element) =>
                                                element.id == service.id &&
                                                element.type ==
                                                    FavouriteType
                                                        .service.index)) {
                                          yachtVm.userFavouritesList
                                              .removeAt(index);
                                          yachtVm.update();
                                          try {
                                            await FbCollections.user
                                                .doc(FirebaseAuth
                                                    .instance.currentUser?.uid)
                                                .collection("favourite")
                                                .doc(service.id)
                                                .delete();
                                          } on Exception catch (e) {
                                            log(e.toString());
                                            yachtVm.stopLoader();
                                          }
                                        } else {
                                          try {
                                            await FbCollections.user
                                                .doc(FirebaseAuth
                                                    .instance.currentUser?.uid)
                                                .collection("favourite")
                                                .doc(service.id)
                                                .set(favModel.toJson());
                                          } on Exception catch (e) {
                                            log(e.toString());
                                            yachtVm.stopLoader();
                                          }
                                        }
                                        yachtVm.stopLoader();

                                        provider.update();
                                      },
                                    ),
                                  ),
                                );
                              }
                            });
                      }),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget cards(XFile img, String? name, String? address,
      String? rating, int index, FavouritesVm provider) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Get.height * .1,
                width: Get.width * .3,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child:
                        Image.file(
                            File(img.path),
                            fit: BoxFit.cover,
                          )
                        ),
              ),
              w4,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name ?? "",
                    style: R.textStyle.helvetica().copyWith(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  h1,
                  Text(
                    address ?? "",
                    style: R.textStyle
                        .helvetica()
                        .copyWith(color: Colors.white, fontSize: 9.sp),
                  ),
                  h0P5,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 4, right: 2),
                        child: Text(
                          rating ?? "",
                          style: R.textStyle.helvetica().copyWith(
                              color: R.colors.yellowDark,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        Icons.star,
                        color: R.colors.yellowDark,
                        size: 17,
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (index == provider.favouritesServices.length - 1)
            SizedBox()
          else
            SizedBox(
                width: Get.width * .9,
                child: Divider(
                  color: R.colors.grey.withOpacity(.40),
                  thickness: 2,
                  height: Get.height * .03,
                ))
        ],
      ),
    );
  }
}
